//
//  ProfileVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "CreateNewChannelView.h"
#import "Channel_BackendObject.h"

#import "Durations.h"

#import "Icons.h"
#import "Intro_Instruction_Notification_View.h"

#import "Follow_BackendManager.h"
#import "FollowingView.h"

#import "GMImagePickerController.h"

#import "LoadingIndicator.h"

#import "ParseBackendKeys.h"

#import "ProfileVC.h"
#import "ProfileHeaderView.h"
#import "PostListVC.h"

#import "PublishingProgressManager.h"

#import "SharePostView.h"
#import "SizesAndPositions.h"
#import "SegueIDs.h"
#import "SettingsVC.h"
#import "StringsAndAppConstants.h"

#import "UIView+Effects.h"
#import "User_BackendObject.h"
#import "UserInfoCache.h"
#import "UserSetupParameters.h"
#import "UserAndChannelListsTVC.h"
#import <PromiseKit/PromiseKit.h>

@interface ProfileVC() <ProfileHeaderViewDelegate, Intro_Notification_Delegate,
UIScrollViewDelegate, CreateNewChannelViewProtocol,
PublishingProgressProtocol, PostListVCProtocol,
UIGestureRecognizerDelegate, GMImagePickerControllerDelegate>

@property (nonatomic) UIButton * postPrompt;

@property (nonatomic) BOOL currentlyCreatingNewChannel;

@property (strong, nonatomic) PostListVC * postListVC;
@property (nonatomic) Intro_Instruction_Notification_View * introInstruction;

@property (nonatomic, strong) ProfileHeaderView *profileHeaderView;
@property (nonatomic) BOOL headerViewOnScreen;

@property (strong, nonatomic) CreateNewChannelView * createNewChannelView;
@property (nonatomic) UIView * darkScreenCover;
@property (nonatomic) SharePostView * sharePOVView;

@property (nonatomic) BOOL inFullScreenMode;

#pragma mark Publishing

@property (nonatomic, strong) UIView* publishingProgressView;
@property (nonatomic, strong) NSProgress* publishingProgress;
@property (nonatomic, strong) UIProgressView* progressBar;


@property (nonatomic) CGRect  postListSmallFrame;
@property (nonatomic) CGRect  postListLargeFrame;
@property (nonatomic) CGSize  cellSmallFrameSize;

@property (nonatomic) PHImageManager* imageManager;

#define CELL_SPACING_SMALL 1.f
#define CELL_SPACING_LARGE 0.3
@end

@implementation ProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
	self.automaticallyAdjustsScrollViewInsets = NO;
	[self setNeedsStatusBarAppearanceUpdate];
	self.view.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1.f];
	[self createHeader];
	[self checkIntroNotification];
}

-(void)loadContentToPostList{
	if(!self.postListVC.isInitiated){
		[self.postListVC display:self.channel asPostListType:listChannel withListOwner: self.ownerOfProfile isCurrentUserProfile:self.isCurrentUserProfile andStartingDate:self.startingDate];
	}else{
		[self.postListVC refreshPosts];
	}
	[self.postListVC startMonitoringPublishing];
}

//to be used sparingly -- has the postlist refresh content
//todo: wtf ^
-(void)refreshProfile {
	if(self.postListVC)[self.postListVC refreshPosts];
	[self createHeader];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self loadContentToPostList];
}

-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self clearOurViews];
}

-(void)clearOurViews {
	if(self.postListVC)[self.postListVC offScreen];
	if(self.postListVC)[self.postListVC clearViews];

}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
}

