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
#import "UserSetupParameters.h"
#import "UserAndChannelListsTVC.h"
#import "UserInfoCache.h"
#import "UtilityFunctions.h"
#import <PromiseKit/PromiseKit.h>

@interface ProfileVC() <ProfileHeaderViewDelegate, ProfileMoreInfoViewDelegate,
UIScrollViewDelegate, PostListVCProtocol,
UIGestureRecognizerDelegate, GMImagePickerControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic) UIButton * postPrompt;

@property (nonatomic) BOOL currentlyCreatingNewChannel;

@property (strong, nonatomic) PostListVC * postListVC;

//@property (nonatomic, strong) ProfileHeaderViewOld *profileHeaderView;
@property (nonatomic) ProfileHeaderView *profileHeaderView;
@property (nonatomic) ProfileMoreInfoView *moreInfoView;
@property (nonatomic) BOOL moreInfoViewOnScreen;
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
#define HEADER_SIZE (self.view.frame.size.height * 2.f/5.f)

@end

@implementation ProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
	self.moreInfoViewOnScreen = NO;
	self.automaticallyAdjustsScrollViewInsets = NO;
	self.view.backgroundColor = [UIColor blackColor];
	[self buildHeaderView];
	[self loadContentToPostList];
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

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self setNeedsStatusBarAppearanceUpdate];
	if (!self.inFullScreenMode) {
		[(MasterNavigationVC*)self.tabBarController showTabBar:YES];
	}
	[self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
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
	if (self.navigationController) {
		[self.navigationController pushViewController:userList animated:YES];
	} else {
		[self.delegate pushViewController:userList];
	}
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

-(void)buildHeaderView {
	if(self.profileHeaderView){
		[self.profileHeaderView removeFromSuperview];
		self.profileHeaderView = nil;
	}

	CGRect frame = CGRectMake(0.f, 0.f, self.view.frame.size.width, HEADER_SIZE);
	self.profileHeaderView = [[ProfileHeaderView alloc] initWithFrame:frame andChannel:self.channel
												 inCurrentUserProfile:NO];
	self.profileHeaderView.delegate = self;
	[self.view addSubview: self.profileHeaderView];
	[self.view sendSubviewToBack:self.profileHeaderView];
}

-(void) moreInfoButtonTapped {
	CGFloat yPos = HEADER_SIZE;
	CGFloat height = self.view.frame.size.height - yPos;
	CGRect offScreenFrame = CGRectMake(0.f, yPos - height, self.view.frame.size.width, height);
	CGRect onScreenFrame = CGRectMake(0.f, yPos, self.view.frame.size.width, height);
	if (!_moreInfoView) {
		self.moreInfoView = [[ProfileMoreInfoView alloc] initWithFrame:onScreenFrame
												   andNumFollowers:self.channel.parseChannelObject[CHANNEL_NUM_FOLLOWS]
												   andNumFollowing:self.channel.parseChannelObject[CHANNEL_NUM_FOLLOWING]
													andDescription:self.channel.blogDescription];
		self.moreInfoView.delegate = self;
		self.moreInfoView.frame = offScreenFrame;
		[self.view addSubview: self.moreInfoView];
	}
	[self.view bringSubviewToFront: self.moreInfoView];
	[self.view bringSubviewToFront: self.profileHeaderView];
	self.moreInfoViewOnScreen = !self.moreInfoViewOnScreen;
	[UIView animateWithDuration:0.5f animations:^{
		if (self.moreInfoViewOnScreen) {
			self.moreInfoView.frame = onScreenFrame;
		} else {
			self.moreInfoView.frame = offScreenFrame;
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
//				[self getImageFromAsset:asset];
			}
		}
	}
}

- (void)assetsPickerControllerDidCancel:(GMImagePickerController *)picker {
	[picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
	}];
}

//todo: in edit mode
//-(void) getImageFromAsset: (PHAsset *) asset {
//	PHImageRequestOptions *options = [PHImageRequestOptions new];
//	options.synchronous = YES;
//	[self.imageManager requestImageForAsset:asset targetSize:self.view.frame.size contentMode:PHImageContentModeAspectFill
//									options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
//										// RESULT HANDLER CODE NOT HANDLED ON MAIN THREAD so must be careful about UIView calls if not using dispatch_async
//										dispatch_async(dispatch_get_main_queue(), ^{
//											[self.profileHeaderView setCoverPhotoImage:image];
//										});
//									}];
//}


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
    UserAndChannelListsTVC *commentListVC = [[UserAndChannelListsTVC alloc] initWithStyle:UITableViewStyleGrouped];
    [commentListVC presentList:CommentList forChannel:nil orPost:post];
	if (self.navigationController) {
		[self.navigationController pushViewController:commentListVC animated:YES];
	} else {
		[self.delegate pushViewController:commentListVC];
	}
}

-(void) showWhoLikedPost:(PFObject *)post {
	UserAndChannelListsTVC *likersListVC = [[UserAndChannelListsTVC alloc] initWithStyle:UITableViewStyleGrouped];
	[likersListVC presentList:LikersList forChannel:nil orPost:post];
	if (self.navigationController) {
		[self.navigationController pushViewController:likersListVC animated:YES];
	} else {
		[self.delegate pushViewController:likersListVC];
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
        userProfile.isProfileTab = NO;
        userProfile.ownerOfProfile = channel.channelCreator;
        userProfile.channel = channel;
		if (self.navigationController) {
			[self.navigationController pushViewController:userProfile animated:YES];
		} else {
			[self.delegate pushViewController:userProfile];
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
	if (cellPath == nil) {

	} else if(cellPath.row < self.postListVC.parsePostActivityObjects.count) {
		[postList.collectionView scrollToItemAtIndexPath:cellPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
	}
	[(MasterNavigationVC*)self.tabBarController showTabBar: inSmallMode];
	if (self.navigationController) {
		[self.navigationController setNavigationBarHidden: !inSmallMode];
	} else {
		[self.delegate showNavBar:inSmallMode];
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

-(void) settingsButtonClicked {
	//todo: push segue with back button
//	[self performSegueWithIdentifier:SETTINGS_PAGE_MODAL_SEGUE sender:self];
}

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
//	[self removePromptToPost];
    if(!self.isCurrentUserProfile){
//        [self.profileHeaderView removeProfileConstructionNotification];
    }
}


-(void)noPostFound {
    if(!self.isCurrentUserProfile){
       // [self.profileHeaderView presentProfileUnderConstructionNotification];
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

-(PHImageManager*) imageManager {
	if (!_imageManager) {
		_imageManager = [[PHImageManager alloc] init];
	}
	return _imageManager;
}

-(void)dealloc {
}

@end
