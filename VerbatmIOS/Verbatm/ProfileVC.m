 //
//  ProfileVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "Channel_BackendObject.h"
#import "CommentingViewController.h"
#import "CurrentUserProfileVC.h"

#import "Durations.h"

#import "Icons.h"

#import "Follow_BackendManager.h"

#import "LoadingIndicator.h"

#import "MasterNavigationVC.h"
#import <MessageUI/MFMessageComposeViewController.h>

#import "ParseBackendKeys.h"

#import "ProfileVC.h"
#import "ProfileHeaderView.h"
#import "ProfileMoreInfoView.h"
#import "PostListVC.h"
#import "PostCollectionViewCell.h"

#import "PublishingProgressManager.h"

#import "SharePostView.h"
#import "SizesAndPositions.h"
#import "SegueIDs.h"
#import "SettingsVC.h"
#import "StringsAndAppConstants.h"

#import "UIView+Effects.h"
#import "User_BackendObject.h"
#import "UserInfoCache.h"
#import "UserAndChannelListsTVC.h"
#import "UserInfoCache.h"
#import "UtilityFunctions.h"
#import <PromiseKit/PromiseKit.h>

#import "VerbatmNavigationController.h"

@interface ProfileVC() <ProfileHeaderViewDelegate, ProfileMoreInfoViewDelegate,
UIScrollViewDelegate, PostListVCProtocol,
UIGestureRecognizerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic) BOOL isCurrentUserProfile;
@property (nonatomic) BOOL isBlocked;
@property (nonatomic) UIButton * postPrompt;

@property (nonatomic) BOOL currentlyCreatingNewChannel;

@property (strong, nonatomic) PostListVC * postListVC;
@property (nonatomic) UIImageView *noPostsView;

@property (nonatomic) ProfileMoreInfoView *moreInfoView;
@property (nonatomic) BOOL moreInfoViewOnScreen;
@property (nonatomic) CGRect moreInfoViewOnScreenFrame;
@property (nonatomic) CGRect moreInfoViewOffScreenFrame;

@property (nonatomic) SharePostView * sharePOVView;

@property (nonatomic) BOOL inFullScreenMode;

#pragma mark Publishing

@property (nonatomic, strong) UIView* publishingProgressView;
@property (nonatomic, strong) NSProgress* publishingProgress;
@property (nonatomic, strong) UIProgressView* progressBar;

@property (nonatomic) CGRect  postListSmallFrame;
@property (nonatomic) CGRect  postListLargeFrame;
@property (nonatomic) CGSize  cellSmallFrameSize;


#define CELL_SPACING_SMALL 5.f
#define CELL_SPACING_LARGE 0.3
#define HEADER_SIZE (self.view.frame.size.height * 3.f/7.f)

@end

@implementation ProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
	self.isBlocked = NO;
	self.isCurrentUserProfile = [self isKindOfClass:[CurrentUserProfileVC class]];
	self.moreInfoViewOnScreen = NO;
	self.automaticallyAdjustsScrollViewInsets = NO;
	self.view.backgroundColor = [UIColor blackColor];
	[self buildHeaderView];
	[self loadContentToPostList];
	[self formatNavigationItem];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.navigationController) {
		[(MasterNavigationVC*)self.tabBarController showTabBar:!self.inFullScreenMode];
		[self.navigationController setNavigationBarHidden: self.inFullScreenMode];
		[(VerbatmNavigationController*)self.navigationController setNavigationBarBackgroundClear];
		[(VerbatmNavigationController*)self.navigationController setNavigationBarShadowColor:[UIColor clearColor]];
		[(VerbatmNavigationController*)self.navigationController setNavigationBarTextColor:[UIColor whiteColor]];
	}
	// In feed list
	else {
		[self.verbatmTabBarController showTabBar:!self.inFullScreenMode];
		[self.verbatmNavigationController setNavigationBarHidden:self.inFullScreenMode];
		[self.verbatmNavigationController setNavigationBarBackgroundClear];
		[(VerbatmNavigationController*)self.navigationController setNavigationBarShadowColor:[UIColor clearColor]];
		[self.verbatmNavigationController setNavigationBarTextColor:[UIColor whiteColor]];
	}
    
}

-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
   
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	[self setNeedsStatusBarAppearanceUpdate];
    if(self.postListVC){
        [self.postListVC viewDidAppear:YES];
    }
}

