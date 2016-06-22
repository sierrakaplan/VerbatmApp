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
#import "Page_BackendObject.h"
#import "Photo_BackendObject.h"
#import "Video_BackendObject.h"
#import "Channel_BackendObject.h"
#import "ParseBackendKeys.h"
#import "PostView.h"
#import <PromiseKit/PromiseKit.h>

#import "Share_BackendManager.h"
#import "SharePostView.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import <Branch/BranchUniversalObject.h>
#import <Branch/BranchLinkProperties.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>
#import "PageTypeAnalyzer.h"

#import "User_BackendObject.h"
#import "UserInfoCache.h"

@interface PostListVC () <UICollectionViewDelegate, UICollectionViewDataSource, SharePostViewDelegate,
UIScrollViewDelegate, PostCollectionViewCellDelegate>

@property (nonatomic) PostListType listType;
@property (nonatomic) BOOL isCurrentUserProfile;
@property (nonatomic) PFUser *listOwner;
@property (nonatomic) Channel *channelForList;
@property (nonatomic) NSDate *latestDate;

@property (nonatomic) NSMutableArray *parsePostObjects;
@property (strong, nonatomic) FeedQueryManager *feedQueryManager;
@property (strong, nonatomic) PostsQueryManager *postsQueryManager;
@property (nonatomic) NSInteger nextIndexToPresent;
@property (nonatomic) NSInteger nextNextIndex;
@property (strong, nonatomic) PostCollectionViewCell *nextCellToPresent;
@property (strong, nonatomic) PostCollectionViewCell *nextNextCell;
@property (nonatomic, strong) UILabel * noContentLabel;

@property (nonatomic) LoadingIndicator *customActivityIndicator;
@property (nonatomic) SharePostView *sharePostView;
@property (nonatomic) BOOL shouldPlayVideos;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic) BOOL isLoadingMore;
@property (nonatomic) BOOL footerBarIsUp;//like share bar
@property (nonatomic) BOOL fbShare;
@property (nonatomic) NSString *postImageText;
@property (nonatomic) PFObject *postToShare;
//@property (strong, nonatomic) BranchUniversalObject *branchUniversalObject;

@property (nonatomic) UIImageView *reblogSucessful;
@property (nonatomic) UIImageView *following;
@property (nonatomic) UIImageView *publishSuccessful;
@property (nonatomic) UIImageView *publishFailed;

@property (nonatomic) NSUInteger selectedCellIndex;

@property (nonatomic) void(^refreshPostsCompletionFeed)(NSArray * posts);
@property (nonatomic) void(^refreshPostsCompletionChannel)(NSArray * posts);
@property (nonatomic) void(^loadMorePostsCompletion)(NSArray * posts);

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
    self.automaticallyAdjustsScrollViewInsets = NO;
}

-(void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self offScreen];
}

-(void)viewDidLayoutSubviews{
    
}

-(void) clearViews {
	for (PostCollectionViewCell *cellView in [self.collectionView visibleCells]) {
		[cellView offScreen];
		[cellView clearViews];
	}
	self.parsePostObjects = nil;
	[self.collectionView reloadData];
	self.feedQueryManager = nil;
	self.nextIndexToPresent = 0;
	self.nextNextIndex = 1;
	self.nextCellToPresent = nil;
	self.nextNextCell = nil;
	self.postToShare = nil;
	self.isRefreshing = NO;
	self.isLoadingMore = NO;
	self.shouldPlayVideos = YES;
    

}

-(void) display:(Channel*)channelForList asPostListType:(PostListType)listType
  withListOwner:(PFUser*)listOwner isCurrentUserProfile:(BOOL)isCurrentUserProfile andStartingDate:(NSDate*)date {
	[self clearViews];
	self.latestDate = date;
	self.channelForList = channelForList;
	self.listType = listType;
	self.listOwner = listOwner;
	self.isCurrentUserProfile = isCurrentUserProfile;
	[self refreshPosts];
	self.footerBarIsUp = (listType != listSmallSizedList);
}

-(void) offScreen {
	for (PostCollectionViewCell *cellView in [self.collectionView visibleCells]) {
		[cellView offScreen];
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
		if(y > h + reload_distance && !self.isRefreshing && !self.isLoadingMore) {
			//todo: show indicator
		}
	}
}


