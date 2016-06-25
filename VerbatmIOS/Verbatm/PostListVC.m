//
//  PostListVC.m
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel_BackendObject.h"

#import "Durations.h"
#import "ExternalShare.h"
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
#import "PublishingProgressView.h"


#import "Share_BackendManager.h"
#import "SharePostView.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import <Branch/BranchUniversalObject.h>
#import <Branch/BranchLinkProperties.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>
#import "PageTypeAnalyzer.h"

#import "UserAndChannelListsTVC.h"
#import "User_BackendObject.h"
#import "UserInfoCache.h"
#import <TwitterKit/TwitterKit.h>

#import <MessageUI/MFMessageComposeViewController.h>

@interface PostListVC () <UICollectionViewDelegate, UICollectionViewDataSource,
                            SharePostViewDelegate,
                            UIScrollViewDelegate, PostCollectionViewCellDelegate, MFMessageComposeViewControllerDelegate>


@property (nonatomic) PostListType listType;
@property (nonatomic) BOOL isCurrentUserProfile;
@property (nonatomic) PFUser *listOwner;
@property (nonatomic) Channel *channelForList;
@property (nonatomic) NSDate *latestDate;

@property (nonatomic) NSMutableArray * parsePostObjects;
@property (strong, nonatomic) FeedQueryManager *feedQueryManager;
@property (strong, nonatomic) PostsQueryManager *postsQueryManager;
@property (nonatomic) BOOL performingUpdate;
@property (nonatomic) NSInteger nextIndexToPresent;
@property (nonatomic) NSInteger nextNextIndex;
@property (nonatomic) PostCollectionViewCell *currentDisplayCell;
@property (strong, nonatomic) PostCollectionViewCell *nextCellToPresent;
@property (strong, nonatomic) PostCollectionViewCell *nextNextCell;
@property (nonatomic, strong) UILabel * noContentLabel;

@property (nonatomic) LoadingIndicator *customActivityIndicator;
@property (nonatomic) SharePostView *sharePostView;
@property (nonatomic) BOOL shouldPlayVideos;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic) BOOL isLoadingMore;
@property (nonatomic) BOOL isLoadingOlder;
@property (nonatomic) BOOL footerBarIsUp;//like share bar
@property (nonatomic) BOOL fbShare;
@property (nonatomic) NSString *postImageText;
@property (nonatomic) PFObject *postToShare;
//@property (strong, nonatomic) BranchUniversalObject *branchUniversalObject;

@property (nonatomic) ExternalShare * externalShare;


@property (nonatomic) UIImageView *reblogSucessful;
@property (nonatomic) UIImageView *following;
@property (nonatomic) UIImageView *publishSuccessful;
@property (nonatomic) UIImageView *publishFailed;

@property (nonatomic) BOOL currentlyPublishing;
@property (nonatomic) BOOL exitedView;

@property (nonatomic) PublishingProgressView * publishingProgressView;


@property (nonatomic) void(^refreshPostsCompletion)(NSArray * posts);
@property (nonatomic) void(^loadMorePostsCompletion)(NSArray * posts);
@property (nonatomic) void(^loadOlderPostsCompletion)(NSArray * posts);

#define LOAD_MORE_POSTS_COUNT 3 //number of posts left to see before we start loading more content
#define POST_CELL_ID @"postCellId"
#define NUM_POVS_TO_PREPARE_EARLY 2 //we prepare this number of POVVs after the current one for viewing

#define REBLOG_IMAGE_SIZE 150.f //when we put size it means both width and height
#define REPOST_ANIMATION_DURATION 4.f

@end

@implementation PostListVC


-(void) viewDidLoad {
	[self setDateSourceAndDelegate];
	[self defineLoadPostsCompletions];
	[self registerClassForCustomCells];
	[self registerForNotifications];
	[self clearViews];
}

-(void) registerForNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(userPublishing:)
												 name:NOTIFICATION_POST_CURRENTLY_PUBLISHING
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(publishingFailed:)
												 name:NOTIFICATION_POST_FAILED_TO_PUBLISH
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(publishingSucceeded:)
												 name:NOTIFICATION_POST_PUBLISHED
											   object:nil];
}

-(void)scrollToLastElementInlist{
	NSInteger section = 0;
	NSInteger item = [self.collectionView numberOfItemsInSection:section] - 1;
	if(item > 0){
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
		[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionRight) animated:NO];
	}
}

