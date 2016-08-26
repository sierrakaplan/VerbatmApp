//
//  ProfileVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "Channel_BackendObject.h"

#import "Durations.h"

#import "Icons.h"

#import "Follow_BackendManager.h"

#import "GMImagePickerController.h"

#import "LoadingIndicator.h"

#import <MessageUI/MFMessageComposeViewController.h>

#import "ParseBackendKeys.h"

#import "ProfileVC.h"
#import "ProfileHeaderView.h"
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
#import "UserSetupParameters.h"
#import "UserAndChannelListsTVC.h"
#import "UserInfoCache.h"
#import "UtilityFunctions.h"
#import <PromiseKit/PromiseKit.h>

@interface ProfileVC() <ProfileHeaderViewDelegate,
UIScrollViewDelegate, PostListVCProtocol,
UIGestureRecognizerDelegate, GMImagePickerControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic) UIButton * postPrompt;

@property (nonatomic) BOOL currentlyCreatingNewChannel;

@property (strong, nonatomic) PostListVC * postListVC;

@property (nonatomic, strong) ProfileHeaderView *profileHeaderView;
@property (nonatomic) BOOL headerViewOnScreen;

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

#define CELL_SPACING_SMALL 5.f
#define CELL_SPACING_LARGE 0.3
#define POSTLISTVC_ISNOT_CREATED_YET (!_postListVC)

@end

@implementation ProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
	self.automaticallyAdjustsScrollViewInsets = NO;
	self.view.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1.f];
	[self buildHeaderView];
	[self loadContentToPostList];
}



-(void)updateDateOfLastPostSeen{
    if(!self.isCurrentUserProfile && self.profileInFeed && [self.channel dateOfMostRecentChannelPost]){
        NSDate * finalDate = [self.postListVC creationDateOfLastPostObjectInPostList];
        if(finalDate){
            [self.channel.followObject setObject:finalDate forKey:FOLLOW_LATEST_POST_DATE];
            [self.channel.followObject saveInBackground];
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

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self setNeedsStatusBarAppearanceUpdate];
}

-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
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
	[self presentViewController:userList animated:YES completion:nil];
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

	self.profileHeaderView = [[ProfileHeaderView alloc] initWithFrame:frame andUser:user
														   andChannel:self.channel
														 inProfileTab:self.isProfileTab inFeed:self.profileInFeed];

	self.profileHeaderView.delegate = self;
	[self.view addSubview: self.profileHeaderView];
	[self.view sendSubviewToBack:self.profileHeaderView];
	self.headerViewOnScreen = YES;
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

-(void)addClearScreenGesture{
	UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearScreen:)];
	singleTap.numberOfTapsRequired = 1;
	singleTap.delegate = self;
	[self.postListVC.view addGestureRecognizer:singleTap];
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
    UserAndChannelListsTVC *likersListVC = [[UserAndChannelListsTVC alloc] initWithStyle:UITableViewStyleGrouped];
    [likersListVC presentList:CommentList forChannel:nil orPost:post];
    [self presentViewController:likersListVC animated:YES completion:nil];
}

