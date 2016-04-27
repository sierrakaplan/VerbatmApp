//
//  PostListVC.m
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel_BackendObject.h"

#import "Durations.h"

#import "FeedQueryManager.h"

#import "Icons.h"

#import "Like_BackendManager.h"
#import "LoadingIndicator.h"

#import "Notifications.h"

#import "Page_BackendObject.h"
#import "PostListVC.h"
#import "PostsQueryManager.h"
#import "PostCollectionViewCell.h"
#import "Post_BackendObject.h"
#import "Post_Channel_RelationshipManager.h"
#import "ParseBackendKeys.h"
#import "PostView.h"
#import <PromiseKit/PromiseKit.h>

#import "Share_BackendManager.h"
#import "SharePostView.h"
#import "SizesAndPositions.h"
#import "Styles.h"

@interface PostListVC () <UICollectionViewDelegate, UICollectionViewDataSource, SharePostViewDelegate, UIScrollViewDelegate>

@property (nonatomic) PostListType listType;
@property (nonatomic) BOOL isCurrentUserProfile;
@property (nonatomic) PFUser * listOwner;
@property (nonatomic) Channel * channelForList;

@property (nonatomic) NSMutableArray *parsePostObjects;
@property (strong, nonatomic) FeedQueryManager * feedQueryManager;
@property (nonatomic) NSInteger nextIndexToPresent;
@property (strong, nonatomic) PostCollectionViewCell *nextCellToPresent;
@property (nonatomic, strong) UILabel * noContentLabel;

@property (nonatomic) LoadingIndicator *customActivityIndicator;
@property (nonatomic) SharePostView *sharePostView;
@property (nonatomic) BOOL shouldPlayVideos;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic) BOOL isLoadingMore;
@property (nonatomic) BOOL footerBarIsUp;//like share bar
@property (nonatomic) PFObject *postToShare;

@property (nonatomic) UIImageView *reblogSucessful;
@property (nonatomic) UIImageView *following;
@property (nonatomic) UIImageView *publishSuccessful;
@property (nonatomic) UIImageView *publishFailed;

@property (nonatomic) void(^refreshPostsCompletion)(NSArray * posts);

#define LOAD_MORE_POSTS_COUNT 3 //number of posts left to see before we start loading more content
#define POST_CELL_ID @"postCellId"
#define NUM_POVS_TO_PREPARE_EARLY 2 //we prepare this number of POVVs after the current one for viewing

#define REBLOG_IMAGE_SIZE 150.f //when we put size it means both width and height
#define REPOST_ANIMATION_DURATION 4.f

@end

@implementation PostListVC

-(void) viewDidLoad {
	[self setDateSourceAndDelegate];
	[self defineRefreshPostsCompletion];
	[self registerClassForCustomCells];
	[self registerForNotifications];
}

-(void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self offScreen];
}

-(void) clearViews {
	[self offScreen];
	self.parsePostObjects = nil;
	[self.collectionView reloadData];
	self.feedQueryManager = nil;
	self.nextIndexToPresent = 0;
	self.nextCellToPresent = nil;
	self.postToShare = nil;
	self.isRefreshing = NO;
	self.isLoadingMore = NO;
	self.shouldPlayVideos = YES;
}

-(void) display:(Channel*)channelForList asPostListType:(PostListType)listType
			   withListOwner:(PFUser*)listOwner isCurrentUserProfile:(BOOL)isCurrentUserProfile {
	[self clearViews];

	self.channelForList = channelForList;
	self.listType = listType;
	self.listOwner = listOwner;
	self.isCurrentUserProfile = isCurrentUserProfile;
	[self refreshPosts];
	self.footerBarIsUp = (self.listType == listFeed || self.isCurrentUserProfile);
}

-(void) offScreen {
	for (NSInteger i = 0; i < [self.collectionView numberOfItemsInSection:0]; ++i) {
		PostCollectionViewCell* cell = (PostCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
		[cell offScreen];
		[cell clearViews];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView == self.collectionView) {
		CGPoint offset = scrollView.contentOffset;
		float reload_distance = 120;

		/* Refresh */
		if(offset.x < (0 - reload_distance)) {
			[self refreshPosts];
		}

		/* Load more */
		CGRect bounds = scrollView.bounds;
		CGSize size = scrollView.contentSize;
		UIEdgeInsets inset = scrollView.contentInset;

		float y = offset.x + bounds.size.width - inset.right;
		float h = size.width;
		if(y > h + reload_distance) {
			//todo:show indicator
			NSLog(@"load more items");
		}
	}
}

-(void)registerForNotifications{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(publishingFailedNotification:)
												 name:NOTIFICATION_MEDIA_SAVING_FAILED
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(successfullyPublishedNotification:)
												 name:NOTIFICATION_POST_PUBLISHED
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(followingSuccessfulNotification:)
												 name:NOTIFICATION_NOW_FOLLOWING_USER
											   object:nil];
}