-(void)clearPublishingView{
	if(self.publishingProgressView){
		[self.publishingProgressView removeFromSuperview];
		self.publishingProgressView = nil;
	}
}

-(void) userPublishing:(NSNotification *) notification {
	if (self.currentlyPublishing) return;
	self.currentlyPublishing = YES;
	[self.collectionView reloadData];
}

-(void) publishingSucceeded:(NSNotification *) notification {
	self.currentlyPublishing = NO;
	[self refreshPosts];

}
-(void) publishingFailed:(NSNotification *) notification {
	self.currentlyPublishing = NO;
	[self.collectionView reloadData];
}
-(void)viewWillAppear:(BOOL)animated{
	self.exitedView = NO;
}
-(void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self offScreen];
}

-(void) clearViews {
	
    @autoreleasepool {
        self.exitedView = YES;
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
        self.isLoadingOlder = NO;
        self.performingUpdate = NO;
        self.shouldPlayVideos = YES;
    }
    

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
	self.footerBarIsUp = (self.listType == listFeed || self.isCurrentUserProfile);
}

-(void) offScreen {
	self.exitedView = YES;
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
	self.noContentLabel.font = [UIFont fontWithName:REGULAR_FONT size:20.f];
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

-(void) defineLoadPostsCompletions {
	__weak typeof(self) weakSelf = self;
	self.refreshPostsCompletion = ^void(NSArray *posts) {
		if (weakSelf.exitedView) return; // Already left page
		[weakSelf.customActivityIndicator stopCustomActivityIndicator];
		if(posts.count) {
			if (weakSelf.listType == listFeed) {
				//Insert new posts into beginning
                @autoreleasepool {
                    
                    NSMutableArray *indices = [NSMutableArray array];
                    for (NSInteger i = 0; i < posts.count; i++) {
                        [indices addObject:[NSIndexPath indexPathForItem:i inSection:0]];
                    }
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0,[posts count])];
                    // Perform the updates
                    [weakSelf.collectionView performBatchUpdates:^{
                        //Insert the new data
                        [weakSelf.parsePostObjects insertObjects:posts atIndexes:indexSet];
                        //Insert the new cells
                        [weakSelf.collectionView insertItemsAtIndexPaths:indices];

                    } completion:^(BOOL finished) {
                        if(finished){
                        }
                    }];
                }
            } else {

				//Reload all posts in channel
				weakSelf.parsePostObjects = nil;
				[weakSelf.parsePostObjects addObjectsFromArray:posts];
				[weakSelf.collectionView reloadData];
				[weakSelf scrollToLastElementInlist];

			}

			[weakSelf removePresentLabel];
		} else if(!weakSelf.parsePostObjects.count){
			[weakSelf nothingToPresentHere];
		}
		weakSelf.isRefreshing = NO;
	};

	self.loadMorePostsCompletion = ^void(NSArray *posts) {
		if (!posts.count || weakSelf.exitedView) return;
		weakSelf.isLoadingMore = NO;
        @autoreleasepool {
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

	self.loadOlderPostsCompletion = ^void(NSArray *posts) {
		if (!posts.count || weakSelf.exitedView) return;
		NSMutableArray *indices = [NSMutableArray array];
		for (NSInteger i = 0; i < posts.count; i++) {
			[indices addObject:[NSIndexPath indexPathForItem:i inSection:0]];
		}
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0,[posts count])];

		[CATransaction begin];
		[CATransaction setDisableActions:YES];
		weakSelf.performingUpdate = YES;
		// Perform the updates
		[weakSelf.collectionView performBatchUpdates:^{
			//Insert the new data
			[weakSelf.parsePostObjects insertObjects:posts atIndexes:indexSet];
			//Insert the new cells
			[weakSelf.collectionView insertItemsAtIndexPaths:indices];

		} completion: ^(BOOL finished) {
			if (finished && !self.currentlyPublishing) {
				// Scroll to previously selected cell so nothing looks different
				NSArray* visiblePaths = [weakSelf.collectionView indexPathsForVisibleItems];
				NSInteger oldRow = visiblePaths && visiblePaths.count ? [(NSIndexPath*)visiblePaths[0] row] : 0;
				NSInteger newRow = oldRow + posts.count;

				if(newRow >= posts.count){
					newRow = [self.collectionView numberOfItemsInSection:0] - 1;
					oldRow = newRow -1;
				}

				NSIndexPath *selectedPostPath = [NSIndexPath indexPathForRow:newRow inSection:0];
				[weakSelf.collectionView scrollToItemAtIndexPath:selectedPostPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
				weakSelf.nextIndexToPresent = newRow + 1;
				weakSelf.nextNextIndex = newRow + 2;
				weakSelf.isLoadingOlder = NO;
				weakSelf.performingUpdate = NO;
				[CATransaction commit];
			}
		}];
	};
}