-(BOOL) prefersStatusBarHidden {
	return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

-(void) formatNavigationItem {
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style
																			target:nil action:nil];
}

-(void)updateDateOfLastPostSeen {
	if(!self.isCurrentUserProfile && self.profileInFeed && [self.channel dateOfMostRecentChannelPost]){
		NSDate * finalDate = [self.postListVC creationDateOfLastPostObjectInPostList];
		if(finalDate){
			[self.channel.followObject setObject:finalDate forKey:FOLLOW_LATEST_POST_DATE];
			[self.channel.followObject saveInBackground];
			if([finalDate compare:[self.channel dateOfMostRecentChannelPost]] != NSOrderedSame){
				[self.channel resetLatestPostInfo];
			}
		}
	}
}

-(void)loadContentToPostList {
	if (!self.channel.followObject) {
		PFObject *followObject = [[UserInfoCache sharedInstance] userFollowsChannel:self.channel];
		self.channel.followObject = followObject;
	}

	if(!self.postListVC.isInitiated){
		NSDate *startingDate = self.channel.followObject ? self.channel.followObject[FOLLOW_LATEST_POST_DATE] : nil;
		[self.postListVC display:self.channel withListOwner: self.ownerOfProfile
			isCurrentUserProfile:self.isCurrentUserProfile andStartingDate: startingDate];
	} else {
		[self.postListVC refreshPosts];
	}
	[self.postListVC startMonitoringPublishing];
}

-(void)refreshProfile {
	if(self.postListVC)[self.postListVC refreshPosts];
	[self buildHeaderView];
}

-(void)clearOurViews {
	if(self.postListVC)[self.postListVC offScreen];
	if(self.postListVC)[self.postListVC clearViews];
	[self.profileHeaderView removeFromSuperview];
	self.profileHeaderView = nil;
}

-(void)presentUserList:(ListType) listType{
	UserAndChannelListsTVC *userList = [[UserAndChannelListsTVC alloc] initWithStyle:UITableViewStyleGrouped];
	[userList presentList:listType forChannel:self.channel orPost:nil];
	if (self.navigationController) {
		[self.navigationController pushViewController:userList animated:YES];
	} else {
		[self.verbatmNavigationController pushViewController:userList animated:YES];
	}
}

-(void)buildHeaderView {
	if(self.profileHeaderView){
		[self.profileHeaderView removeFromSuperview];
		self.profileHeaderView = nil;
	}
    
	CGRect frame = CGRectMake(0.f, 0.f, self.view.frame.size.width, HEADER_SIZE);
	self.profileHeaderView = [[ProfileHeaderView alloc] initWithFrame:frame andChannel:self.channel
												 inCurrentUserProfile: self.isCurrentUserProfile];
	self.profileHeaderView.delegate = self;
	[self.view addSubview: self.profileHeaderView];
	[self.view sendSubviewToBack:self.profileHeaderView];
}

-(void) headerViewTapped {
	//If the header is tapped anywhere while the more info view is on screen, remove it
	if (self.moreInfoViewOnScreen) {
		[self moreInfoButtonTapped];
	}
}

-(void) moreInfoButtonTapped {
	[self.view bringSubviewToFront: self.moreInfoView];
	[self.view bringSubviewToFront: self.profileHeaderView];
	self.moreInfoViewOnScreen = !self.moreInfoViewOnScreen;
	[UIView animateWithDuration:0.5f animations:^{
		if (self.moreInfoViewOnScreen) {
			self.moreInfoView.frame = self.moreInfoViewOnScreenFrame;
		} else {
			self.moreInfoView.frame = self.moreInfoViewOffScreenFrame;
		}
	} completion:^(BOOL finished) {
	}];
}

-(void) followersButtonPressed {
	[self showFollowers];
}

-(void) followingButtonPressed {
	[self showChannelsFollowing];
}

-(void) followChannel:(BOOL)follow {
	if (follow) {
		[Follow_BackendManager currentUserFollowChannel: self.channel];
	} else {
		[Follow_BackendManager currentUserStopFollowingChannel: self.channel];
	}
}