//register our custom cell class
-(void)registerClassForCustomCells{
	[self.collectionView registerClass:[PostCollectionViewCell class] forCellWithReuseIdentifier:POST_CELL_ID];
}

//set the data source and delegate of the collection view
-(void)setDateSourceAndDelegate{
	self.collectionView.dataSource = self;
	self.collectionView.delegate = self;
	self.collectionView.pagingEnabled = YES;
	self.collectionView.scrollEnabled = YES;
	self.collectionView.showsHorizontalScrollIndicator = NO;
	self.collectionView.bounces = YES;
}

-(void)nothingToPresentHere {
	if (self.noContentLabel || self.parsePostObjects.count > 0){
		return;
	}

	self.noContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.f - NO_POSTS_LABEL_WIDTH/2.f, 0.f,
																	NO_POSTS_LABEL_WIDTH, self.view.frame.size.height)];
	self.noContentLabel.text = @"There are no posts to present :(";
	self.noContentLabel.font = [UIFont fontWithName:DEFAULT_FONT size:20.f];
	self.noContentLabel.textColor = [UIColor whiteColor];
	self.noContentLabel.textAlignment = NSTextAlignmentCenter;
	self.noContentLabel.lineBreakMode = NSLineBreakByWordWrapping;
	self.noContentLabel.numberOfLines = 3;
	self.view.backgroundColor = [UIColor blackColor];
	[self.view addSubview:self.noContentLabel];
}

-(void)removePresentLabel{
	if(self.noContentLabel){
		[self.noContentLabel removeFromSuperview];
		self.noContentLabel = nil;
	}
}

-(void) defineRefreshPostsCompletion {
	__weak typeof(self) weakSelf = self;
	self.refreshPostsCompletion = ^void(NSArray *posts) {
		[weakSelf.customActivityIndicator stopCustomActivityIndicator];
		if(posts.count) {
			NSIndexSet *indices = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0,[posts count])];
			[weakSelf.parsePostObjects insertObjects:posts atIndexes:indices];

			[weakSelf removePresentLabel];
			[weakSelf.collectionView reloadData];
		} else if(!weakSelf.parsePostObjects.count){
			[weakSelf nothingToPresentHere];
		}
		weakSelf.isRefreshing = NO;
	};
}

-(void) refreshPosts {
	if (self.isRefreshing) return;
	self.isRefreshing = YES;
	[self.customActivityIndicator startCustomActivityIndicator];
	if(self.listType == listFeed){
		[self.feedQueryManager refreshFeedWithCompletionHandler:self.refreshPostsCompletion];
	} else if (self.listType == listChannel) {
		//todo: load in chunks
		[PostsQueryManager getPostsInChannel:self.channelForList withLimit:20 withCompletionBlock:self.refreshPostsCompletion];
	}
}

//TODO:
//-(void) loadMorePosts {
//	[self.customActivityIndicator startCustomActivityIndicator];
//	if(self.listType == listFeed) {
//		[self.feedQueryManager loadMorePostsWithCompletionHandler:^(NSArray * posts) {
//			[self.customActivityIndicator stopCustomActivityIndicator];
//			if(posts.count){
//				[self loadNewBackendPosts:posts];
//				[self removePresentLabel];
//			} else if(self.presentedPostList.count == 0) {
//				[self nothingToPresentHere];
//			}
//		}];
//
//	} else if (self.listType == listChannel) {
//		[self loadCurrentChannel];
//	}
//}

//todo:
//-(void)clearOldPosts {
	//	for(PostView * view in self.presentedPostList){
	//		[view removeFromSuperview];
	//		[view clearPost];
	//	}
	//	[self.presentedPostList removeAllObjects];
//}