// Something in profile was reblogged so contains a header allowing user to navigate
// to a different profile
-(void)channelSelected:(Channel *) channel{
    if([[[channel channelCreator] objectId] isEqualToString:[[self.channel channelCreator] objectId]]){
        //if the channel belongs to this profile then simply remove the large postlist view
        [self exitCurrentPostView];
    } else {
        ProfileVC *  userProfile = [[ProfileVC alloc] init];
		BOOL isCurrentUserChannel = [[channel.channelCreator objectId] isEqualToString:[[PFUser currentUser] objectId]];
		userProfile.isCurrentUserProfile = isCurrentUserChannel;
        userProfile.isProfileTab = NO;
        userProfile.ownerOfProfile = channel.channelCreator;
        userProfile.channel = channel;
        [self presentViewController:userProfile animated:YES completion:^{
        }];
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

-(void)presentViewPostView:(PostListVC *) postList inSmallMode:(BOOL) inSmallMode shouldPage:(BOOL) shouldPage fromCellPath:(NSIndexPath *) cellPath{

	[self.view addSubview:postList.view];
	[self.view bringSubviewToFront:postList.view];
	if(cellPath.row < self.postListVC.parsePostActivityObjects.count)[postList.collectionView scrollToItemAtIndexPath:cellPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
	[self.delegate showTabBar:!shouldPage];
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

	PostCollectionViewCell* cell = (PostCollectionViewCell*)[[self.postListVC.collectionView visibleCells] firstObject];
    if(cellPath == nil) {
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

	//todo: redundant with passing in constructor right now
	NSDate *startingDate = self.channel.followObject ? self.channel.followObject[FOLLOW_LATEST_POST_DATE] : nil;
    
    if(self.postListVC.parsePostActivityObjects && self.postListVC.parsePostActivityObjects.count){
        newVC.postsQueryManager = self.postListVC.postsQueryManager;
        newVC.currentlyPublishing = self.postListVC.currentlyPublishing;
        [newVC display:self.channel withListOwner:self.ownerOfProfile isCurrentUserProfile:self.isCurrentUserProfile
       andStartingDate:startingDate withOldParseObjects:self.postListVC.parsePostActivityObjects];
    }
    
    [self presentViewPostView:newVC inSmallMode:!self.inFullScreenMode shouldPage:self.inFullScreenMode fromCellPath:cellPath];
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
	[self showFollowers];
}

-(void)followingButtonSelected{
	[self showChannelsFollowing];
}

-(void)showChannelsFollowing{
	[self presentUserList: FollowingList];
}

-(void)showFollowers{
	[self presentUserList: FollowersList];
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

-(void)createPromptToPost{
	self.postPrompt =  [[UIButton alloc] init];
	[self.postPrompt setBackgroundImage:[UIImage imageNamed:CREATE_POST_PROMPT_ICON] forState:UIControlStateNormal];
	[self.view addSubview:self.postPrompt];
	[self.postPrompt addTarget:self action:@selector(createFirstPost) forControlEvents:UIControlEventTouchDown];
	self.postPrompt.frame = CGRectMake(self.postListSmallFrame.origin.x, self.postListSmallFrame.origin.y,
									   self.cellSmallFrameSize.width, self.cellSmallFrameSize.height);
	self.postListVC.view.hidden = YES;
	[self.delegate showTabBar:YES];
}

-(void)createFirstPost {
	if([self.delegate respondsToSelector:@selector(userCreateFirstPost)]){
		[self.delegate userCreateFirstPost];
	}
}

-(void)postsFound{
	[self removePromptToPost];
    if(!self.isCurrentUserProfile){
        [self.profileHeaderView removeProfileConstructionNotification];
    }
}

-(void)removePromptToPost{
	if(self.isCurrentUserProfile){
		if(self.postPrompt)[self.postPrompt removeFromSuperview];
		self.postPrompt = nil;
		self.postListVC.view.hidden = NO;
	}
}

-(void)noPostFound {
    if(self.isCurrentUserProfile){
        [self createPromptToPost];
    }else{
        [self.profileHeaderView presentProfileUnderConstructionNotification];
    }
}

-(void) shareToSmsSelectedToUrl:(NSString *) url{
    if(url){
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        NSString * message = @"Hey - checkout this post on Verbatm!   ";
        controller.body = [message stringByAppendingString:url];
        
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


//the current user has selected the back button
-(void)exitCurrentProfile {
    
    if(self.profileInFeed){
        [self.delegate exitProfile];
    }else{
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        }];
    }
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
		CGFloat postHeight = self.view.frame.size.height - (self.view.frame.size.width - SMALL_SQUARE_LIKESHAREBAR_HEIGHT);
		CGFloat postWidth = (self.view.frame.size.width / self.view.frame.size.height ) * postHeight;//same ratio as screen
        CGFloat postListSmallY = self.view.frame.size.height - postHeight - ((self.isCurrentUserProfile) ? (TAB_BAR_HEIGHT + 1.f): 1.f);
        
		self.cellSmallFrameSize = CGSizeMake(postWidth, postHeight);
		UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
		flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		[flowLayout setMinimumInteritemSpacing:CELL_SPACING_SMALL];
		[flowLayout setMinimumLineSpacing:CELL_SPACING_SMALL];
		[flowLayout setItemSize:self.cellSmallFrameSize];
		_postListVC = [[PostListVC alloc] initWithCollectionViewLayout:flowLayout];
		_postListVC.postListDelegate = self;
		_postListVC.inSmallMode = YES;
		self.postListSmallFrame = CGRectMake(0.f,postListSmallY,
											 self.view.frame.size.width, postHeight);
		self.postListLargeFrame = self.view.bounds;
		[_postListVC.view setFrame:self.postListSmallFrame];
        [self.view addSubview:_postListVC.view];
    }
    
	return _postListVC;
}

-(PHImageManager*) imageManager {
	if (!_imageManager) {
		_imageManager = [[PHImageManager alloc] init];
	}
	return _imageManager;
}

-(void)dealloc {
}

@end