-(void) refreshPosts {
	if (!self.isRefreshing){
		self.exitedView = NO;
		self.isRefreshing = YES;
		self.isLoadingMore = NO;
		[self.customActivityIndicator startCustomActivityIndicator];
		if(self.listType == listFeed) {
			[self.feedQueryManager refreshFeedWithCompletionHandler:self.refreshPostsCompletion];
		} else if (self.listType == listChannel) {
			if (self.isCurrentUserProfile) {
				[self.postsQueryManager refreshPostsInUserChannel:self.channelForList withCompletionBlock: self.refreshPostsCompletion];
			} else {
				[self.postsQueryManager refreshPostsInChannel: self.channelForList startingAt:self.latestDate
										  withCompletionBlock: self.refreshPostsCompletion];
			}
		}
	}
}

-(void) loadMorePosts {
	if (!self.isLoadingMore){
		self.isLoadingMore = YES;
		self.exitedView = NO;
		if (self.listType == listFeed) {
			[self.feedQueryManager loadMorePostsWithCompletionHandler:self.loadMorePostsCompletion];
		} else if (self.listType == listChannel) {
			[self.postsQueryManager loadMorePostsInChannel:self.channelForList withCompletionBlock:self.loadMorePostsCompletion];
		}
	}
}

-(void) loadOlderPosts {
	if (self.isLoadingOlder) return;
	self.isLoadingOlder = YES;
	if (self.listType == listFeed) {
		return; // Not logical to load older posts in feed
	} else {
		[self.postsQueryManager loadOlderPostsInChannel:self.channelForList withCompletionBlock:self.loadOlderPostsCompletion];
	}
}

#pragma mark - DataSource -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
	 numberOfItemsInSection:(NSInteger)section {
	return self.currentlyPublishing ? self.parsePostObjects.count + 1 : self.parsePostObjects.count;
}

#pragma mark - ViewDelegate -

- (BOOL)collectionView: (UICollectionView *)collectionView
shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (self.currentlyPublishing) {
		return [self postCellAtIndexPath:indexPath];
	}
	if (self.performingUpdate && self.currentDisplayCell){
		return self.currentDisplayCell;
	}
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
	if (self.nextIndexToPresent == self.nextNextIndex) self.nextCellToPresent = self.nextNextCell;
	if (!self.nextCellToPresent || self.nextIndexToPresent != self.nextNextIndex) {
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

	//Load older posts
	if ( indexPath.row <= LOAD_MORE_POSTS_COUNT && !self.isLoadingOlder && !self.isRefreshing) {
		[self loadOlderPosts];
	}

	self.currentDisplayCell = currentCell;
	return currentCell;
}

-(PostCollectionViewCell*) postCellAtIndexPath:(NSIndexPath *)indexPath {
	if ((self.currentlyPublishing && (indexPath.row > self.parsePostObjects.count)) ||
		(!self.currentlyPublishing && indexPath.row >= self.parsePostObjects.count)){
		return nil;
	}
	PostCollectionViewCell *cell = (PostCollectionViewCell *) [self.collectionView dequeueReusableCellWithReuseIdentifier:POST_CELL_ID forIndexPath:indexPath];
	cell.cellDelegate = self;
	if(indexPath.row < self.parsePostObjects.count){
		PFObject *postObject = self.parsePostObjects[indexPath.row];
		if (cell.currentPostActivityObject != postObject) {
			[cell clearViews];
			[cell presentPostFromPCActivityObj:postObject andChannel:self.channelForList
							  withDeleteButton:self.isCurrentUserProfile andLikeShareBarUp:self.footerBarIsUp];
		}

	} else if(self.currentlyPublishing){
		[cell clearViews];
		[cell presentPublishingView:self.publishingProgressView];
	}
	return cell;
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


-(void) ShareToVerbatmSelected{
    UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Repost to Verbatm Account" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {}];
    
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                   
                                                       NSMutableArray *channels = [[NSMutableArray alloc] init];
                                                       [channels addObject:[[UserInfoCache sharedInstance] getUserChannel]];
                                                       [Post_Channel_RelationshipManager savePost:self.postToShare toChannels:channels withCompletionBlock:^{
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               [self successfullyReblogged];
                                                           });
                                                       }];
                                                   
                                                   }];
    [newAlert addAction:action1];
    [newAlert addAction:action2];
    [self presentViewController:newAlert animated:YES completion:nil];
}