//-(void)loadNewBackendPosts:(NSArray *) backendPostObjects{
//	NSMutableArray * postLoadPromises = [[NSMutableArray alloc] init];
//
//	for(PFObject * postChannelActivityObject in backendPostObjects) {
//		AnyPromise * promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
//			PFObject * post = [postChannelActivityObject objectForKey:POST_CHANNEL_ACTIVITY_POST];
//			[Page_BackendObject getPagesFromPost:post andCompletionBlock:^(NSArray * pages) {
//				PostView *postView = [[PostView alloc] initWithFrame:self.view.bounds andPostChannelActivityObject:postChannelActivityObject
//															   small:NO];
//
//				NSNumber * numberOfPages = [NSNumber numberWithInteger:pages.count];
//
//				[postView renderPostFromPageObjects: pages];
//				[postView postOffScreen];
//				postView.delegate = self;
//				postView.listChannel = self.channelForList;
//				[self.presentedPostList addObject:postView];
//				resolve(nil);
//
//				AnyPromise *likesPromise = [Like_BackendManager numberOfLikesForPost:post];
//				AnyPromise *sharesPromise = [Share_BackendManager numberOfSharesForPost:post];
//				PMKWhen(@[likesPromise, sharesPromise]).then(^(NSArray *likesAndShares) {
//					NSNumber *numLikes = likesAndShares[0];
//					NSNumber *numShares = likesAndShares[1];
//					[postView createLikeAndShareBarWithNumberOfLikes:numLikes numberOfShares:numShares
//													   numberOfPages:numberOfPages
//											   andStartingPageNumber:@(1)
//															 startUp:self.footerBarIsUp
//													withDeleteButton:self.isCurrentUserProfile];
//					[postView addCreatorInfo];
//				});
//			}];
//		}];
//
//		[postLoadPromises addObject:promise];
//	}
//
//	//when all pages are loaded then we reload our list
//	PMKWhen(postLoadPromises).then(^(id data){
//		if (self.listType == listFeed) {
//			[self sortOurPostListEarliestToLatest: NO];
//		} else {
//			[self sortOurPostListEarliestToLatest: YES];
//		}
//		dispatch_async(dispatch_get_main_queue(), ^{
//			//prepare the first post object
//			if(self.shouldPlayVideos && !self.isReloading)[(PostView *)self.presentedPostList.firstObject postOnScreen];
//			[self.collectionView reloadData];
//			self.isReloading = NO;
//		});
//	});
//}

//-(void)sortOurPostListEarliestToLatest: (BOOL) earliestToLatest {
//	[self.presentedPostList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//		PostView * view1 = obj1;
//		PostView * view2 = obj2;
//
//		PFObject * pc_activityA = view1.parsePostChannelActivityObject;
//		PFObject * pc_activityB = view2.parsePostChannelActivityObject;
//
//		NSTimeInterval distanceBetweenDates = [[pc_activityA createdAt] timeIntervalSinceDate:[pc_activityB createdAt]];
//		double secondsInMinute = 60;
//		NSInteger secondsBetweenDates = distanceBetweenDates / secondsInMinute;
//
//		if (secondsBetweenDates == 0)
//			return NSOrderedSame;
//		else if (secondsBetweenDates < 0)
//			return earliestToLatest ? NSOrderedAscending : NSOrderedDescending;
//		else
//			return earliestToLatest ? NSOrderedDescending : NSOrderedAscending;
//
//	}];
//}

#pragma mark - DataSource -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
	 numberOfItemsInSection:(NSInteger)section {
	return self.parsePostObjects.count;
}

#pragma mark - ViewDelegate -
- (BOOL)collectionView: (UICollectionView *)collectionView
shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	PostCollectionViewCell *currentCell;
	if (indexPath.row == self.nextIndexToPresent) {
		currentCell = self.nextCellToPresent;
	}
	if (currentCell == nil) {
		currentCell = [self postCellAtIndexPath:indexPath];
	}
	[currentCell onScreen];

	//Prepare next cell
	self.nextIndexToPresent = indexPath.row+1;
	self.nextCellToPresent = [self postCellAtIndexPath:[NSIndexPath indexPathForRow:self.nextIndexToPresent inSection:indexPath.section]];
	if (self.nextCellToPresent) [self.nextCellToPresent almostOnScreen];

	// Load more posts
	if(indexPath.row >= (self.parsePostObjects.count - LOAD_MORE_POSTS_COUNT)) {
		//todo:
		//		[self loadMorePosts];
	}

	return currentCell;
}