-(void)changePostViewsToSize:(CGSize) newSize{
    NSArray * cells = [self.collectionView visibleCells];
    if(cells){
        
        for (PostCollectionViewCell *currentCell in cells){
            [currentCell changePostFrameToSize:newSize];
        }
    }
}


-(void)registerForNotifications{
	
}

//register our custom cell class
-(void)registerClassForCustomCells{
	[self.collectionView registerClass:[PostCollectionViewCell class] forCellWithReuseIdentifier:POST_CELL_ID];
}

//set the data source and delegate of the collection view
-(void)setDateSourceAndDelegate{
	self.collectionView.dataSource = self;
	self.collectionView.delegate = self;
	self.collectionView.pagingEnabled = NO;
	self.collectionView.scrollEnabled = YES;
	self.collectionView.showsHorizontalScrollIndicator = NO;
	self.collectionView.bounces = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];

}

-(void)nothingToPresentHere {
    
    [self.postListDelegate noPostFound];
    
    if (self.noContentLabel || self.parsePostObjects.count > 0){
		return;
	}
    
    
    
	self.noContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.f - NO_POSTS_LABEL_WIDTH/2.f, 0.f,
																	NO_POSTS_LABEL_WIDTH, self.view.frame.size.height)];
	self.noContentLabel.text = @"There are no posts to present :(";
	self.noContentLabel.font = [UIFont fontWithName:REGULAR_FONT size:20.f];
	self.noContentLabel.textColor = [UIColor whiteColor];
	self.noContentLabel.textAlignment = NSTextAlignmentCenter;
	self.noContentLabel.lineBreakMode = NSLineBreakByWordWrapping;
	self.noContentLabel.numberOfLines = 3;
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
	self.refreshPostsCompletionFeed = ^void(NSArray *posts) {
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

	self.refreshPostsCompletionChannel = ^void(NSArray *posts) {
		[weakSelf.customActivityIndicator stopCustomActivityIndicator];
		if(posts.count) {
			weakSelf.parsePostObjects = nil;
			[weakSelf.parsePostObjects addObjectsFromArray:posts];

			[weakSelf removePresentLabel];
			[weakSelf.collectionView reloadData];
		} else if(!weakSelf.parsePostObjects.count){
			[weakSelf nothingToPresentHere];
		}
		weakSelf.isRefreshing = NO;
	};

	self.loadMorePostsCompletion = ^void(NSArray *posts) {
		if (posts.count) {
			weakSelf.isLoadingMore = NO;
			NSMutableArray *indices = [NSMutableArray array];
			NSInteger index = weakSelf.parsePostObjects.count;
			for (NSInteger i = index; i < index + posts.count; i++) {
				[indices addObject:[NSIndexPath indexPathForItem:i inSection:0]];
			}
			// Perform the updates
			[weakSelf.collectionView performBatchUpdates:^{
				//Insert the new data
				[weakSelf.parsePostObjects addObjectsFromArray:posts];
				//Insert the new cells
				[weakSelf.collectionView insertItemsAtIndexPaths:indices];

			} completion:nil];
		}
	};
}

-(void) refreshPosts {
	if (self.isRefreshing) return;
	self.isRefreshing = YES;
	self.isLoadingMore = NO;
	[self.customActivityIndicator startCustomActivityIndicator];
	if(self.listType == listFeed){
		[self.feedQueryManager refreshFeedWithCompletionHandler:self.refreshPostsCompletionFeed];
	} else if (self.listType == listChannel || self.listType == listSmallSizedList) {
		if (self.isCurrentUserProfile) [self.postsQueryManager refreshPostsInUserChannel:self.channelForList withCompletionBlock:self.refreshPostsCompletionChannel];
		else [self.postsQueryManager refreshPostsInChannel:self.channelForList startingAt:self.latestDate
								  withCompletionBlock:self.refreshPostsCompletionChannel];
	}
}

