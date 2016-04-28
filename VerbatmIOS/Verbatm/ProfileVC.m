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

#import "LoadingIndicator.h"

#import "ParseBackendKeys.h"

#import "ProfileVC.h"
#import "ProfileNavBar.h"
#import "PostListVC.h"

#import "PublishingProgressManager.h"

#import "SharePostView.h"
#import "SegueIDs.h"
#import "SettingsVC.h"

#import "UIView+Effects.h"
#import "User_BackendObject.h"
#import "UserInfoCache.h"
#import "UserSetupParameters.h"

#import <PromiseKit/PromiseKit.h>

@interface ProfileVC() <ProfileNavBarDelegate,Intro_Notification_Delegate,
UIScrollViewDelegate, CreateNewChannelViewProtocol,
PublishingProgressProtocol, PostListVCProtocol, UIGestureRecognizerDelegate>

@property (nonatomic) BOOL initializing;
@property (nonatomic) BOOL currentlyCreatingNewChannel;

@property (strong, nonatomic) PostListVC * postListVC;
@property (nonatomic) Intro_Instruction_Notification_View * introInstruction;

@property (nonatomic, strong) ProfileNavBar * profileNavBar;
@property (nonatomic) BOOL profileNavBarOnScreen;
@property (nonatomic) CGRect profileNavBarFrameOnScreen;
@property (nonatomic) CGRect profileNavBarFrameOffScreen;

@property (nonatomic, strong) NSString * currentThreadInView;

@property (strong, nonatomic) NSArray* channels;

@property (strong, nonatomic) CreateNewChannelView * createNewChannelView;
@property (nonatomic) UIView * darkScreenCover;
@property (nonatomic) SharePostView * sharePOVView;

@property (strong, nonatomic) LoadingIndicator * customActivityIndicator;

#pragma mark Publishing

@property (nonatomic, strong) UIView* publishingProgressView;
@property (nonatomic, strong) NSProgress* publishingProgress;
@property (nonatomic, strong) UIProgressView* progressBar;

@end

@implementation ProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
	self.initializing = YES;
	if (!self.postListVC) {
		[self initialize].then(^{
			[self selectChannel: self.startChannel ? self.startChannel : [self.channels firstObject]];
			self.initializing = NO;
		});
	}
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (!self.initializing) {
		[self selectChannel: self.startChannel ? self.startChannel : [self.channels firstObject]];
	}
}

-(AnyPromise*) initialize {

	self.view.backgroundColor = [UIColor blackColor];
	//this is where you'd fetch the threads
	[self.customActivityIndicator startCustomActivityIndicator];
	self.view.clipsToBounds = YES;
	return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
		[self getChannelsWithCompletionBlock:^{
			[self.customActivityIndicator stopCustomActivityIndicator];
			[self createNavigationBar];
			[self addClearScreenGesture];
			[self checkIntroNotification];

			if (self.channels.count == 0) return;

			[self addPostListVC];

			if(self.isCurrentUserProfile) {
				//We stop the video because we start in the feed
				[self.postListVC offScreen];
			}
			resolve(nil);
		}];
	}];
}

-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.postListVC clearViews];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

//this is where downloading of channels should happen
-(void) getChannelsWithCompletionBlock:(void(^)())block{
	if(self.isCurrentUserProfile){
		[[UserInfoCache sharedInstance] loadUserChannelsWithCompletionBlock:^{
			block();
		}];
	} else {
		[Channel_BackendObject getChannelsForUser:self.userOfProfile withCompletionBlock:
		 ^(NSMutableArray * channels) {
			 self.channels = channels;
			 block();
		 }];
	}
}

-(void)checkIntroNotification{
	if(![[UserSetupParameters sharedInstance] isProfile_InstructionShown] &&
	   self.isCurrentUserProfile) {
		self.introInstruction = [[Intro_Instruction_Notification_View alloc] initWithCenter:self.view.center andType:Profile];
		self.introInstruction.custom_delegate = self;
		[self.view addSubview:self.introInstruction];
		[self.view bringSubviewToFront:self.introInstruction];
		[[UserSetupParameters sharedInstance] set_profileNotification_InstructionAsShown];
	}
}