-(PostCollectionViewCell*) postCellAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row >= self.parsePostObjects.count) return nil;
	PostCollectionViewCell *cell = (PostCollectionViewCell *) [self.collectionView dequeueReusableCellWithReuseIdentifier:POST_CELL_ID forIndexPath:indexPath];
	PFObject *postObject = self.parsePostObjects[indexPath.row];
	if (cell.currentPostActivityObject != postObject) {
		[cell clearViews];
		[cell presentPostFromPCActivityObj:postObject andChannel:self.channelForList
						  withDeleteButton:self.isCurrentUserProfile];
	}
	return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
	// If the indexpath is not within visible objects then it is offscreen
	if ([collectionView.indexPathsForVisibleItems indexOfObject:indexPath] == NSNotFound) {
		[(PostCollectionViewCell*)cell offScreen];
	}
}

//todo: delete?
-(CGFloat) getVisibileCellIndex{
	return self.collectionView.contentOffset.x / self.view.frame.size.width;
}

// Marks all posts as off screen
//-(void) stopAllVideoContent {
//	self.shouldPlayVideos = NO;
//	for (NSInteger i = 0; i < [self.collectionView numberOfItemsInSection:0]; ++i) {
//		[(PostCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] offScreen];
//	}
//}

// Tells post it's on screen
-(void) continueVideoContent {
	self.shouldPlayVideos = YES;
	NSInteger visibleCellIndex = [self getVisibileCellIndex];
	if(visibleCellIndex < self.parsePostObjects.count) {
		[(PostCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:visibleCellIndex inSection:0]] onScreen];
	}
}

-(void) footerShowing: (BOOL) showing {
	self.footerBarIsUp = showing;
	[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
		[self setNeedsStatusBarAppearanceUpdate];
	} completion:^(BOOL finished) {
	}];
	for (NSInteger i = 0; i < [self.collectionView numberOfItemsInSection:0]; ++i) {
		[(PostCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] shiftLikeShareBarDown:!showing];
	}
}

#pragma mark - Scrollview delegate -

//todo:
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView  {
	//    NSInteger visibleIndex = [self getVisibileCellIndex];
	//    if(visibleIndex < self.presentedPostList.count){
	//        PostView * currentView = self.presentedPostList[visibleIndex];
	//        [self turnOffCellsOffScreenWithVisibleCell:currentView];
	//        [self prepareNextViewAfterVisibleIndex:visibleIndex];
	//
	//    }
}

//-(void)prepareNextViewAfterVisibleIndex:(NSInteger) visibleIndex{
//	for(NSInteger i = 0; i < self.presentedPostList.count; i++){
//		PostView * view = self.presentedPostList[i];
//		if((i > visibleIndex) && (i < (visibleIndex + NUM_POVS_TO_PREPARE_EARLY))){
//			[view presentMediaContent];
//		}
//	}
//}

