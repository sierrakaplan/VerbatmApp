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

#import <Crashlytics/Crashlytics.h>


@interface MasterNavigationVC () <UITabBarControllerDelegate, FeedVCDelegate, ProfileVCDelegate>

#pragma mark - Tab Bar Controller -
@property (weak, nonatomic) IBOutlet UIView *tabBarControllerContainerView;
@property (strong, nonatomic) UITabBarController* tabBarController;
@property (nonatomic) CGRect tabBarFrameOnScreen;
@property (nonatomic) CGRect tabBarFrameOffScreen;

#pragma mark View Controllers in tab bar Controller

@property (strong,nonatomic) ProfileVC* profileVC;
@property (strong,nonatomic) FeedVC * feedVC;

#define ANIMATION_NOTIFICATION_DURATION 0.5
#define TIME_UNTIL_ANIMATION_CLEAR 1.5

#define TAB_BAR_CONTROLLER_ID @"main_tab_bar_controller"
#define FEED_VC_ID @"feed_vc"
#define MEDIA_DEV_VC_ID @"media_dev_vc"
#define PROFILE_VC_ID @"profile_vc"

#define DARK_GRAY 0.f
#define TAB_BAR_ALPHA 0.4
#define ADK_BUTTON_SIZE 60.f

@end

@implementation MasterNavigationVC

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setUpTabBarController];
	[self registerForNotifications];
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

-(void) registerForNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loginFailed:)
												 name:NOTIFICATION_USER_LOGIN_FAILED
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loginSucceeded:)
												 name:NOTIFICATION_USER_LOGIN_SUCCEEDED
											   object:nil];
}

#pragma mark - User Manager Delegate -

-(void) loginSucceeded:(NSNotification*) notification {
	GTLVerbatmAppVerbatmUser* user = notification.object;
	[[Crashlytics sharedInstance] setUserEmail: user.email];
	[[Crashlytics sharedInstance] setUserName: user.name];
	[self.profileVC updateUserInfo];
}

-(void) loginFailed:(NSNotification *) notification {
	NSError* error = (NSError*) notification.object;
	NSLog(@"Error finding current user: %@", error.description);
	//TODO: only do this if have a connection, or only a certain number of times
//	[[UserManager sharedInstance] queryForCurrentUser];
}

#pragma mark - Tab bar controller -

-(void) setUpTabBarController {
    [self createTabBarViewController];
    [self createViewControllers];
    self.tabBarController.viewControllers = @[self.profileVC, [[UIViewController alloc] init], self.feedVC];
    //add adk button to tab bar
	[self addTabBarCenterButtonWithImage:[UIImage imageNamed:ADK_NAV_ICON]];
    self.tabBarController.selectedViewController = self.profileVC;
	[self formatTabBar];
}

-(void) formatTabBar {
	NSInteger numTabs = self.tabBarController.viewControllers.count;
	CGSize tabBarItemSize = CGSizeMake(self.tabBarController.tabBar.frame.size.width/numTabs,
									   self.tabBarController.tabBar.frame.size.height);
	// Sets background of unselected UITabBarItem
	[self.tabBarController.tabBar setBackgroundImage: [self getUnselectedTabBarItemImageWithSize: tabBarItemSize]];
	// Sets the background color of the selected UITabBarItem
	[self.tabBarController.tabBar setSelectionIndicatorImage: [self getSelectedTabBarItemImageWithSize: tabBarItemSize]];

	//set two tab bar frames-- for when we want to remove the tab bar
	self.tabBarFrameOnScreen = self.tabBarController.tabBar.frame;
	self.tabBarFrameOffScreen = CGRectMake(self.tabBarController.tabBar.frame.origin.x,
										   self.view.frame.size.height + ADK_BUTTON_SIZE/2.f,
										   self.tabBarController.tabBar.frame.size.width,
										   self.tabBarController.tabBar.frame.size.height);
}

-(UIImage*) getUnselectedTabBarItemImageWithSize: (CGSize) size {
	return [UIImage makeImageWithColorAndSize:[UIColor colorWithWhite:1.0 alpha:TAB_BAR_ALPHA]
									  andSize: size];
}

-(UIImage*) getSelectedTabBarItemImageWithSize: (CGSize) size {
	return [UIImage makeImageWithColorAndSize:[UIColor colorWithWhite:DARK_GRAY alpha:TAB_BAR_ALPHA]
									  andSize: size];
}