-(void) loadMorePosts {
	if (self.isLoadingMore) return;
	self.isLoadingMore = YES;
	if (self.listType == listFeed) {
		[self.feedQueryManager loadMorePostsWithCompletionHandler:self.loadMorePostsCompletion];
	} else if (self.listType == listChannel || self.listType ==listSmallSizedList) {
		[self.postsQueryManager loadMorePostsInChannel:self.channelForList withCompletionBlock:self.loadMorePostsCompletion];
	}
}

//todo:
-(void) loadOlderPosts {

}

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
	} else if (indexPath.row == self.nextNextIndex) {
		currentCell = self.nextNextCell;
	}
	if (currentCell == nil) {
		currentCell = [self postCellAtIndexPath:indexPath];
	}
	[currentCell onScreen];

	//Prepare next cell (after first time will just be nextNextCell)
	self.nextIndexToPresent = indexPath.row+1;
	self.nextCellToPresent = self.nextNextCell;
	if (!self.nextCellToPresent) {
		self.nextCellToPresent = [self postCellAtIndexPath:[NSIndexPath indexPathForRow:self.nextIndexToPresent inSection:indexPath.section]];
	}
	if (self.nextCellToPresent) [self.nextCellToPresent almostOnScreen];

	//Prepare next next cell
	self.nextNextIndex = indexPath.row+2;
	self.nextNextCell = [self postCellAtIndexPath:[NSIndexPath indexPathForRow:self.nextNextIndex inSection:indexPath.section]];
	if (self.nextNextCell) [self.nextNextCell almostOnScreen];

	// Load more posts
	if(indexPath.row >= (self.parsePostObjects.count - LOAD_MORE_POSTS_COUNT)
	   && !self.isLoadingMore && !self.isRefreshing) {
		[self loadMorePosts];
	}

	return currentCell;
}



-(PostCollectionViewCell * )getCellUnderPoint:(CGPoint) touchPoint{
    NSArray * visibleCells = [self.collectionView visibleCells];
    for(PostCollectionViewCell * cell in visibleCells){
        NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
        CGFloat cellOriginY = indexPath.row * (cell.frame.size.width);
        CGFloat touchY = touchPoint.y;
        CGFloat cellWidthSize = cell.frame.size.width;
        if(cellOriginY < touchY &&
           cellOriginY + cellWidthSize >= touchPoint.y){
            return cell;
        }
    }
    //should not reach here
    return nil;
}


//note point is in our collection view reference frame
-(void)setReadyToEnlargeWithNewSize:(CGSize) newSize{
   
    //[self.view layoutIfNeeded];
   if(self.selectedCellIndex < self.parsePostObjects.count) [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedCellIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
}

-(PostCollectionViewCell*) postCellAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row >= self.parsePostObjects.count) return nil;
	PostCollectionViewCell *cell = (PostCollectionViewCell *) [self.collectionView dequeueReusableCellWithReuseIdentifier:POST_CELL_ID forIndexPath:indexPath];
	cell.cellDelegate = self;
	PFObject *postObject = self.parsePostObjects[indexPath.row];
	if (cell.currentPostActivityObject != postObject) {
		[cell clearViews];
        
        if(self.listType == listSmallSizedList){
            [cell putInSmallMode];
        }else{
            [cell removeFromSmallMode];
        }
        
		[cell presentPostFromPCActivityObj:postObject andChannel:self.channelForList
						  withDeleteButton:self.isCurrentUserProfile andLikeShareBarUp:self.footerBarIsUp];
        [self addEnlargeGestureToCell:cell];
	}
	return cell;
}

-(void)addEnlargeGestureToCell:(PostCollectionViewCell *) cell {
    
    if(!cell.hasTapGesture){
        UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changePostListSize:)];
        singleTap.numberOfTapsRequired = 1;
        [cell addGestureRecognizer:singleTap];
        cell.hasTapGesture = YES;
    }
    
}

-(void)changePostListSize:(UIGestureRecognizer *) tapGesture {
    PostCollectionViewCell * selectedCell = (PostCollectionViewCell *) [tapGesture view];
    if(selectedCell){
        self.selectedCellIndex = [self.collectionView indexPathForCell:selectedCell].row;
        
        UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:[self.collectionView indexPathForCell:selectedCell]];
        
        CGFloat originX = attributes.frame.origin.x - self.collectionView.contentOffset.x;
        CGFloat originY = attributes.frame.origin.y;
        
        
        
        [self.postListDelegate cellSelectedWithImage:[self getImageScreenShotFromCell:selectedCell] andStartFrame:CGRectMake(originX, originY, attributes.frame.size.width, attributes.frame.size.height)];
    }
}