-(void)turnOffCellsOffScreenWithVisibleCell:(PostView *)visibleCell{
	//    if(visibleCell && (self.lastVisibleCell != visibleCell)){
	//		if(self.lastVisibleCell) {
	//			[self.lastVisibleCell postOffScreen];
	//			self.lastVisibleCell = visibleCell;
	//		}else{
	//            if([self.presentedPostList indexOfObject:visibleCell] != 0){
	//                [(PostView *)self.presentedPostList[0] postOffScreen];
	//            }
	//			self.lastVisibleCell = visibleCell;
	//		}
	//		[visibleCell postOnScreen];
	//	}
}
//
//-(void) deleteButtonSelectedOnPostView:(PostView *)postView withPostObject:(PFObject *)post reblogged:(BOOL)reblogged {
//	if (reblogged) {
//		[self deleteReblog:post onPostView:postView];
//		return;
//	}
//	UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
//																   message:@"Entire post will be deleted."
//															preferredStyle:UIAlertControllerStyleAlert];
//
//	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
//														 handler:^(UIAlertAction * action) {}];
//	UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//		NSInteger postIndex = [self.presentedPostList indexOfObject: postView];
//		[self removePostAtIndex: postIndex];
//		[postView clearPost];
//		[Post_BackendObject deletePost:post];
//	}];
//
//	[alert addAction: cancelAction];
//	[alert addAction: deleteAction];
//	[self presentViewController:alert animated:YES completion:nil];
//}
//
//-(void)flagButtonSelectedOnPostView:(PostView *)postView withPostObject:(PFObject *)post{
//
//    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Flag Post"
//                                                                   message:@"Are you sure you want to flag the content of this post? We will review it ASAP."
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//
//    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
//                                                         handler:^(UIAlertAction * action) {}];
//    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//        [Post_BackendObject markPostAsFlagged:post];
//    }];
//
//    [alert addAction: cancelAction];
//    [alert addAction: deleteAction];
//    [self presentViewController:alert animated:YES completion:nil];
//
//}
//
//
//-(void) deleteReblog:(PFObject *)post onPostView:(PostView *)postView {
//	UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
//																   message:@"Are you sure you want to delete this reblogged post from your channel?"
//															preferredStyle:UIAlertControllerStyleAlert];
//
//	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
//														 handler:^(UIAlertAction * action) {}];
//	UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//		NSInteger postIndex = [self.presentedPostList indexOfObject: postView];
//		[self removePostAtIndex: postIndex];
//		[postView clearPost];
//		[postView.parsePostChannelActivityObject deleteInBackground];
//	}];
//
//	[alert addAction: cancelAction];
//	[alert addAction: deleteAction];
//	[self presentViewController:alert animated:YES completion:nil];
//}
//
//-(void)removePostAtIndex:(NSInteger)i {
//	[self.collectionView performBatchUpdates: ^ {
//		[self.presentedPostList removeObjectAtIndex:i];
//		NSIndexPath *indexPath =[NSIndexPath indexPathForRow:i inSection:0];
//		[self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
//		if (self.presentedPostList.count < 1) {
//			[self nothingToPresentHere];
//		}
//	} completion:^(BOOL finished) {
//
//	}];
//}
//
//-(void) shareOptionSelectedForParsePostObject: (PFObject* )post {
//	[self.postListDelegate hideNavBarIfPresent];
//	self.postToShare = post;
//	[self presentShareSelectionViewStartOnChannels:YES];
//}
//
//-(void)presentShareSelectionViewStartOnChannels:(BOOL) startOnChannels{
//	if(self.sharePostView){
//		[self.sharePostView removeFromSuperview];
//		self.sharePostView = nil;
//	}
//
//	CGRect onScreenFrame = CGRectMake(0.f, self.view.frame.size.height/2.f, self.view.frame.size.width, self.view.frame.size.height/2.f);
//	CGRect offScreenFrame = CGRectMake(0.f, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.f);
//	self.sharePostView = [[SharePostView alloc] initWithFrame:offScreenFrame shouldStartOnChannels:startOnChannels];
//	self.sharePostView.delegate = self;
//	[self.view addSubview:self.sharePostView];
//	[self.view bringSubviewToFront:self.sharePostView];
//	[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^ {
//		self.sharePostView.frame = onScreenFrame;
//	}];
//}
//
//-(void)removeSharePOVView{
//	if(self.sharePostView){
//		CGRect offScreenFrame = CGRectMake(0.f, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.f);
//		[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
//			self.sharePostView.frame = offScreenFrame;
//		}completion:^(BOOL finished) {
//			if(finished){
//				[self.sharePostView removeFromSuperview];
//				self.sharePostView = nil;
//			}
//		}];
//	}
//}

#pragma mark -Share Seletion View Protocol -
//-(void)cancelButtonSelected{
//	[self removeSharePOVView];
//}
//
////todo: save share object
//-(void)postPostToChannels:(NSMutableArray *) channels{
//
//    if(channels.count) {
//
//        [Post_Channel_RelationshipManager savePost:self.postToShare toChannels:channels withCompletionBlock:^{
//			dispatch_async(dispatch_get_main_queue(), ^{
//				[self successfullyReblogged];
//			});
//		}];
//
//
//	}
//
//	[self removeSharePOVView];
//}
//
//-(void)successfullyReblogged{
//	[self.view addSubview:self.reblogSucessful];
//	[self.view bringSubviewToFront:self.reblogSucessful];
//
//	[UIView animateWithDuration:REPOST_ANIMATION_DURATION animations:^{
//		self.reblogSucessful.alpha = 0.f;
//	}completion:^(BOOL finished) {
//
//        [self.reblogSucessful removeFromSuperview];
//		self.reblogSucessful = nil;
//	}];
//}
//