-(void)presentUserList:(ListLoadType) listType{
	UserAndChannelListsTVC * vc = [[UserAndChannelListsTVC alloc] initWithStyle:UITableViewStyleGrouped];
	[vc presentList:listType forChannel:self.channel orPost:nil];
	[self presentViewController:vc animated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

-(void)buildHeaderView {
	if(self.profileHeaderView){
		[self.profileHeaderView removeFromSuperview];
		self.headerViewOnScreen = NO;
		self.profileHeaderView = nil;
	}

	CGRect frame = self.view.bounds;
	PFUser* user = self.isCurrentUserProfile ? nil : self.channel.channelCreator;

	self.profileHeaderView = [[ProfileHeaderView alloc] initWithFrame:frame andUser:user                                                                   andChannel:self.channel inProfileTab:self.isProfileTab inFeed:self.profileInFeed];

	self.profileHeaderView.delegate = self;
	[self.view addSubview: self.profileHeaderView];
	[self.view sendSubviewToBack:self.profileHeaderView];
	self.headerViewOnScreen = YES;
}

-(void) createHeader {
    if(self.channel.channelsUserFollowing == nil || !self.channel.channelsUserFollowing.count){
        [self.channel getFollowersAndFollowingWithCompletionBlock:^{
        }];
    }
    [self buildHeaderView];
}

#pragma mark - Profile Photo -

-(void)presentGalleryToSelectImage {
	GMImagePickerController *picker = [[GMImagePickerController alloc] init];
	picker.delegate = self;
	//Display or not the selection info Toolbar:
	picker.displaySelectionInfoToolbar = YES;

	//Display or not the number of assets in each album:
	picker.displayAlbumsNumberOfAssets = YES;

	//Customize the picker title and prompt (helper message over the title)
	picker.title = GALLERY_PICKER_TITLE;
	picker.customNavigationBarPrompt = GALLERY_CUSTOM_MESSAGE;

	[picker setSelectOnlyOneImage:YES];

	//Customize the number of cols depending on orientation and the inter-item spacing
	picker.colsInPortrait = 3;
	picker.colsInLandscape = 5;
	picker.minimumInteritemSpacing = 2.0;
	[self presentViewController:picker animated:YES completion:nil];
}

-(void)assetsPickerController:(GMImagePickerController *)picker didFinishPickingAssets:(NSArray *)assetArray{
	for(PHAsset * asset in assetArray) {
		if(asset.mediaType==PHAssetMediaTypeImage) {
			@autoreleasepool {
				[self getImageFromAsset:asset];
			}
		}
	}
}

- (void)assetsPickerControllerDidCancel:(GMImagePickerController *)picker {
	[picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
	}];
}

-(void) getImageFromAsset: (PHAsset *) asset {
	PHImageRequestOptions *options = [PHImageRequestOptions new];
	options.synchronous = YES;
	[self.imageManager requestImageForAsset:asset targetSize:self.view.frame.size contentMode:PHImageContentModeAspectFill
									options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
										// RESULT HANDLER CODE NOT HANDLED ON MAIN THREAD so must be careful about UIView calls if not using dispatch_async
										dispatch_async(dispatch_get_main_queue(), ^{
											[self.profileHeaderView setCoverPhotoImage:image];
										});
									}];
}


-(void)checkEditProfileNotification{
        if(![[UserSetupParameters sharedInstance] checkEditButtonNotification] &&
           self.isCurrentUserProfile) {
            self.introInstruction = [[Intro_Instruction_Notification_View alloc] initWithCenter:self.view.center andType:Profile];
            self.introInstruction.custom_delegate = self;
            [self.view addSubview:self.introInstruction];
            [self.view bringSubviewToFront:self.introInstruction];
        }
}

-(void)checkIntroNotification{
	if(![[UserSetupParameters sharedInstance] checkAndSetProfileInstructionShown] &&
	   self.isCurrentUserProfile) {
		self.introInstruction = [[Intro_Instruction_Notification_View alloc] initWithCenter:self.view.center andType:Profile];
		self.introInstruction.custom_delegate = self;
		[self.view addSubview:self.introInstruction];
		[self.view bringSubviewToFront:self.introInstruction];
	}
}

-(void) notificationDoneAnimatingOut {
	if(self.introInstruction){
		[self.introInstruction removeFromSuperview];
		self.introInstruction = nil;
	}
}

-(void)addClearScreenGesture{
	UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearScreen:)];
	singleTap.numberOfTapsRequired = 1;
	singleTap.delegate = self;
	[self.postListVC.view addGestureRecognizer:singleTap];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return  (![touch.view isKindOfClass:[Intro_Instruction_Notification_View class]]);
}

#pragma mark - Post list vc delegate -