-(UIImage *) getImageScreenShotFromCell:(PostCollectionViewCell *) cell{

    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);

    [cell drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];

    UIImage *screenShotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screenShotImage;
}
- (void) collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
	// If the indexpath is not within visible objects then it is offscreen
	if ([collectionView.indexPathsForVisibleItems indexOfObject:indexPath] == NSNotFound) {
		[(PostCollectionViewCell*)cell offScreen];
	}
}

-(void) footerShowing: (BOOL) showing {
	self.footerBarIsUp = showing;
	[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
		[self setNeedsStatusBarAppearanceUpdate];
	} completion:^(BOOL finished) {
	}];
	//todo: this is only for visible cell for some reason - see if can find all cells that exist
	for (NSInteger i = 0; i < [self.collectionView numberOfItemsInSection:0]; ++i) {
		PostCollectionViewCell* cell = (PostCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
		if (cell) {
			[cell shiftLikeShareBarDown:!showing];
		}
	}
	[self.nextCellToPresent shiftLikeShareBarDown:!showing];
	[self.nextNextCell shiftLikeShareBarDown:!showing];
}

#pragma mark - PostCollectionViewCell delegate -

#pragma mark - Deleting -

-(void) deleteButtonSelectedOnPostView:(PostView *)postView withPostObject:(PFObject *)post
			 andPostChannelActivityObj:(PFObject *)pfActivityObj reblogged:(BOOL)reblogged {
	if (reblogged) {
		[self deleteReblog:post onPostView:postView withPostChannelActivityObj:pfActivityObj];
		return;
	}
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete post"
																   message:@"Entire post will be deleted."
															preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction * action) {}];
	UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		NSInteger postIndex = [self.parsePostObjects indexOfObject: pfActivityObj];
		[self removePostAtIndex: postIndex];
		[postView clearPost];
		[Post_BackendObject deletePost:post];
	}];

	[alert addAction: cancelAction];
	[alert addAction: deleteAction];
	[self presentViewController:alert animated:YES completion:nil];
}

-(void) deleteReblog:(PFObject *)post onPostView:(PostView *)postView withPostChannelActivityObj:(PFObject *)pfActivityObj {
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete reblogged post"
																   message:@"Are you sure?"
															preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction * action) {}];
	UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		NSInteger postIndex = [self.parsePostObjects indexOfObject: pfActivityObj];
		[self removePostAtIndex: postIndex];
		[postView clearPost];
		[postView.parsePostChannelActivityObject deleteInBackground];
	}];

	[alert addAction: cancelAction];
	[alert addAction: deleteAction];
	[self presentViewController:alert animated:YES completion:nil];
}

-(void)removePostAtIndex:(NSInteger)i {
	[self.collectionView performBatchUpdates: ^ {
		[self.parsePostObjects removeObjectAtIndex:i];
		NSIndexPath *indexPath =[NSIndexPath indexPathForRow:i inSection:0];
		[self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
		if (self.parsePostObjects.count < 1) {
			[self nothingToPresentHere];
		}
	} completion:^(BOOL finished) {
	}];
}



#pragma mark Flagging & Blocking

-(void) flagOrBlockButtonSelectedOnPostView:(PostView *)postView withPostObject:(PFObject *)post{

	UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
																   message:nil
															preferredStyle:UIAlertControllerStyleActionSheet];

	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction * action) {}];
	UIAlertAction* flagAction = [UIAlertAction actionWithTitle:@"Report Post" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		[self confirmFlagOrBlock:YES onPostView:postView withPostObject:post];
	}];
	UIAlertAction* blockAction = [UIAlertAction actionWithTitle:@"Block User" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		[self confirmFlagOrBlock:NO onPostView:postView withPostObject:post];
	}];

	[alert addAction: cancelAction];
	[alert addAction: flagAction];
	[alert addAction: blockAction];
	[self presentViewController:alert animated:YES completion:nil];
}

