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

#import "CustomTabBarItem.h"

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


/*

 New navigation: Feed, profile, and adk should be in a UITabBarController. Implement delegate to perform segue when they
 are selected. Set each view controller's tabbaritem (with title + image + selected image)
 
 Segue to login if profile or adk are selected and they aren't signed in
 
 Article display should segue from the feed vc 
 
 ADk should use a custom bar for the pull bar but a navigation bar on top
 
 Preview should use a navigation bar
 
 Profile will have a custom bar
 
 
 */


@interface MasterNavigationVC () <UITabBarControllerDelegate, UserManagerDelegate, MediaDevVCDelegate>

#pragma mark - Tab Bar Controller -
@property (weak, nonatomic) IBOutlet UIView *tabBarControllerContainerView;
@property (strong, nonatomic) UITabBarController* tabBarController;

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
	[self formatTabBarVC];
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

-(void) formatTabBarVC {
	self.tabBarControllerContainerView.frame = self.view.bounds;
	self.tabBarController = [self.storyboard instantiateViewControllerWithIdentifier: TAB_BAR_CONTROLLER_ID];
	[self.tabBarControllerContainerView addSubview:self.tabBarController.view];
	[self addChildViewController:self.tabBarController];
	self.tabBarController.delegate = self;

	//TODO: remake icons
	CGSize iconSize = CGSizeMake(30, 30);
	self.profileVC = [self.storyboard instantiateViewControllerWithIdentifier:PROFILE_VC_ID];
	self.profileVC.tabBarItem = [[CustomTabBarItem alloc] initWithTitle:@"" image:[[UIImage imageNamed:PROFILE_NAV_ICON] scaleImageToSize:iconSize] tag:0];

	self.mediaDevVC = [self.storyboard instantiateViewControllerWithIdentifier:MEDIA_DEV_VC_ID];
	self.mediaDevVC.delegate = self;

	self.feedVC = [self.storyboard instantiateViewControllerWithIdentifier:FEED_VC_ID];
	self.feedVC.tabBarItem = [[CustomTabBarItem alloc] initWithTitle:@"" image:[[UIImage imageNamed:HOME_NAV_ICON] scaleImageToSize:iconSize] tag:0];

	self.tabBarController.viewControllers = @[self.profileVC, [[UIViewController alloc] init], self.feedVC];
	self.tabBarController.selectedViewController = self.feedVC;
	UIImage* adkImage = [[UIImage imageNamed:ADK_NAV_ICON] scaleImageToSize:iconSize];
	[self addTabBarCenterButtonWithImage:adkImage highlightImage:adkImage];
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addTabBarCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage {

	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
	button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
	[button setBackgroundImage:buttonImage forState:UIControlStateNormal];
	[button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(revealADK) forControlEvents:UIControlEventTouchUpInside];

	CGFloat heightDifference = buttonImage.size.height - self.tabBarController.tabBar.frame.size.height;
	if (heightDifference < 0)
		button.center = self.tabBarController.tabBar.center;
	else {
		CGPoint center = self.tabBarController.tabBar.center;
		center.y = center.y - heightDifference/2.0;
		button.center = center;
	}

	[self.tabBarController.view addSubview:button];
}

-(void) revealADK {
	[self performSegueWithIdentifier:ADK_SEGUE sender:self];
}

/*TODO: apply some analytics
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    

    if(scrollView == self.masterSV){
        if(self.feedContainer.frame.origin.x == scrollView.contentOffset.x){
            //in the feed
            [[Analytics getSharedInstance] endOfADKSession];
        }else if (self.adkContainer.frame.origin.x == scrollView.contentOffset.x){
            //in the adk
            [[Analytics getSharedInstance] newADKSession];
        }
    }
}*/

#pragma mark - Handle Login -

//brings up the create account page if there is no user logged in
-(void) bringUpLogin {
	//TODO: check user defaults and do login if they have logged in before
	[self performSegueWithIdentifier:CREATE_ACCOUNT_SEGUE sender:self];
}

//catches the unwind segue from login / create account
- (IBAction) unwindToMasterNavVC: (UIStoryboardSegue *)segue {
	// TODO: have variable set and go to profile or adk
	[self.profileVC updateUserInfo];
}

#pragma mark - Media Dev VC Delegate methods -

-(void) povPublishedWithUserName:(NSString *)userName andTitle:(NSString *)title andCoverPic:(UIImage *)coverPhoto andProgressObject:(NSProgress *)progress {
	[self.feedVC showPOVPublishingWithUserName:userName andTitle:title andCoverPic:coverPhoto andProgressObject:progress];
	[self.tabBarController setSelectedViewController:self.feedVC];
}

#pragma mark - Alerts -

-(void)alertPullTrendingIcon {
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Slide the black circle!" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[[UserSetupParameters sharedInstance]set_trendingCirle_InstructionAsShown];
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