-(void) blockButtonPressed {
	if (self.isBlocked) {
		[self askIfShouldBlock: NO];
	} else {
		[User_BackendObject userIsBlockedByCurrentUser:self.channel.channelCreator withCompletionBlock:^(BOOL blocked) {
			self.isBlocked = blocked;
			[self askIfShouldBlock: !blocked];
		}];
	}
}

-(void) askIfShouldBlock:(BOOL) shouldBlock {
	NSString * titleText;

	if(shouldBlock) {
		titleText = @"Block User";
	} else {
		titleText = @"Unblock User";
	}

	UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
																   message:nil
															preferredStyle:UIAlertControllerStyleActionSheet];

	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction * action) {}];
	UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:titleText style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		if(shouldBlock){
			[User_BackendObject blockUser:self.ownerOfProfile];
			[self alertUserBlocked:YES];

		} else {
			[User_BackendObject unblockUser:self.ownerOfProfile];
			[self alertUserBlocked:NO];
		}
	}];

	[alert addAction: cancelAction];
	[alert addAction: confirmAction];
	[self presentViewController:alert animated:YES completion:nil];
}

-(void) alertUserBlocked:(BOOL) blocked {
	NSString *title = blocked ? @"User blocked" : @"User unblocked";
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
																   message:nil
															preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction * action) {}];

	[alert addAction: cancelAction];
	[self presentViewController:alert animated:YES completion:nil];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

-(void)exitCurrentPostView{
	[self createNewPostViewFromCellIndexPath:nil];
}

#pragma mark - Post list vc delegate -

-(void)removePostViewSelected{
	[self exitCurrentPostView];
}

-(void)showWhoCommentedOnPost:(PFObject *) post{
	CommentingViewController *commentListVC = [[CommentingViewController alloc] initForPost:post];
	if (self.navigationController) {
		[self.navigationController pushViewController:commentListVC animated:YES];
	} else {
		[self.verbatmNavigationController pushViewController:commentListVC animated:YES];
	}
}

-(void) showWhoLikedPost:(PFObject *)post {
	UserAndChannelListsTVC *likersListVC = [[UserAndChannelListsTVC alloc] initWithStyle:UITableViewStyleGrouped];
	[likersListVC presentList:LikersList forChannel:nil orPost:post];
	if (self.navigationController) {
		[self.navigationController pushViewController:likersListVC animated:YES];
	} else {
		[self.verbatmNavigationController pushViewController:likersListVC animated:YES];
	}
}

// Something in profile was reblogged so contains a header allowing user to navigate
// to a different profile
-(void)channelSelected:(Channel *) channel{
	if([[[channel channelCreator] objectId] isEqualToString:[[self.channel channelCreator] objectId]]){
		//if the channel belongs to this profile then simply remove the large postlist view
		[self exitCurrentPostView];
	} else {
		//todo: push segue
		ProfileVC *  userProfile = [[ProfileVC alloc] init];
		BOOL isCurrentUserChannel = [[channel.channelCreator objectId] isEqualToString:[[PFUser currentUser] objectId]];
		userProfile.isCurrentUserProfile = isCurrentUserChannel;
		userProfile.ownerOfProfile = channel.channelCreator;
		userProfile.channel = channel;
		if (self.navigationController) {
			[self.navigationController pushViewController:userProfile animated:YES];
		} else {
			userProfile.verbatmNavigationController = self.verbatmNavigationController;
			userProfile.verbatmTabBarController = self.verbatmTabBarController;
			[self.verbatmNavigationController pushViewController:userProfile animated:YES];
		}
	}
}

-(UICollectionViewFlowLayout * )getFlowLayout{
	UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
	if(self.inFullScreenMode){
		[self.view bringSubviewToFront:self.postListVC.view];
		flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		[flowLayout setMinimumInteritemSpacing:CELL_SPACING_LARGE];
		[flowLayout setMinimumLineSpacing:0.0f];
		[flowLayout setItemSize:self.postListLargeFrame.size];
	} else {
		flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		[flowLayout setMinimumInteritemSpacing:CELL_SPACING_SMALL];
		[flowLayout setMinimumLineSpacing:CELL_SPACING_SMALL];
		[flowLayout setItemSize:self.cellSmallFrameSize];
	}

	return flowLayout;
}