// Something in profile was reblogged so contains a header allowing user to navigate
// to a different profile
-(void)channelSelected:(Channel *) channel{
	ProfileVC *  userProfile = [[ProfileVC alloc] init];
	userProfile.isCurrentUserProfile = NO;
	userProfile.isProfileTab = NO;
	userProfile.ownerOfProfile = channel.channelCreator;
	userProfile.channel = channel;
	[self presentViewController:userProfile animated:YES completion:^{
	}];
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

-(void)presentViewPostView:(PostListVC *) postList inSmallMode:(BOOL) inSmallMode shouldPage:(BOOL) shouldPage fromCellPath:(NSIndexPath *) cellPath{
	if(inSmallMode)[self.postListVC.view removeFromSuperview];

	[UIView animateWithDuration:REVEAL_NEW_MEDIA_TILE_ANIMATION_DURATION animations:^{
		[self.view addSubview:postList.view];
		[self.view bringSubviewToFront:postList.view];
		if(cellPath.row < self.postListVC.parsePostObjects.count)[postList.collectionView scrollToItemAtIndexPath:cellPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
		[self.delegate showTabBar:!shouldPage];
	}completion:^(BOOL finished) {
		if(finished){
			if(!inSmallMode)[self.postListVC.view removeFromSuperview];
			@autoreleasepool {
				[self.postListVC clearViews];
				self.postListVC = nil;
			}
			self.postListVC = postList;
		}
	}];
}

-(void)cellSelectedAtPostIndex:(NSIndexPath *) cellPath{
	self.inFullScreenMode = !self.inFullScreenMode;
	BOOL shouldPage = self.inFullScreenMode;
	BOOL inSmallMode = !self.inFullScreenMode;


	PostListVC * newVC = [[PostListVC alloc] initWithCollectionViewLayout:[self getFlowLayout]];
	newVC.postListDelegate = self;
	newVC.inSmallMode = inSmallMode;
	newVC.collectionView.pagingEnabled = shouldPage;
	[newVC.view setFrame: (inSmallMode) ? self.postListSmallFrame : self.postListLargeFrame];

	if(self.postListVC.parsePostObjects && self.postListVC.parsePostObjects.count){
		newVC.postsQueryManager = self.postListVC.postsQueryManager;
		newVC.currentlyPublishing = self.postListVC.currentlyPublishing;
		[newVC loadPostListFromOlPostListWithDisplay:self.channel postListType:listChannel listOwner:self.ownerOfProfile isCurrentUserProfile:self.isCurrentUserProfile startingDate:self.startingDate andParseObjects:self.postListVC.parsePostObjects];
	}

	[self presentViewPostView:newVC inSmallMode:inSmallMode shouldPage:shouldPage fromCellPath:cellPath];

}

#pragma mark - Profile Nav Bar Delegate Methods -

-(void) settingsButtonClicked {
	[self performSegueWithIdentifier:SETTINGS_PAGE_MODAL_SEGUE sender:self];
}

-(void) editDoneButtonClickedWithoutName {
	UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"You've gotta title your blog!" message:nil
																preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
												   handler:^(UIAlertAction * action) {}];
	[newAlert addAction:action];
	[self presentViewController:newAlert animated:YES completion:nil];
}

-(void)followersButtonSelected{
	[self showMyFollowers];
}

-(void)followingButtonSelected{
	[self showWhoIAmFollowing];
}

-(void)showWhoIAmFollowing{
	[self presentUserList:followingList];
}

-(void)showMyFollowers{
	[self presentUserList:followersList];
}

//ProfileNavBarDelegate protocol
-(void) createNewChannel {
	if(!self.createNewChannelView){
		[self darkenScreen];

		CGFloat xOffset = (self.view.frame.size.width - CHANNEL_CREATION_VIEW_WIDTH)/2.f;
		CGRect newChannelViewFrame = CGRectMake(xOffset, CHANNEL_CREATION_VIEW_Y_OFFSET,
												CHANNEL_CREATION_VIEW_WIDTH, CHANNEL_CREATION_VIEW_HEIGHT);
		self.createNewChannelView = [[CreateNewChannelView alloc] initWithFrame:newChannelViewFrame];
		self.createNewChannelView.delegate = self;
		[self.view addSubview:self.createNewChannelView];
		[self.view bringSubviewToFront:self.createNewChannelView];
	}
}

-(void)darkenScreen{
	if(!self.darkScreenCover){
		self.darkScreenCover = [[UIView alloc] initWithFrame:self.view.bounds];
		self.darkScreenCover.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.5];
		[self.view addSubview:self.darkScreenCover];
	}
}

