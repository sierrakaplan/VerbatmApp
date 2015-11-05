//
//  verbatmMasterNavigationViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 5/20/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <AVFoundation/AVAudioSession.h>

#import "ArticleDisplayVC.h"
#import "Analytics.h"

#import "FeedVC.h"

#import "GTLVerbatmAppVerbatmUser.h"

#import "Icons.h"
#import "InternetConnectionMonitor.h"

#import "MasterNavigationVC.h"
#import "MediaSessionManager.h"
#import "MediaDevVC.h"

#import "Notifications.h"

#import "POVPublisher.h"
#import "PreviewDisplayView.h"
#import "ProfileVC.h"

#import "SegueIDs.h"
#import "SizesAndPositions.h"
#import "Styles.h"

#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

#import "UIImage+ImageEffectsAndTransforms.h"
#import "UserSetupParameters.h"
#import "UserManager.h"
#import "UserPovInProgress.h"

#import "VerbatmCameraView.h"


@interface MasterNavigationVC () <UITabBarControllerDelegate, UserManagerDelegate,
MediaDevVCDelegate, FeedVCDelegate, ProfileVCDelegate>

#pragma mark - Tab Bar Controller -
@property (weak, nonatomic) IBOutlet UIView *tabBarControllerContainerView;
@property (strong, nonatomic) UITabBarController* tabBarController;
@property (nonatomic) CGRect tabBarFrameOnScreen;
@property (nonatomic) CGRect tabBarFrameOffScreen;

#pragma mark View Controllers in tab bar Controller

@property (strong,nonatomic) ProfileVC* profileVC;
@property (strong,nonatomic) FeedVC* feedVC;
@property (strong,nonatomic) MediaDevVC* mediaDevVC;

#pragma mark - User Manager -
@property (strong, nonatomic) UserManager* userManager;


#define ANIMATION_NOTIFICATION_DURATION 0.5
#define TIME_UNTIL_ANIMATION_CLEAR 1.5

#define TAB_BAR_CONTROLLER_ID @"main_tab_bar_controller"
#define FEED_VC_ID @"feed_vc"
#define MEDIA_DEV_VC_ID @"media_dev_vc"
#define PROFILE_VC_ID @"profile_vc"


@end

@implementation MasterNavigationVC

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setUpTabBarController];
	if (![PFUser currentUser].isAuthenticated &&
		![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
	} else {
		[self.userManager queryForCurrentUser];
	}
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    if(![[UserSetupParameters sharedInstance]blackCircleInstructionShown]) {
		[self alertPullTrendingIcon];
	}
}

-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

#pragma mark - User Manager Delegate -

-(void) successfullyLoggedInUser:(GTLVerbatmAppVerbatmUser *)user {
	[self.profileVC updateUserInfo];
}

-(void) errorLoggingInUser:(NSError *)error {
	NSLog(@"Error finding current user: %@", error.description);
}

#pragma mark - Tab bar controller -

-(void) setUpTabBarController {
	self.tabBarControllerContainerView.frame = self.view.bounds;
	self.tabBarController = [self.storyboard instantiateViewControllerWithIdentifier: TAB_BAR_CONTROLLER_ID];
	[self.tabBarControllerContainerView addSubview:self.tabBarController.view];
	[self addChildViewController:self.tabBarController];
	self.tabBarController.delegate = self;

	//TODO: remake icons
	CGSize iconSize = CGSizeMake(30, 30);
	self.profileVC = [self.storyboard instantiateViewControllerWithIdentifier:PROFILE_VC_ID];
	self.profileVC.delegate = self;
	self.profileVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:[[UIImage imageNamed:PROFILE_NAV_ICON] scaleImageToSize:iconSize] tag:0];

	self.mediaDevVC = [self.storyboard instantiateViewControllerWithIdentifier:MEDIA_DEV_VC_ID];
	self.mediaDevVC.delegate = self;

	self.feedVC = [self.storyboard instantiateViewControllerWithIdentifier:FEED_VC_ID];
	self.feedVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:[[UIImage imageNamed:HOME_NAV_ICON] scaleImageToSize:iconSize] tag:0];
	self.feedVC.delegate = self;

	self.tabBarController.viewControllers = @[self.profileVC, [[UIViewController alloc] init], self.feedVC];
	self.tabBarController.selectedViewController = self.feedVC;
	UIImage* adkImage = [[UIImage imageNamed:ADK_NAV_ICON] scaleImageToSize:iconSize];
	[self addTabBarCenterButtonWithImage:adkImage highlightImage:adkImage];

	[self formatTabBar];
	self.tabBarFrameOnScreen = self.tabBarController.tabBar.frame;
	self.tabBarFrameOffScreen = CGRectMake(self.tabBarController.tabBar.frame.origin.x,
										   self.view.frame.size.height,
										   self.tabBarController.tabBar.frame.size.width,
										   self.tabBarController.tabBar.frame.size.height);

}