-(void)presentViewPostView:(PostListVC *) postList inSmallMode:(BOOL) inSmallMode
				shouldPage:(BOOL) shouldPage
			  fromCellPath:(NSIndexPath *) cellPath{

	[self.view addSubview:postList.view];
	[self.view bringSubviewToFront:postList.view];
	if(cellPath != nil) {
		if(cellPath.row < self.postListVC.parsePostActivityObjects.count) {
			[postList.collectionView scrollToItemAtIndexPath:cellPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
		}
	}

	if (self.navigationController) {
        
		[self.navigationController setNavigationBarHidden: !inSmallMode];
		[(MasterNavigationVC*)self.tabBarController showTabBar: inSmallMode];
        
	} else {
        
        //in feed
		[self.verbatmNavigationController setNavigationBarHidden: !inSmallMode];
		[self.verbatmTabBarController showTabBar: inSmallMode];
        [self.delegate lockFeedScrollView:!inSmallMode];
	}
    
	[self.postListVC.view removeFromSuperview];
	[self.postListVC clearViews];
	self.postListVC = nil;
	self.postListVC = postList;
}

// Switches between large and small post list
-(void)cellSelectedAtPostIndex:(NSIndexPath *) cellPath{
	[self createNewPostViewFromCellIndexPath:cellPath];
}

-(void)createNewPostViewFromCellIndexPath:(NSIndexPath *) cellPath{

	self.inFullScreenMode = !self.inFullScreenMode;
	NSArray *visibleCells = [self.postListVC.collectionView visibleCells];
	if (cellPath == nil && visibleCells.count) {
		PostCollectionViewCell* cell = (PostCollectionViewCell*)[visibleCells firstObject];
		cellPath = [self.postListVC.collectionView indexPathForCell:cell];
	}

	PostListVC * newVC = [[PostListVC alloc] initWithCollectionViewLayout:[self getFlowLayout]];
	newVC.postListDelegate = self;
	newVC.inSmallMode = !self.inFullScreenMode;
	newVC.collectionView.pagingEnabled = self.inFullScreenMode;
	[newVC.view setFrame: (self.inFullScreenMode) ? self.postListLargeFrame : self.postListSmallFrame];

	// If clicking out of full screen update cursor (latest date seen)
	if (self.channel.followObject && newVC.inSmallMode && self.postListVC) {
		NSDate *latestDate = self.postListVC.latestPostSeen;
		NSTimeInterval timeSince = [latestDate timeIntervalSinceDate:self.channel.followObject[FOLLOW_LATEST_POST_DATE]];
		if (latestDate && timeSince > 0) {
			[self.channel.followObject setObject:latestDate forKey:FOLLOW_LATEST_POST_DATE];
			[self.channel.followObject saveInBackground];
		}
	}

	NSDate *startingDate = self.channel.followObject ? self.channel.followObject[FOLLOW_LATEST_POST_DATE] : nil;
	if(self.postListVC.parsePostActivityObjects) {
		newVC.postsQueryManager = self.postListVC.postsQueryManager;
		newVC.currentlyPublishing = self.postListVC.currentlyPublishing;
		[newVC display:self.channel withListOwner:self.ownerOfProfile isCurrentUserProfile:self.isCurrentUserProfile
	   andStartingDate:startingDate withOldParseObjects:self.postListVC.parsePostActivityObjects];
	}
	[self presentViewPostView:newVC inSmallMode:!self.inFullScreenMode shouldPage:self.inFullScreenMode fromCellPath:cellPath];
}

#pragma mark - Profile Nav Bar Delegate Methods -


-(void) editDoneButtonClickedWithoutName {
	UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"You've gotta title your blog!" message:nil
																preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
												   handler:^(UIAlertAction * action) {}];
	[newAlert addAction:action];
	[self presentViewController:newAlert animated:YES completion:nil];
}

-(void)showChannelsFollowing{
	[self presentUserList: FollowingList];
}

-(void)showFollowers{
	[self presentUserList: FollowersList];
}

-(void)createPostPromptSelected{
	if([self.delegate respondsToSelector:@selector(userCreateFirstPost)]){
		if(self.inFullScreenMode)[self createNewPostViewFromCellIndexPath:nil];
		[self.delegate userCreateFirstPost];
	}
}

-(void)postsFound{
	if(!self.isCurrentUserProfile) {
		[self.noPostsView removeFromSuperview];
        [self updateDateOfLastPostSeen];
	}
}