-(void) removeScreenDarkener {
	if(self.darkScreenCover) {
		[self.darkScreenCover removeFromSuperview];
		self.darkScreenCover = nil;
	}
}

-(void) cancelCreation {
	[self clearChannelCreationView];
	[self presentHeadAndFooter:YES];
}

-(void) createChannelWithName:(NSString *) channelName {
	//save the channel name and create it in the backend
	//upate the scrollview to present a new channel
	if(!self.currentlyCreatingNewChannel){
		self.currentlyCreatingNewChannel = YES;
		[Channel_BackendObject createChannelWithName:channelName andCompletionBlock:^(PFObject *channelObject) {
		}];
	}
}

-(void) clearChannelCreationView{
	if(self.createNewChannelView){
		[self removeScreenDarkener];
		[self.createNewChannelView removeFromSuperview];
		self.createNewChannelView = nil;
	}
}


-(void)createPromptToPost{
	self.postPrompt =  [[UIButton alloc] init];
	[self.postPrompt setBackgroundImage:[UIImage imageNamed:CREATE_POST_PROMPT_ICON] forState:UIControlStateNormal];
	[self.view addSubview:self.postPrompt];
	[self.postPrompt addTarget:self action:@selector(createFirstPost) forControlEvents:UIControlEventTouchDown];
	CGFloat frameHeight = self.postListVC.view.frame.size.height -2.f;
	CGFloat frameWidth = 3.f +  (self.view.frame.size.width/ self.view.frame.size.height) * frameHeight;
	self.postPrompt.frame = CGRectMake(self.postListVC.view.frame.origin.x, self.postListVC.view.frame.origin.y, frameWidth, frameHeight);
	self.postListVC.view.hidden = YES;
}

-(void)createFirstPost{
	if([self.delegate respondsToSelector:@selector(userCreateFirstPost)]){
		[self.delegate userCreateFirstPost];
	}
}
-(void)postsFound{
	[self removePromptToPost];
}
-(void)removePromptToPost{
	if(self.isCurrentUserProfile){
		if(self.postPrompt)[self.postPrompt removeFromSuperview];
		self.postPrompt = nil;
		if(self.postListVC.view.isHidden)self.postListVC.view.hidden = NO;
	}
}

-(void)noPostFound{
	if(self.isCurrentUserProfile)[self createPromptToPost];
}

#pragma mark -Navigate profile-
//the current user has selected the back button
-(void)exitCurrentProfile {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:^{
	}];
}

-(void)blockCurrentUserShouldBlock:(BOOL) shouldBlock{
	NSString * titleText;
	NSString * messageText;

	if(shouldBlock) {
		titleText = @"Block User";
		messageText = @"Are you sure?";
	} else {
		titleText = @"Unblock User";
		messageText = @"Are you sure?";
	}

	UIAlertController* alert = [UIAlertController alertControllerWithTitle:titleText
																   message:messageText
															preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction * action) {}];
	UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"Yes, I'm sure." style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		if(shouldBlock){
			[User_BackendObject blockUser:self.ownerOfProfile];
			//todo: update blocked
			//			[self.profileHeaderView updateUserIsBlocked:YES];
			[self alertUserBlocked:YES];

		} else {
			[User_BackendObject unblockUser:self.ownerOfProfile];
			//todo: update unblocked
			//			[self.profileHeaderView updateUserIsBlocked:NO];
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

#pragma mark - POSTListVC Protocol -

-(void)hideNavBarIfPresent{
	[self presentHeadAndFooter:NO];
}

-(void) presentHeadAndFooter:(BOOL) shouldShow {
	if(shouldShow && !self.headerViewOnScreen) {
		self.headerViewOnScreen = YES;
		CGRect onScreenFrame = CGRectOffset(self.profileHeaderView.frame, 0.f, self.profileHeaderView.frame.size.height);
		[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
			[self.profileHeaderView setFrame: onScreenFrame];
		}];
		[self.delegate showTabBar:YES];
		if(self.isProfileTab) [self.postListVC footerShowing:YES];

	} else if (!shouldShow && self.headerViewOnScreen) {
		self.headerViewOnScreen = NO;
		CGRect offScreenFrame = CGRectOffset(self.profileHeaderView.frame, 0.f, -self.profileHeaderView.frame.size.height);
		[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
			[self.profileHeaderView setFrame: offScreenFrame];
		}];

		[self.delegate showTabBar:NO];
		if(self.isCurrentUserProfile) [self.postListVC footerShowing:NO];
	}
}

