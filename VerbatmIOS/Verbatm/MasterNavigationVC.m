//
//  verbatmMasterNavigationViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 5/20/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "Analytics.h"

#import "ContentDevVC.h"

#import "Durations.h"

#import "DiscoverVC.h"
#import "FeedTableViewController.h"
#import "FeedProfileListTVC.h"

#import "Icons.h"
#import "InstallationVariables.h"

#import "MasterNavigationVC.h"

#import "Notifications.h"
#import "NotificationsListTVC.h"
#import "Notification_BackendManager.h"

#import "ParseBackendKeys.h"
#import "ProfileVC.h"
#import "PublishingProgressManager.h"
#import <Parse/PFQuery.h>
#import <Parse/PFInstallation.h>

#import "StoryboardVCIdentifiers.h"
#import "SegueIDs.h"
#import "SizesAndPositions.h"
#import "Styles.h"

#import "UIImage+ImageEffectsAndTransforms.h"
#import "UserAndChannelListsTVC.h"
#import "User_BackendObject.h"
#import "UserInfoCache.h"
#import "UserSetupParameters.h"
#import "UserManager.h"

#import <Crashlytics/Crashlytics.h>


@interface MasterNavigationVC () <UITabBarControllerDelegate, FeedTableViewDelegate,
ProfileVCDelegate, NotificationsListTVCProtocol,FeedProfileListProtocol>

#pragma mark - Tab Bar Controller -

@property (nonatomic) BOOL migrated;

@property (nonatomic) BOOL notificationIndicatorPresent;

@property (nonatomic) BOOL tabBarHidden;
@property (nonatomic) CGRect tabBarFrameOnScreen;
@property (nonatomic) CGRect tabBarFrameOffScreen;

#pragma mark View Controllers in tab bar Controller

@property (strong,nonatomic) ProfileVC *profileVC;
//@property (strong,nonatomic) FeedTableViewController *feedVC;
@property (strong,nonatomic) DiscoverVC *discoverVC;
@property (strong, nonatomic) NotificationsListTVC * notificationVC;
@property (strong, nonatomic) FeedProfileListTVC * feedProfileList;
@property(strong,nonatomic) UIImageView * notificationIndicator;

#define ANIMATION_NOTIFICATION_DURATION 0.5
#define TIME_UNTIL_ANIMATION_CLEAR 1.5
#define DARK_GRAY 0.6f
#define ADK_BUTTON_SIZE 40.f
#define SELECTED_TAB_ICON_COLOR [UIColor colorWithRed:0.5 green:0.1 blue:0.1 alpha:1.f]
#define NOTIFICATION_INDICATOR_SIZE 40.f
@end

@implementation MasterNavigationVC

- (void)viewDidLoad {
	[super viewDidLoad];
	[self registerForNotifications];
	if ([PFUser currentUser].isAuthenticated) {
		[self setUpStartUpEnvironment];
	}
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (![PFUser currentUser].isAuthenticated) {
		[self bringUpLogin];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)viewWillLayoutSubviews {
	CGRect tabFrame = self.tabBar.frame;
	tabFrame.size.height = self.tabBarHeight ? self.tabBarHeight : 80;
	tabFrame.origin.y = self.view.frame.size.height - tabFrame.size.height;
	self.tabBar.frame = tabFrame;
}

- (UIStatusBarAnimation) preferredStatusBarUpdateAnimation {
	return UIStatusBarAnimationSlide;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
	return self.selectedViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
	return self.selectedViewController;
}

-(void) registerForNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loginFailed:)
												 name:NOTIFICATION_USER_LOGIN_FAILED
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loginSucceeded:)
												 name:NOTIFICATION_USER_LOGIN_SUCCEEDED
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(userHasSignedOutNotification:)
												 name:NOTIFICATION_USER_SIGNED_OUT
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(successfullyPublishedNotification:)
                                                 name:NOTIFICATION_POST_PUBLISHED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(publishingFailedNotification:)
                                                 name:NOTIFICATION_POST_FAILED_TO_PUBLISH
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(followingSuccessfulNotification:)
                                                 name:NOTIFICATION_NOW_FOLLOWING_USER
                                               object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(newPushNotification:)
												 name:NOTIFICATION_NEW_PUSH_NOTIFICATION
											   object:nil];
}

#pragma mark - Setting up environment on startup -