#pragma mark - Notifications (publishing, following) -

-(void)successfullyPublishedNotification:(NSNotification *) notification {
	[self.view addSubview:self.publishSuccessful];
	[self.view bringSubviewToFront:self.publishSuccessful];
	[UIView animateWithDuration:REPOST_ANIMATION_DURATION animations:^{
		self.publishSuccessful.alpha = 0.f;
	}completion:^(BOOL finished) {
		[self.publishSuccessful removeFromSuperview];
		self.publishSuccessful = nil;
	}];
}


-(void)publishingFailedNotification:(NSNotification *) notification{
	[self.view addSubview:self.publishFailed];
	[self.view bringSubviewToFront:self.publishFailed];
	[UIView animateWithDuration:REPOST_ANIMATION_DURATION animations:^{
		self.publishFailed.alpha = 0.f;
	}completion:^(BOOL finished) {
		[self.publishFailed removeFromSuperview];
		self.publishFailed = nil;
	}];
}

-(void)followingSuccessfulNotification:(NSNotification *) notification{
	[self.view addSubview:self.following];
	[self.view bringSubviewToFront:self.following];
	[UIView animateWithDuration:REPOST_ANIMATION_DURATION animations:^{
		self.following.alpha = 0.f;
	}completion:^(BOOL finished) {
		[self.following removeFromSuperview];
		self.following = nil;
	}];
}


#pragma mark -POV delegate-

-(void)channelSelected:(Channel *) channel{
	[self.postListDelegate channelSelected:channel];
}

#pragma mark -Lazy instantiation-

-(UIImageView *)reblogSucessful {
	if(!_reblogSucessful){
		_reblogSucessful = [[UIImageView alloc] init];
		[_reblogSucessful setImage:[UIImage imageNamed:REBLOG_IMAGE]];
		[_reblogSucessful setFrame:CGRectMake((self.view.frame.size.width/2.f)-REBLOG_IMAGE_SIZE/2.f, (self.view.frame.size.height/2.f) -REBLOG_IMAGE_SIZE/2.f, REBLOG_IMAGE_SIZE, REBLOG_IMAGE_SIZE)];
	}
	return _reblogSucessful;
}


-(UIImageView *)publishSuccessful {
	if(!_publishSuccessful){
		_publishSuccessful = [[UIImageView alloc] init];
		[_publishSuccessful setImage:[UIImage imageNamed:SUCCESS_PUBLISHING_IMAGE]];
		[_publishSuccessful setFrame:self.reblogSucessful.frame];
		self.reblogSucessful = nil;
	}
	return _publishSuccessful;
}

-(UIImageView *)publishFailed {
	if(!_publishFailed){
		_publishFailed = [[UIImageView alloc] init];
		[_publishFailed setImage:[UIImage imageNamed:FAILED_PUBLISHING_IMAGE]];
		[_publishFailed setFrame:self.reblogSucessful.frame];
		self.reblogSucessful = nil;
	}
	return _publishFailed;
}

-(UIImageView *)following {
	if(!_following){
		_following = [[UIImageView alloc] init];
		[_following setImage:[UIImage imageNamed:FOLLOWING_SUCCESS_IMAGE]];
		[_following setFrame:self.reblogSucessful.frame];
		self.reblogSucessful = nil;
	}
	return _following;
}

-(LoadingIndicator *)customActivityIndicator {
	if(!_customActivityIndicator){
		CGPoint center = CGPointMake(self.view.frame.size.width/2., self.view.frame.size.height/2.f);
		_customActivityIndicator = [[LoadingIndicator alloc] initWithCenter:center andImage:[UIImage imageNamed:LOAD_ICON_IMAGE]];
		[self.view addSubview:_customActivityIndicator];
		[self.view bringSubviewToFront:_customActivityIndicator];
	}
	return _customActivityIndicator;
}

-(NSMutableArray *) parsePostObjects {
	if(!_parsePostObjects) _parsePostObjects = [[NSMutableArray alloc] init];
	return _parsePostObjects;
}

-(FeedQueryManager*) feedQueryManager {
	if (!_feedQueryManager) {
		_feedQueryManager = [FeedQueryManager sharedInstance];
		[_feedQueryManager clearFeedData];
	}
	return _feedQueryManager;
}

@end