//the view controllers that will be tabbed
-(void)createViewControllers {
    self.profileVC = [self.storyboard instantiateViewControllerWithIdentifier:PROFILE_VC_ID];
    self.profileVC.delegate = self;

    self.feedVC = [self.storyboard instantiateViewControllerWithIdentifier:FEED_VC_ID];
    self.feedVC.delegate = self;

	self.profileVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@""
															  image:[[UIImage imageNamed:PROFILE_NAV_ICON]
																	 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
													  selectedImage:[[UIImage imageNamed:PROFILE_NAV_ICON]
																	 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

	self.feedVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@""
															  image:[[UIImage imageNamed:HOME_NAV_ICON]
																	 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
													  selectedImage:[[UIImage imageNamed:HOME_NAV_ICON]
																	 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
	// images need to be centered this way for some reason
	self.profileVC.tabBarItem.imageInsets = UIEdgeInsetsMake(5.f, 0.f, -5.f, 0.f);
	self.feedVC.tabBarItem.imageInsets = UIEdgeInsetsMake(5.f, 0.f, -5.f, 0.f);
}

-(void)createTabBarViewController{
    self.tabBarControllerContainerView.frame = self.view.bounds;
    self.tabBarController = [self.storyboard instantiateViewControllerWithIdentifier: TAB_BAR_CONTROLLER_ID];
    [self.tabBarControllerContainerView addSubview:self.tabBarController.view];
    [self addChildViewController:self.tabBarController];
    self.tabBarController.delegate = self;
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addTabBarCenterButtonWithImage:(UIImage*)buttonImage {

	NSInteger numTabs = self.tabBarController.viewControllers.count;
	CGFloat tabWidth = self.tabBarController.tabBar.frame.size.width/numTabs;
	// covers up tab so that it won't go to blank view controller
	// Center tab out of 3
	UIView* tabView = [[UIView alloc] initWithFrame:CGRectMake(tabWidth, 0.f, tabWidth,
															self.tabBarController.tabBar.frame.size.height)];
	[tabView setBackgroundColor:[UIColor clearColor]];

	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(tabWidth + tabWidth/2.f - ADK_BUTTON_SIZE/2.f, -(ADK_BUTTON_SIZE/2.f),
							  ADK_BUTTON_SIZE, ADK_BUTTON_SIZE);
	[button setBackgroundColor:[UIColor clearColor]];
	[button.imageView setContentMode:UIViewContentModeScaleAspectFill];
	[button setBackgroundImage:buttonImage forState:UIControlStateNormal];
	[button addTarget:self action:@selector(revealADK) forControlEvents:UIControlEventTouchUpInside];

	[self.tabBarController.tabBar addSubview:tabView];
	[self.tabBarController.tabBar addSubview:button];
}

-(void) revealADK {
	[[Analytics getSharedInstance] newADKSession];
    [self playContentOnSelectedViewController:NO];
	[self performSegueWithIdentifier:ADK_SEGUE sender:self];
}

#pragma mark - Handle Login -

//brings up the create account page if there is no user logged in
-(void) bringUpLogin {
	//TODO: check user defaults and do login if they have logged in before
	[self performSegueWithIdentifier:SIGN_IN_SEGUE sender:self];
}

//catches the unwind segue from login / create account or adk
- (IBAction) unwindToMasterNavVC: (UIStoryboardSegue *)segue {
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	if ([segue.identifier  isEqualToString: UNWIND_SEGUE_FROM_LOGIN_TO_MASTER]) {
		// TODO: have variable set and go to profile or adk
		[self.profileVC updateUserInfo];
	} else if ([segue.identifier isEqualToString: UNWIND_SEGUE_FROM_ADK_TO_MASTER]) {
        
        [self playContentOnSelectedViewController:YES];
		[[Analytics getSharedInstance] endOfADKSession];
	}
}

-(void) playContentOnSelectedViewController:(BOOL) shoulPlay{
    
    if(shoulPlay){
        UIViewController * currentViewController = self.tabBarController.viewControllers[self.tabBarController.selectedIndex];
        
        if(currentViewController == self.feedVC){
            [self.feedVC onScreen];
        }else if (currentViewController == self.profileVC){
            [self.profileVC onScreen];
        }
    }else{
        UIViewController * currentViewController = self.tabBarController.viewControllers[self.tabBarController.selectedIndex];
        
        if(currentViewController == self.feedVC){
            [self.feedVC offScreen];
        }else if (currentViewController == self.profileVC){
            [self.profileVC offScreen];
        }
    }
}

#pragma mark - Media Dev VC Delegate methods -

// TODO: make this a notification and change this to the profile vc
-(void) povPublishedWithUserName:(NSString *)userName andTitle:(NSString *)title andProgressObject:(NSProgress *)progress {
//	[self.tabBarController setSelectedViewController:self.feedVC];
}

#pragma mark - Feed VC Delegate -

-(void) showTabBar:(BOOL)show {
	if (show) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO];
		self.tabBarController.tabBar.frame = self.tabBarFrameOnScreen;
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:YES];
		self.tabBarController.tabBar.frame = self.tabBarFrameOffScreen;
	}
}

#pragma mark - Memory Warning -

- (void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