-(void) setUpStartUpEnvironment {
	// Associate the device with a user
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	currentInstallation[@"user"] = [PFUser currentUser];
	[currentInstallation saveInBackground];

	[[UserSetupParameters sharedInstance] setUpParameters];
	NSString *facebookId = [PFUser currentUser][USER_FB_ID];
	if (!facebookId) {
		[UserManager setFbId];
	}
	self.view.backgroundColor = [UIColor blackColor];
	//todo: show loading while this happens
	[[UserInfoCache sharedInstance] loadUserChannelsWithCompletionBlock:^{
		[self setUpTabBarController];
	}];
}

#pragma mark - User Manager Delegate -

-(void) loginSucceeded:(NSNotification*) notification {
	PFUser * user = notification.object;
	[[Crashlytics sharedInstance] setUserIdentifier: [user username]];
	[[Crashlytics sharedInstance] setUserName: [user objectForKey:VERBATM_USER_NAME_KEY]];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self setUpStartUpEnvironment];
	});
}

-(void) loginFailed:(NSNotification *) notification {
	NSError* error = (NSError*) notification.object;
	[[Crashlytics sharedInstance] recordError: error];
	//TODO: only do this if have a connection, or only a certain number of times
}

#pragma mark - Tab bar controller -

-(void) setUpTabBarController {
	self.tabBarHeight = TAB_BAR_HEIGHT;
	self.delegate = self;
	[self createViewControllers];

	UIViewController * deadView = [[UIViewController alloc] init];

	UIImage * deadViewTabImage = [self imageWithImage:[[UIImage imageNamed:ADK_NAV_ICON]
													   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
										 scaledToSize:CGSizeMake(30.f, 30.f)];

	deadView.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:deadViewTabImage selectedImage:deadViewTabImage];
	deadView.tabBarItem.imageInsets = UIEdgeInsetsMake(5.f, 0.f, -5.f, 0.f);

	self.viewControllers = @[self.feedProfileList, self.discoverVC, deadView,self.notificationVC, self.profileVC];

	if ([[InstallationVariables sharedInstance] launchedFromNotification]) {
		self.selectedIndex = 3;
	} else {
		self.selectedIndex = 0;
	}

	[self addTabBarCenterButtonOverDeadView];
	[self formatTabBar];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
	UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
	[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

-(void) formatTabBar {
	NSInteger numTabs = self.viewControllers.count;
	CGSize tabBarItemSize = CGSizeMake(self.tabBar.frame.size.width/numTabs,
									   self.tabBarHeight);
	// Sets background of unselected UITabBarItem
	[self.tabBar setBackgroundImage: [self getUnselectedTabBarItemImageWithSize: tabBarItemSize]];
	[self.tabBar setBackgroundColor:[UIColor colorWithWhite:0.15f alpha:1.f]];
	// Sets the background color of the selected UITabBarItem
	[self.tabBar setSelectionIndicatorImage: [self getSelectedTabBarItemImageWithSize: tabBarItemSize]];

	//set two tab bar frames-- for when we want to remove the tab bar
	self.tabBarFrameOnScreen = self.tabBar.frame;
	self.tabBarFrameOffScreen = CGRectMake(self.tabBar.frame.origin.x,
										   self.view.frame.size.height + ADK_BUTTON_SIZE/2.f,
										   self.tabBar.frame.size.width,
										   self.tabBarHeight);
}

-(UIImage*) getUnselectedTabBarItemImageWithSize: (CGSize) size {
	return [UIImage makeImageWithColorAndSize:[UIColor clearColor]
									  andSize: size];
}

-(UIImage*) getSelectedTabBarItemImageWithSize: (CGSize) size {
	return [UIImage makeImageWithColorAndSize:[UIColor clearColor]
									  andSize: size];
}

//the view controllers that will be tabbed
-(void)createViewControllers {
	self.discoverVC = [self.storyboard instantiateViewControllerWithIdentifier:FEATURED_CONTENT_VC_ID];
	self.discoverVC.onboardingBlogSelection = NO;
	self.profileVC = [self.storyboard instantiateViewControllerWithIdentifier:PROFILE_VC_ID];
	self.profileVC.delegate = self;
	self.profileVC.ownerOfProfile = [PFUser currentUser];
	self.profileVC.isCurrentUserProfile = YES;
	self.profileVC.channel = [[UserInfoCache sharedInstance] getUserChannel];
	self.profileVC.isProfileTab = YES;

    
    self.feedProfileList = [[FeedProfileListTVC alloc] init];
    self.feedProfileList.view.frame = self.view.bounds;
    self.feedProfileList.delegate = self;

    self.notificationVC = [[NotificationsListTVC alloc] init];
    self.notificationVC.view.frame = self.view.bounds;
    self.notificationVC.delegate = self;
	self.profileVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@""
															  image:[UIImage imageNamed:PROFILE_NAV_ICON]
													  selectedImage:[UIImage imageNamed:PROFILE_NAV_ICON]];
	
    
    self.feedProfileList.tabBarItem = [[UITabBarItem alloc] initWithTitle:@""
                                                           image:[UIImage imageNamed:HOME_NAV_ICON]
                                                   selectedImage:[UIImage imageNamed:HOME_NAV_ICON]];
//    self.feedVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@""
//															  image:[UIImage imageNamed:HOME_NAV_ICON]
//													  selectedImage:[UIImage imageNamed:HOME_NAV_ICON]];
	self.discoverVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@""
															   image:[UIImage imageNamed:DISCOVER_NAV_ICON]
													   selectedImage:[UIImage imageNamed:DISCOVER_NAV_ICON]];
    
    UIImage * unselectedNotification = [self imageWithImage:[[UIImage imageNamed:NOTIFICATION_ICON_UNSELECTED]
                                                             imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                               scaledToSize:CGSizeMake(30.f, 30.f)];
    
    UIImage * selectedNotification = [self imageWithImage:[[UIImage imageNamed:NOTIFICATION_ICON_SELECTED]
                                                             imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                               scaledToSize:CGSizeMake(30.f, 30.f)];
    
    self.notificationVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@""
                                                               image:unselectedNotification
                                                       selectedImage:selectedNotification];
    
    self.notificationVC.tabBarItem.imageInsets = UIEdgeInsetsMake(5.f, 0.f, -5.f, 0.f);
    
	self.profileVC.tabBarItem.imageInsets = self.discoverVC.tabBarItem.imageInsets =
    self.feedProfileList.tabBarItem.imageInsets =  UIEdgeInsetsMake(5.f, 0.f, -5.f, 0.f);
}

-(void)notificationListHideTabBar:(BOOL) shouldHide{
    [self showTabBar:!shouldHide];
}

-(void)showNotificationIndicator{
    [self showIndicator];
}

-(void)removeNotificationIndicator{
    [self removeIndicator];
}

-(void)removeIndicator {
    self.notificationIndicatorPresent = NO;
    [self.notificationIndicator removeFromSuperview];
}

-(void)showIndicator {
    self.notificationIndicatorPresent = YES;
	if (self.tabBarHidden) return;
    CGFloat tabBarItemWidth = self.view.frame.size.width/5.f;
	CGFloat xpos = 1.f + (self.view.frame.size.width - (tabBarItemWidth *2)) + tabBarItemWidth/2.f;

    CGRect frame = CGRectMake(xpos, self.view.frame.size.height - (TAB_BAR_HEIGHT + NOTIFICATION_INDICATOR_SIZE), NOTIFICATION_INDICATOR_SIZE, NOTIFICATION_INDICATOR_SIZE);
    [self.notificationIndicator setFrame:frame];
    [self.view addSubview:self.notificationIndicator];
    [self.view bringSubviewToFront:self.notificationIndicator];
}

// Create a custom UIButton and add it over our adk icon
-(void) addTabBarCenterButtonOverDeadView {

	NSInteger numTabs = self.viewControllers.count;
	CGFloat tabWidth = self.tabBar.frame.size.width/numTabs;
	// covers up tab so that it won't go to blank view controller
	// Center tab out of 3
	UIView* tabView = [[UIView alloc] initWithFrame:CGRectMake(tabWidth*2, 0.f, tabWidth,
															   self.tabBarHeight)];
	[tabView setBackgroundColor:[UIColor clearColor]];

	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = tabView.frame;
	[button setBackgroundColor:[UIColor clearColor]];
	[button addTarget:self action:@selector(revealADK) forControlEvents:UIControlEventTouchUpInside];

	//[self.tabBar addSubview:tabView];
	[self.tabBar addSubview:button];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController
 shouldSelectViewController:(UIViewController *)viewController {
	// Refresh feed if they tap the feed icon while on the feed
	if (viewController == self.feedProfileList && self.selectedViewController == self.feedProfileList) {
		//todo:[self.feedProfileList refreshListOfContent];
	}
	return YES;
}

-(void) revealADK {
	[[Analytics getSharedInstance] newADKSession];
	[self performSegueWithIdentifier:ADK_SEGUE sender:self];
}


-(void)userHasSignedOutNotification:(NSNotification *) notification{
	[self bringUpLogin];
}


#pragma mark - Handle Login -

//brings up the create account page if there is no user logged in
-(void) bringUpLogin {
	[self performSegueWithIdentifier:SEGUE_LOGIN_OR_SIGNUP sender:self];
}

//catches the unwind segue from login / create account or adk
- (IBAction) unwindToMasterNavVC: (UIStoryboardSegue *)segue {
    
	if ([segue.identifier isEqualToString: UNWIND_SEGUE_FROM_ADK_TO_MASTER] ||
		[segue.identifier isEqualToString: UNWIND_SEGUE_FROM_ONBOARDING_TO_MASTER]) {
		if ([[PublishingProgressManager sharedInstance] currentlyPublishing]) {
			[self setSelectedViewController:self.profileVC];
		}
		[[Analytics getSharedInstance] endOfADKSession];
	} else if ([segue.identifier isEqualToString: UNWIND_SEGUE_FACEBOOK_LOGIN_TO_MASTER] ||
               [segue.identifier isEqualToString: UNWIND_SEGUE_PHONE_LOGIN_TO_MASTER]) {
		//todo
	}
}

#pragma mark - Profile VC Delegate -

-(void) userCreateFirstPost{
    [self revealADK];
}

#pragma mark - Feed VC Delegate -

-(void) goToDiscover{
    [self setSelectedIndex: 1];
}


-(void) showTabBar:(BOOL)show {
	if (show) {
		self.tabBarHidden = NO;
        if (self.notificationIndicatorPresent) {
            [self showIndicator];
        }

		[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
			[self setNeedsStatusBarAppearanceUpdate];
			self.tabBar.frame = self.tabBarFrameOnScreen;
		}];
	} else {
		self.tabBarHidden = YES;
        if(self.notificationIndicatorPresent){
            [self removeIndicator];
            self.notificationIndicatorPresent = YES;
        }
		[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
			[self setNeedsStatusBarAppearanceUpdate];
			self.tabBar.frame = self.tabBarFrameOffScreen;
		}];
	}
}