-(void)reportLinkError{
    UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Oops something went wrong" message:@"Generating link - Please try again in a minute" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {}];
    [newAlert addAction:action1];
    [self presentViewController:newAlert animated:YES completion:nil];
}

-(void)ShareToTwitterSelected{
    
    NSString * url = [self.postToShare valueForKey:POST_SHARE_LINK];
    if(url){
        
        TWTRComposer *composer = [[TWTRComposer alloc] init];
        NSString * message = @"Hey - checkout this post on Verbatm! ";
        [composer setText:[message stringByAppendingString:url]];
        [composer setImage:[UIImage imageNamed:@"fabric"]];
        
        // Called from a UIViewController
        [composer showFromViewController:self completion:^(TWTRComposerResult result) {
            if (result == TWTRComposerResultCancelled) {
                NSLog(@"Tweet composition cancelled");
            }
            else {
                NSLog(@"Sending Tweet!");
            }
        }];

    }else{
        [self.externalShare storeShareLinkToPost:self.postToShare withCaption:nil withCompletionBlock:nil];
        [self reportLinkError];
    }
    
    
    
}

-(void)ShareToFacebookSelected{
    NSString * url = [self.postToShare valueForKey:POST_SHARE_LINK];
    if(url){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"got my Branch invite link to share: %@", url);
            NSURL *link = [NSURL URLWithString:url];
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            content.contentURL = link;
            [FBSDKShareDialog showFromViewController:self
                                         withContent:content
                                            delegate:nil];
        });
    }else{
        [self.externalShare storeShareLinkToPost:self.postToShare withCaption:nil withCompletionBlock:nil];
        [self reportLinkError];
    }
}


-(void)ShareToSmsSelected{
    NSString * url = [self.postToShare valueForKey:POST_SHARE_LINK];
    if(url){
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        NSString * message = @"Hey - checkout this post on Verbatm!   ";
        controller.body = [message stringByAppendingString:url];
        
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    
        
    }else{
        [self.externalShare storeShareLinkToPost:self.postToShare withCaption:nil withCompletionBlock:nil];
        
        [self reportLinkError];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)CopyLinkSelected{
    NSString * url = [self.postToShare valueForKey:POST_SHARE_LINK];
    if(url){
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = url;
        
        UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Link Copied to Clipboard" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {}];
        [newAlert addAction:action1];
        [self presentViewController:newAlert animated:YES completion:nil];
        
    }else{
        [self.externalShare storeShareLinkToPost:self.postToShare withCaption:nil withCompletionBlock:nil];
        [self reportLinkError];
    }
}




//todo: save share object
-(void) shareToShareOption:(ShareOptions) shareOption{

    
    switch (shareOption) {
        case Verbatm:
            [self ShareToVerbatmSelected];
            break;
        case TwitterShare:
            [self ShareToTwitterSelected];
            break;
        case Facebook:
            [self ShareToFacebookSelected];
            break;
        case Sms:
            [self ShareToSmsSelected];
            break;
        case CopyLink:
            [self CopyLinkSelected];
            break;
        
        default:
            break;
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

	//todo: delete?

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

-(void) showWhoLikesThePost:(PFObject *) post{
    UserAndChannelListsTVC * vc = [[UserAndChannelListsTVC alloc] initWithStyle:UITableViewStyleGrouped];
    [vc presentList:likersList forChannel:nil orPost:post];
    [self presentViewController:vc animated:YES completion:nil];
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

-(ExternalShare *)externalShare{
    if(!_externalShare)_externalShare = [[ExternalShare alloc] init];
    return _externalShare;
}
-(PublishingProgressView *)publishingProgressView{
	if(!_publishingProgressView){
		CGRect frame =  CGRectMake(0, 0,[(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout itemSize].width, [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout itemSize].height);
		_publishingProgressView = [[PublishingProgressView alloc] initWithFrame:frame];
	}
	return _publishingProgressView;
}

@end