-(void) notificationDoneAnimatingOut {
	if(self.introInstruction){
		[self.introInstruction removeFromSuperview];
		self.introInstruction = nil;
	}
}

-(void) addPostListVC {
	if(self.postListVC) {
		[self.postListVC offScreen];
		[self.postListVC.view removeFromSuperview];
	}

	UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
	flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	[flowLayout setMinimumInteritemSpacing:0.3];
	[flowLayout setMinimumLineSpacing:0.0f];
	[flowLayout setItemSize:self.view.frame.size];
	self.postListVC = [[PostListVC alloc] initWithCollectionViewLayout:flowLayout];
	self.postListVC.postListDelegate = self;
	if(self.profileNavBar)[self.view insertSubview:self.postListVC.view belowSubview:self.profileNavBar];
	else [self.view addSubview:self.postListVC.view];
}

-(void) createNavigationBar {
	//frame when on screen
	self.profileNavBarFrameOnScreen = CGRectMake(0.f, 0.f, self.view.frame.size.width, PROFILE_NAV_BAR_HEIGHT);
	//frame when off screen
	self.profileNavBarFrameOffScreen = CGRectMake(0.f, 0.f - STATUS_BAR_HEIGHT - PROFILE_NAV_BAR_HEIGHT,
												  self.view.frame.size.width, PROFILE_NAV_BAR_HEIGHT);

	self.profileNavBar = [[ProfileNavBar alloc]
						  initWithFrame:self.profileNavBarFrameOnScreen
						  andChannels: self.channels
						  andUser:self.userOfProfile
						  isCurrentLoggedInUser:self.isCurrentUserProfile
						  isProfileTab:self.isProfileTab];

	self.profileNavBar.delegate = self;
	[self.view addSubview:self.profileNavBar];
	[self.view bringSubviewToFront:self.profileNavBar];
	self.profileNavBarOnScreen = YES;
}

-(void)addClearScreenGesture{
	UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearScreen:)];
	singleTap.numberOfTapsRequired = 1;
	singleTap.delegate = self;
	[self.view addGestureRecognizer:singleTap];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return  (![touch.view isKindOfClass:[Intro_Instruction_Notification_View class]]);
}

#pragma mark - POSTListView delegate -

-(void)channelSelected:(Channel *) channel{
	ProfileVC *  userProfile = [[ProfileVC alloc] init];
	userProfile.isCurrentUserProfile = NO;
	userProfile.isProfileTab = NO;
	userProfile.userOfProfile = channel.channelCreator;
	userProfile.startChannel = channel;
	[self presentViewController:userProfile animated:YES completion:^{
	}];
}

#pragma mark - Profile Nav Bar Delegate Methods -

-(void) settingsButtonClicked {
	[self performSegueWithIdentifier:SETTINGS_PAGE_MODAL_SEGUE sender:self];
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

-(void) removeScreenDarkener{
	if(self.darkScreenCover){
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
            if (channelObject) {
                Channel *newChannel = [[Channel alloc] initWithChannelName:channelName
													 andParseChannelObject:channelObject
														 andChannelCreator:[PFUser currentUser]];
                [self.profileNavBar newChannelCreated:newChannel];
                [self clearChannelCreationView];
				[[UserInfoCache sharedInstance] loadUserChannelsWithCompletionBlock:^{}];
                self.currentlyCreatingNewChannel = NO;
            }
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
        messageText = @"Are you sure you want to block this user? This will prevent them from finding you on Verbatm or viewing any of your content. You will also automatically unfollow all of their channels. You can undo your decision at any time.";
    } else {
        titleText = @"Unblock User";
        messageText = @"Are you sure you want to unblock this user? This will allow them to view your content on Verbatm.";
    }
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:titleText
                                                                   message:messageText
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {}];
    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if(shouldBlock){
			[User_BackendObject blockUser:self.userOfProfile];

			//unfollow all their channels automatically
			for (Channel *channel in self.channels) {
				[Follow_BackendManager user:[PFUser currentUser] stopFollowingChannel: channel];
			}
			[self.profileNavBar updateUserIsBlocked:YES];

        } else {
			[User_BackendObject unblockUser:self.userOfProfile];
			[self.profileNavBar updateUserIsBlocked:NO];
        }
    }];
    
    [alert addAction: cancelAction];
    [alert addAction: confirmAction];
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)newChannelSelected:(Channel *) channel{
	[self.postListVC display:channel asPostListType:listChannel withListOwner:self.userOfProfile
		isCurrentUserProfile:self.isCurrentUserProfile];
}