-(void) confirmFlagOrBlock:(BOOL)flagging onPostView:(PostView *)postView withPostObject:(PFObject *)post{
	UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction * action) {}];
	UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		if (flagging) {
			[Post_BackendObject markPostAsFlagged:post];
			//todo: send us an email
		} else {
			PFObject *postChannelObject = [postView parsePostChannelActivityObject];
			PFObject *channel = [postChannelObject objectForKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO];
			PFUser *user = [channel objectForKey:CHANNEL_CREATOR_KEY];
			[User_BackendObject blockUser:user];
		}
	}];
	[confirmAlert addAction: cancelAction];
	[confirmAlert addAction: deleteAction];
	[self presentViewController:confirmAlert animated:YES completion:nil];
}

#pragma mark Sharing

-(void) shareOptionSelectedForParsePostObject: (PFObject* )post {
	[self.postListDelegate hideNavBarIfPresent];
	self.postToShare = post;
	[self presentShareSelectionViewStartOnChannels:YES];
}

-(void)presentShareSelectionViewStartOnChannels:(BOOL) startOnChannels {
	if(self.sharePostView){
		[self.sharePostView removeFromSuperview];
		self.sharePostView = nil;
	}

	CGRect onScreenFrame = CGRectMake(0.f, self.view.frame.size.height/2.f, self.view.frame.size.width, self.view.frame.size.height/2.f);
	CGRect offScreenFrame = CGRectMake(0.f, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.f);
	self.sharePostView = [[SharePostView alloc] initWithFrame:offScreenFrame];
	self.sharePostView.delegate = self;
	self.view.userInteractionEnabled = NO;
	[[UIApplication sharedApplication].keyWindow addSubview:self.sharePostView];

	//[self.view addSubview:self.sharePostView];
	[[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.sharePostView];
	//[self.view bringSubviewToFront:self.sharePostView];
	[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^ {
		self.sharePostView.frame = onScreenFrame;
	}];
}

-(void)removeSharePOVView{
	if(self.sharePostView){
		CGRect offScreenFrame = CGRectMake(0.f, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.f);
		[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
			self.sharePostView.frame = offScreenFrame;
		}completion:^(BOOL finished) {
			if(finished){
				[self.sharePostView removeFromSuperview];
				self.sharePostView = nil;
			}
		}];
	}
}

#pragma mark -Share Seletion View Protocol -

-(void)cancelButtonSelected{
	[self removeSharePOVView];
	self.view.userInteractionEnabled = YES;
}

//todo: save share object
-(void) reblogToVerbatm:(BOOL)verbatm andFacebook:(BOOL)facebook {
	if(verbatm) {
		//todo: change this eventually to one channel
		NSMutableArray *channels = [[NSMutableArray alloc] init];
		[channels addObject:[[UserInfoCache sharedInstance] getUserChannel]];
		[Post_Channel_RelationshipManager savePost:self.postToShare toChannels:channels withCompletionBlock:^{
			dispatch_async(dispatch_get_main_queue(), ^{
				[self successfullyReblogged];
			});
		}];
	}
	if(facebook){
		dispatch_async(dispatch_get_main_queue(), ^{
			[self postPostExternal];
		});
	}

	[self removeSharePOVView];
    self.view.userInteractionEnabled = YES;
}

-(void)postPostExternal {
	[Page_BackendObject getPagesFromPost:self.postToShare andCompletionBlock:^(NSArray *pages){
		PFObject *po = pages[0];
		PageTypes type = [((NSNumber *)[po valueForKey:PAGE_VIEW_TYPE]) intValue];

		if(type == PageTypePhoto || type == PageTypePhotoVideo){
			[Photo_BackendObject getPhotosForPage:po andCompletionBlock:^(NSArray * photoObjects) {
				PFObject *photo = photoObjects[0];
				NSString *photoLink = [photo valueForKey:PHOTO_IMAGEURL_KEY];
				[self postToFacebookWithShareLink:photoLink];
			}];
		} else if(type == PageTypeVideo){
			[Video_BackendObject getVideoForPage:po andCompletionBlock:^(PFObject * videoObject) {
				NSString * thumbNailUrl = [videoObject valueForKey:VIDEO_THUMBNAIL_KEY];
				[self postToFacebookWithShareLink:thumbNailUrl];
			}];
		} 
	}];
}