-(void)clearScreen:(UIGestureRecognizer *) tapGesture {
	if (self.headerViewOnScreen) {
		[self presentHeadAndFooter:NO];
	} else {
		[self presentHeadAndFooter:YES];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	// Make sure your segue name in storyboard is the same as this line
	if ([[segue identifier] isEqualToString:SETTINGS_PAGE_MODAL_SEGUE]){
		// Get reference to the destination view controller
		SettingsVC * vc = [segue destinationViewController];

		//set the username of the currently logged in user
		vc.userName  = [[PFUser currentUser] valueForKey:VERBATM_USER_NAME_KEY];
	}
}

#pragma mark Publishing Progress Manager Delegate methods

-(void) publishingComplete {
	NSLog(@"Publishing Complete!");
	[self.publishingProgressView removeFromSuperview];
	self.publishingProgressView = nil;
	[self.postListVC loadMorePosts];
}

-(void) publishingFailedWithError:(NSError *)error {
	NSLog(@"PUBLISHING FAILED");
	NSString *message = @"We were unable to publish your post. One of the videos may be too long or your internet connection may be too weak. Please try again later.";
	UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Publishing Failed" message:message preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction * action) {}];
	[newAlert addAction:defaultAction];
	[self presentViewController:newAlert animated:YES completion:nil];
	if(self.publishingProgress) [self.publishingProgressView removeFromSuperview];
}

#pragma mark - Lazy Instantiation -

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

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
	if (object == self.publishingProgress && [keyPath isEqualToString:@"completedUnitCount"] ) {
		[self.progressBar setProgress:self.publishingProgress.fractionCompleted animated:YES];
	}
}

-(PostListVC *) postListVC{
	if(!_postListVC){
		CGFloat postHeight = self.view.frame.size.height - self.view.frame.size.width;
		CGFloat postWidth = (self.view.frame.size.width / self.view.frame.size.height ) * postHeight;//same ratio as screen
		self.cellSmallFrameSize = CGSizeMake(postWidth, postHeight);
		UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
		flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		[flowLayout setMinimumInteritemSpacing:CELL_SPACING_SMALL];
		[flowLayout setMinimumLineSpacing:CELL_SPACING_SMALL];
		[flowLayout setItemSize:self.cellSmallFrameSize];
		_postListVC = [[PostListVC alloc] initWithCollectionViewLayout:flowLayout];
		_postListVC.postListDelegate = self;
		_postListVC.inSmallMode = YES;
		self.postListSmallFrame = CGRectMake(0.f,(self.profileInFeed || self.isCurrentUserProfile) ?(postHeight + TAB_BAR_HEIGHT):
											 (self.view.frame.size.height - postHeight),
											 self.view.frame.size.width, postHeight);
		self.postListLargeFrame = self.view.bounds;
		[_postListVC.view setFrame:self.postListSmallFrame];
		[self.view addSubview:_postListVC.view];
		[self.view bringSubviewToFront:_postListVC.view];
	}
	return _postListVC;
}
-(PHImageManager*) imageManager {
	if (!_imageManager) {
		_imageManager = [[PHImageManager alloc] init];
	}
	return _imageManager;
}

-(void)dealloc{
    NSLog(@"Profile dealocated");
}

@end