-(void) formatTabBar {
	[self.tabBarController.tabBar setTintColor:[UIColor blackColor]];
	[self.tabBarController.tabBar setBarTintColor:[UIColor lightGrayColor]];
	NSInteger numTabs = self.tabBarController.viewControllers.count;
	// Sets the background color of the selected UITabBarItem
	[self.tabBarController.tabBar setSelectionIndicatorImage:[UIImage makeImageWithColorAndSize:[UIColor darkGrayColor]
																				 andSize: CGSizeMake(self.tabBarController.tabBar.frame.size.width/numTabs,
																															self.tabBarController.tabBar.frame.size.height)]];
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addTabBarCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage {

	NSInteger numTabs = self.tabBarController.viewControllers.count;
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(self.tabBarController.tabBar.frame.size.width/numTabs, 0.f,
							  self.tabBarController.tabBar.frame.size.width/numTabs,
							  self.tabBarController.tabBar.frame.size.height);
	button.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[button setImage:buttonImage forState:UIControlStateNormal];
	[button setImage:highlightImage forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(revealADK) forControlEvents:UIControlEventTouchUpInside];

	[button setBackgroundColor:[UIColor whiteColor]];
	[self.tabBarController.tabBar addSubview:button];
}

-(void) revealADK {
	[[Analytics getSharedInstance] newADKSession];
	[self performSegueWithIdentifier:ADK_SEGUE sender:self];
}

#pragma mark - Handle Login -

//brings up the create account page if there is no user logged in
-(void) bringUpLogin {
	//TODO: check user defaults and do login if they have logged in before
	[self performSegueWithIdentifier:CREATE_ACCOUNT_SEGUE sender:self];
}

//catches the unwind segue from login / create account or adk
- (IBAction) unwindToMasterNavVC: (UIStoryboardSegue *)segue {
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	if ([segue.identifier isEqualToString: UNWIND_SEGUE_FROM_CREATE_ACCOUNT_TO_MASTER]
		|| [segue.identifier  isEqualToString: UNWIND_SEGUE_FROM_LOGIN_TO_MASTER]) {
		// TODO: have variable set and go to profile or adk
		[self.profileVC updateUserInfo];
	} else if ([segue.identifier isEqualToString: UNWIND_SEGUE_FROM_ADK_TO_MASTER]) {
		[[Analytics getSharedInstance] endOfADKSession];
	}
}

#pragma mark - Media Dev VC Delegate methods -

-(void) povPublishedWithUserName:(NSString *)userName andTitle:(NSString *)title andCoverPic:(UIImage *)coverPhoto andProgressObject:(NSProgress *)progress {
	[self.feedVC showPOVPublishingWithUserName:userName andTitle:title andCoverPic:coverPhoto andProgressObject:progress];
	[self.tabBarController setSelectedViewController:self.feedVC];
}

#pragma mark - Feed VC Delegate -

-(void) showTabBar:(BOOL)show {
	if (show) {
		self.tabBarController.tabBar.frame = self.tabBarFrameOnScreen;
	} else {
		self.tabBarController.tabBar.frame = self.tabBarFrameOffScreen;
	}
}

#pragma mark - Alerts -

-(void)alertPullTrendingIcon {
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Slide the black circle!" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[[UserSetupParameters sharedInstance] set_trendingCirle_InstructionAsShown];
}

#pragma mark - Memory Warning -

- (void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Lazy Instantiation -

-(UserManager*) userManager {
	if (!_userManager) _userManager = [UserManager sharedInstance];
	_userManager.delegate = self;
	return _userManager;
}

@end