-(void) postToFacebookWithShareLink:(NSString*)shareLink {
	NSString *postId = self.postToShare.objectId;
	PFUser *user = [PFUser currentUser];
	NSString *name = [user valueForKey:VERBATM_USER_NAME_KEY];
	Channel_BackendObject *channelObj = [self.postToShare valueForKey:POST_CHANNEL_KEY];
	NSString *channelName = [channelObj valueForKey:CHANNEL_NAME_KEY];

//	NSDictionary*params = [[NSDictionary alloc] initWithObjects:@[[NSString stringWithFormat:@"%@ shared a post from '%@' Verbatm blog", name, channelName],
//																  @"Verbatm is a blogging app that allows users to create, curate, and consume multimedia content. Find Verbatm in the App Store!",
//																  shareLink,
//																  @"http://verbatm.io"]
//														forKeys:@[@"$og_title",
//																  @"$og_description",
//																  @"$og_image_url",
//																  @"$fallback_url"]];
//	NSLog(@"Getting link for fb for user %@ reblogging from channel %@ for post %@...", name, channelName, postId);
//	[[Branch getInstance] getShortURLWithParams:params
//									 andChannel:@"facebook"
//									 andFeature:@"sharing"
//									andCallback:^(NSString *url, NSError *err) {
//										NSLog(@"got callback from branch");
//										if (!err) {
//											NSLog(@"got my Branch invite link to share: %@", url);
//											NSURL *link = [NSURL URLWithString:url];
//											FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
//											content.contentURL = link;
//											[FBSDKShareDialog showFromViewController:self
//																		 withContent:content
//																			delegate:nil];
//										} else {
//											NSLog(@"An error occured %@", err.description);
//										}
//									}];

	    BranchUniversalObject *branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:postId];
	    branchUniversalObject.title = [NSString stringWithFormat:@"%@ shared a post from '%@' Verbatm blog", name, channelName];
	    branchUniversalObject.contentDescription = @"Verbatm is a blogging app that allows users to create, curate, and consume multimedia content. Find Verbatm in the App Store!";
		branchUniversalObject.imageUrl = shareLink;
	
	    BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];
	    linkProperties.feature = @"share";
	    linkProperties.channel = @"facebook";
	
		NSLog(@"Getting link for fb for user %@ reblogging from channel %@ for post %@...", name, channelName, postId);
	    [branchUniversalObject getShortUrlWithLinkProperties:linkProperties andCallback:^(NSString *url, NSError *error) {
			NSLog(@"callback from external share called");
	        if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"got my Branch invite link to share: %@", url);
                    NSURL *link = [NSURL URLWithString:url];
                    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
                    content.contentURL = link;
                    [FBSDKShareDialog showFromViewController:self
                                                 withContent:content
                                                    delegate:nil];
                });
	           
	        } else {
	            NSLog(@"An error occured %@", error.description);
	        }
	    }];
	self.view.userInteractionEnabled = YES;
}

-(void)successfullyReblogged{
    
    UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Sucessfully Reblogged!" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {}];
    [newAlert addAction:action];
    [self presentViewController:newAlert animated:YES completion:nil];
    
    
    
//	[self.view addSubview:self.reblogSucessful];
//	[self.view bringSubviewToFront:self.reblogSucessful];
//
//	[UIView animateWithDuration:REPOST_ANIMATION_DURATION animations:^{
//		self.reblogSucessful.alpha = 0.f;
//	}completion:^(BOOL finished) {
//
//		[self.reblogSucessful removeFromSuperview];
//		self.reblogSucessful = nil;
//	}];
}


#pragma mark - Notifications (publishing, following) -



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

-(PostsQueryManager*) postsQueryManager {
	if (!_postsQueryManager) {
		_postsQueryManager = [[PostsQueryManager alloc] init];
	}
	return _postsQueryManager;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