#pragma mark - Publishing Alerts -

-(void)successfullyPublishedNotification:(NSNotification *) notification {

	UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Successfully Published!"
																	   message:@"Remember to share your post! :D"
																preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* action = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault
												   handler:^(UIAlertAction * action) {}];
	[newAlert addAction:action];
	[self presentViewController:newAlert animated:YES completion:nil];
}

-(void)publishingFailedNotification:(NSNotification *) notification{
	NSError *error = notification.object;
	NSString* message = @"Don't worry - we saved all your stuff! Try to publish again later!";
	if (error.code == -1000 && [error.domain isEqualToString:@"com.alamofire.error.serialization.request"]) {
		message = @"We couldn't publish one of your pieces of media - the file was unreadable.";
	}
	UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Publishing Failed" message:message preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
												   handler:^(UIAlertAction * action) {}];
	[newAlert addAction:action];
	[self presentViewController:newAlert animated:YES completion:nil];
}

-(void)followingSuccessfulNotification:(NSNotification *) notification {
}

-(void) newPushNotification:(NSNotification *) notification {
	NSDictionary *notificationInfo = notification.userInfo;
	NSNumber *notificationType = notificationInfo[@"notificationType"];
	NSInteger type = notificationType.integerValue;
	if (type != NOTIFICATION_NEW_POST && (type & VALID_NOTIFICATION_TYPE)) {
		[self.notificationVC refreshNotifications];
		[self showIndicator];
	} else {
//		NSLog(@"Received push notification that cannot be shown in notifications tab.");
	}
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    //return supported orientation masks
    return UIInterfaceOrientationMaskPortrait;
}

-(UIImageView *)notificationIndicator{
    if(!_notificationIndicator)_notificationIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:NOTIFICATION_POPUP_ICON]];
    return _notificationIndicator;
}

#pragma mark - Memory Warning -

- (void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
	if (self.selectedViewController != self.discoverVC) {
		NSNotification * not = [[NSNotification alloc]initWithName:NOTIFICATION_FREE_MEMORY_DISCOVER object:nil userInfo:nil];
		[[NSNotificationCenter defaultCenter] postNotification:not];
	}
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