-(void)noPostFound {
	if(!self.isCurrentUserProfile){
		[self.view addSubview: self.noPostsView];
	}
	if (self.inFullScreenMode) {
		[self exitCurrentPostView];
	}
}

-(void) shareToSmsSelectedToUrl:(NSString *) url{
	if(url){
		MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
		NSString * message = @"Hey - checkout this post on Verbatm!";
		controller.body = [message stringByAppendingString:url];
		controller.messageComposeDelegate = self;
		[self presentViewController:controller animated:YES completion:nil];
	}
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
	[controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Lazy Instantiation -

-(ProfileMoreInfoView*) moreInfoView {
	if (!_moreInfoView) {
		CGFloat yPos = HEADER_SIZE;
		CGFloat height = self.view.frame.size.height - yPos;
		self.moreInfoViewOffScreenFrame = CGRectMake(0.f, yPos - height, self.view.frame.size.width, height);
		self.moreInfoViewOnScreenFrame = CGRectMake(0.f, yPos, self.view.frame.size.width, height);
		_moreInfoView = [[ProfileMoreInfoView alloc] initWithFrame:self.moreInfoViewOnScreenFrame andChannel:self.channel
											  isCurrentUserProfile:self.isCurrentUserProfile];
		_moreInfoView.delegate = self;
		_moreInfoView.frame = self.moreInfoViewOffScreenFrame;
		[self.view addSubview: _moreInfoView];
	}
	return _moreInfoView;
}

-(UIView*) publishingProgressView {
	if (!_publishingProgressView) {
		_publishingProgressView = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.profileHeaderView.frame.size.height,
																		   self.view.frame.size.width, 20.f)];
		[_publishingProgressView setBackgroundColor:[UIColor blackColor]];
		self.progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
		[self.progressBar setTrackTintColor:[UIColor grayColor]];
		[self.progressBar setFrame:CGRectMake(15.f, 15.f, self.view.frame.size.width - 30.f, self.progressBar.frame.size.height)];
		[self.progressBar setTransform:CGAffineTransformMakeScale(1.0, 3.0)];
		[self.progressBar.layer setCornerRadius:10.f];
		if ([self.progressBar respondsToSelector:@selector(setObservedProgress:)]) {
			[self.progressBar setObservedProgress: self.publishingProgress];
		} else {
			[self.publishingProgress addObserver:self forKeyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew context:nil];
		}
		[_publishingProgressView addSubview: self.progressBar];
	}
	return _publishingProgressView;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change
					   context:(void *)context {
	if (object == self.publishingProgress && [keyPath isEqualToString:@"completedUnitCount"] ) {
		[self.progressBar setProgress:self.publishingProgress.fractionCompleted animated:YES];
	}
}

-(PostListVC *) postListVC{
	if(!_postListVC) {
		self.postListLargeFrame = self.view.bounds;
		self.postListSmallFrame = CGRectMake(0.f, HEADER_SIZE,
											 self.view.frame.size.width, self.view.frame.size.height -
											 HEADER_SIZE - TAB_BAR_HEIGHT);
		CGFloat postHeight = self.postListSmallFrame.size.height;
		CGFloat postWidth = (self.view.frame.size.width / self.view.frame.size.height ) * postHeight;
		self.cellSmallFrameSize = CGSizeMake(postWidth, postHeight);
		_postListVC = [[PostListVC alloc] initWithCollectionViewLayout:[self getFlowLayout]];
		_postListVC.postListDelegate = self;
		_postListVC.inSmallMode = YES;
		[_postListVC.view setFrame:self.postListSmallFrame];
		[self.view addSubview:_postListVC.view];
	}

	return _postListVC;
}

-(UIImageView*) noPostsView {
	if (!_noPostsView) {
		CGRect frame = CGRectMake(self.postListSmallFrame.origin.x + 5.f,
								  self.postListSmallFrame.origin.y + 5.f,
								  self.postListSmallFrame.size.width - 10.f,
								  self.postListSmallFrame.size.height - 10.f);
		_noPostsView = [[UIImageView alloc] initWithFrame: frame];
		_noPostsView.contentMode = UIViewContentModeScaleAspectFit;
		_noPostsView.image = [UIImage imageNamed: PROFILE_UNDER_CONSTRUCTION_ICON];
	}
	return _noPostsView;
}

-(void)dealloc {
}

@end