// updates tab and content
-(void) selectChannel: (Channel *) channel {
	[self.profileNavBar selectChannel: channel];
	[self.postListVC display:channel asPostListType:listChannel withListOwner:self.userOfProfile
		isCurrentUserProfile:self.isCurrentUserProfile];
}

#pragma mark - POSTListVC Protocol -

-(void)hideNavBarIfPresent{
	[self presentHeadAndFooter:NO];
}

-(void) presentHeadAndFooter:(BOOL) shouldShow {
	if(shouldShow) {
		self.profileNavBarOnScreen = YES;
		[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
			[self.profileNavBar setFrame: self.profileNavBarFrameOnScreen];
		}];
		[self.delegate showTabBar:YES];
		if(self.isProfileTab) [self.postListVC footerShowing:YES];

	} else {
		self.profileNavBarOnScreen = NO;
		[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
			[self.profileNavBar setFrame: self.profileNavBarFrameOffScreen];
		}];

		[self.delegate showTabBar:NO];
		if(self.isCurrentUserProfile) [self.postListVC footerShowing:NO];
	}
}

-(void)clearScreen:(UIGestureRecognizer *) tapGesture {
	// Tap interferes with photo fade circle
	CGFloat circleRadiusWithPadding = (CIRCLE_RADIUS + 20.f);
	CGPoint tapPoint = [tapGesture locationInView:self.view];
	if ((tapPoint.y > (self.view.frame.size.height - CIRCLE_OFFSET - circleRadiusWithPadding*2)
		 && tapPoint.y < (self.view.frame.size.height - CIRCLE_OFFSET))
		&& (tapPoint.x > (self.view.frame.size.width/2.f - circleRadiusWithPadding)
			&& tapPoint.x < (self.view.frame.size.width/2.f + circleRadiusWithPadding)))
		return;
	if (self.profileNavBarOnScreen) {
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

#pragma mark - Publishing -

-(void) showPublishingProgress {
	if (_publishingProgressView) return;
	PublishingProgressManager *progressManager = [PublishingProgressManager sharedInstance];
	self.publishingProgress = [progressManager progressAccountant];
	[progressManager setDelegate:self];
	Channel * currentPublishingChannel = [progressManager currentPublishingChannel];
	if ([progressManager newChannelCreated]) {
		[self.profileNavBar newChannelCreated: currentPublishingChannel];
		[progressManager setNewChannelCreated:NO];
	}
	[self selectChannel: currentPublishingChannel];
	[self.profileNavBar addSubview: self.publishingProgressView];
}

#pragma mark Publishing Progress Manager Delegate methods

-(void) publishingComplete {
	NSLog(@"Publishing Complete!");
	[self.publishingProgressView removeFromSuperview];
	self.publishingProgressView = nil;
	//todo: bring this back
	//if ([PublishingProgressManager sharedInstance].currentPublishingChannel == self.postListVC.channelForList) {
		[self.postListVC refreshPosts];
	//}
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
		_publishingProgressView = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.profileNavBar.frame.size.height,
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

-(NSArray *)channels{
	return (!self.isCurrentUserProfile) ? _channels : [[UserInfoCache sharedInstance] getUserChannels];
}

-(LoadingIndicator *)customActivityIndicator{
    if(!_customActivityIndicator){
        CGPoint newCenter = CGPointMake(self.view.center.x, self.view.frame.size.height * 1.f/2.f);
        _customActivityIndicator = [[LoadingIndicator alloc] initWithCenter:newCenter andImage:[UIImage imageNamed:LOAD_ICON_IMAGE]];
        [self.view addSubview:_customActivityIndicator];
    }
    return _customActivityIndicator;
}


@end
