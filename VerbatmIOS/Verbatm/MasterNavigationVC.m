//
//  verbatmMasterNavigationViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 5/20/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "Analytics.h"

#import "CustomTabBarController.h"
#import "ContentDevVC.h"

#import "DiscoverVC.h"
#import "Durations.h"

#import "FeedVC.h"

#import "Icons.h"

#import "MasterNavigationVC.h"

#import "Notifications.h"

#import "ParseBackendKeys.h"
#import "ProfileVC.h"
#import "PublishingProgressManager.h"

#import "StoryboardVCIdentifiers.h"
#import "SegueIDs.h"
#import "SizesAndPositions.h"
#import "Styles.h"

#import "UIImage+ImageEffectsAndTransforms.h"
#import "UserAndChannelListsTVC.h"
#import "User_BackendObject.h"
#import "UserInfoCache.h"
#import "UserSetupParameters.h"

#import <Crashlytics/Crashlytics.h>


@interface MasterNavigationVC () <UITabBarControllerDelegate, FeedVCDelegate,
ProfileVCDelegate>

#pragma mark - Tab Bar Controller -

@property (nonatomic) BOOL migrated;

@property (weak, nonatomic) IBOutlet UIView *tabBarControllerContainerView;
@property (strong, nonatomic) CustomTabBarController* tabBarController;
@property (nonatomic) BOOL tabBarHidden;
@property (nonatomic) CGRect tabBarFrameOnScreen;
@property (nonatomic) CGRect tabBarFrameOffScreen;

#pragma mark View Controllers in tab bar Controller

@property (strong,nonatomic) ProfileVC *profileVC;
@property (strong,nonatomic) FeedVC *feedVC;
@property (strong,nonatomic) DiscoverVC *discoverVC;


#define ANIMATION_NOTIFICATION_DURATION 0.5
#define TIME_UNTIL_ANIMATION_CLEAR 1.5
#define DARK_GRAY 0.6f
#define ADK_BUTTON_SIZE 40.f
#define SELECTED_TAB_ICON_COLOR [UIColor colorWithRed:0.5 green:0.1 blue:0.1 alpha:1.f]

@end

@implementation MasterNavigationVC

- (void)viewDidLoad {
	[super viewDidLoad];
	[self registerForNotifications];
	if ([PFUser currentUser].isAuthenticated) {
		[self checkMigrated];
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

-(BOOL) prefersStatusBarHidden {
	return self.tabBarHidden;
}

- (UIStatusBarAnimation) preferredStatusBarUpdateAnimation {
	return UIStatusBarAnimationSlide;
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


}


-(void)successfullyPublishedNotification:(NSNotification *) notification {
    
    UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Sucessfully Published!                                        " message:@"Remember to share your post! :D" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {}];
    [newAlert addAction:action];
    [self presentViewController:newAlert animated:YES completion:nil];
    
	//todo: bring back image later
    //	[self.view addSubview:self.publishSuccessful];
    //	[self.view bringSubviewToFront:self.publishSuccessful];
    //	[UIView animateWithDuration:REPOST_ANIMATION_DURATION animations:^{
    //		self.publishSuccessful.alpha = 0.f;
    //	}completion:^(BOOL finished) {
    //		[self.publishSuccessful removeFromSuperview];
    //		self.publishSuccessful = nil;
    //	}];
}


-(void)publishingFailedNotification:(NSNotification *) notification{
	NSError *error = notification.object;
	NSString* message = @"Don't worry - we saved all your stuff! Try to publish again later!";
	if (error.code == -1000 && [error.domain isEqualToString:@"com.alamofire.error.serialization.request"]) {
		message = @"We couldn't publish one of your pieces of media - the file was unreadable.";
	}
    UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Ooops...we couldn't publish." message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {}];
    [newAlert addAction:action];
    [self presentViewController:newAlert animated:YES completion:nil];

	//todo: bring back image later
    //	[self.view addSubview:self.publishFailed];
    //	[self.view bringSubviewToFront:self.publishFailed];
    //	[UIView animateWithDuration:REPOST_ANIMATION_DURATION animations:^{
    //		self.publishFailed.alpha = 0.f;
    //	}completion:^(BOOL finished) {
    //		[self.publishFailed removeFromSuperview];
    //		self.publishFailed = nil;
    //	}];
}

-(void)followingSuccessfulNotification:(NSNotification *) notification{
    
    UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Following Successful!" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {}];
    [newAlert addAction:action];
    [self presentViewController:newAlert animated:YES completion:nil];
    
//    [self.view addSubview:self.following];
//    [self.view bringSubviewToFront:self.following];
//    [UIView animateWithDuration:REPOST_ANIMATION_DURATION animations:^{
//        self.following.alpha = 0.f;
//    }completion:^(BOOL finished) {
//        [self.following removeFromSuperview];
//        self.following = nil;
//    }];
}

/* Migrating to one channel */
-(void) checkMigrated {
	self.migrated = NO;
	NSNumber* migratedObject = [[PFUser currentUser] objectForKey:USER_MIGRATED_ONE_CHANNEL];
	if (migratedObject && [migratedObject boolValue]) self.migrated = YES;
	if (!self.migrated) {
		[User_BackendObject migrateUserToOneChannelWithCompletionBlock:^(BOOL success) {
			if (success) {
				self.migrated = YES;
				[[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:USER_MIGRATED_ONE_CHANNEL];
				[[PFUser currentUser] saveInBackground];
			}
			[self setUpStartUpEnvironment];
		}];
	} else {
		[self setUpStartUpEnvironment];
	}
}

-(void) setUpStartUpEnvironment {
	[[UserSetupParameters sharedInstance] setUpParameters];
	self.view.backgroundColor = [UIColor blackColor];
	[[UserInfoCache sharedInstance] loadUserChannelsWithCompletionBlock:^{
		[self setUpTabBarController];
	}];
	if(![[UserSetupParameters sharedInstance] checkFirstTimeFollowBlogShown]){
		[self performSegueWithIdentifier:SEGUE_ONBOARDING_BLOG_SELECT sender:self];
	}
}

#pragma mark - User Manager Delegate -

-(void) loginSucceeded:(NSNotification*) notification {
	PFUser * user = notification.object;
	[[Crashlytics sharedInstance] setUserIdentifier: [user username]];
	[[Crashlytics sharedInstance] setUserName: [user objectForKey:VERBATM_USER_NAME_KEY]];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self checkMigrated];
	});
}

-(void) loginFailed:(NSNotification *) notification {
	NSError* error = (NSError*) notification.object;
	[[Crashlytics sharedInstance] recordError: error];
	//TODO: only do this if have a connection, or only a certain number of times
}

#pragma mark - Tab bar controller -

-(void) setUpTabBarController {
	[self createTabBarViewController];
	[self createViewControllers];

	UIViewController * deadView = [[UIViewController alloc] init];

	UIImage * deadViewTabImage = [self imageWithImage:[[UIImage imageNamed:ADK_NAV_ICON]
													   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
										 scaledToSize:CGSizeMake(30.f, 30.f)];

	deadView.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:deadViewTabImage selectedImage:deadViewTabImage];
	deadView.tabBarItem.imageInsets = UIEdgeInsetsMake(5.f, 0.f, -5.f, 0.f);

	self.tabBarController.viewControllers = @[self.feedVC, self.discoverVC, deadView, self.profileVC];
	//add adk button to tab bar
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
	NSInteger numTabs = self.tabBarController.viewControllers.count;
	CGSize tabBarItemSize = CGSizeMake(self.tabBarController.tabBar.frame.size.width/numTabs,
									   self.tabBarController.tabBarHeight);
	//[self.tabBarController.tabBar setTintColor:SELECTED_TAB_ICON_COLOR];
	// Sets background of unselected UITabBarItem
	[self.tabBarController.tabBar setBackgroundImage: [self getUnselectedTabBarItemImageWithSize: tabBarItemSize]];
	[self.tabBarController.tabBar setBackgroundColor:[UIColor blackColor]];
	// Sets the background color of the selected UITabBarItem
	[self.tabBarController.tabBar setSelectionIndicatorImage: [self getSelectedTabBarItemImageWithSize: tabBarItemSize]];

	//set two tab bar frames-- for when we want to remove the tab bar
	self.tabBarFrameOnScreen = self.tabBarController.tabBar.frame;
	self.tabBarFrameOffScreen = CGRectMake(self.tabBarController.tabBar.frame.origin.x,
										   self.view.frame.size.height + ADK_BUTTON_SIZE/2.f,
										   self.tabBarController.tabBar.frame.size.width,
										   self.tabBarController.tabBarHeight);
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
	self.discoverVC = [self.storyboard instantiateViewControllerWithIdentifier:DISCOVER_VC_ID];

	self.profileVC = [self.storyboard instantiateViewControllerWithIdentifier:PROFILE_VC_ID];
	self.profileVC.delegate = self;
	self.profileVC.ownerOfProfile = [PFUser currentUser];
	self.profileVC.isCurrentUserProfile = YES;
	self.profileVC.channel = [[UserInfoCache sharedInstance] getUserChannel];
	self.profileVC.isProfileTab = YES;

	self.feedVC = [self.storyboard instantiateViewControllerWithIdentifier:FEED_VC_ID];
	self.feedVC.delegate = self;

	self.profileVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@""
															  image:[UIImage imageNamed:PROFILE_NAV_ICON]
													  selectedImage:[UIImage imageNamed:PROFILE_NAV_ICON]];
	self.feedVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@""
															  image:[UIImage imageNamed:HOME_NAV_ICON]
													  selectedImage:[UIImage imageNamed:HOME_NAV_ICON]];
	self.discoverVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@""
															   image:[UIImage imageNamed:DISCOVER_NAV_ICON]
													   selectedImage:[UIImage imageNamed:DISCOVER_NAV_ICON]];

	// images need to be centered this way for some reason
	self.profileVC.tabBarItem.imageInsets = UIEdgeInsetsMake(5.f, 0.f, -5.f, 0.f);
	//    self.channelListView.tabBarItem.imageInsets = UIEdgeInsetsMake(5.f, 0.f, -5.f, 0.f);
	self.discoverVC.tabBarItem.imageInsets = UIEdgeInsetsMake(5.f, 0.f, -5.f, 0.f);
	self.feedVC.tabBarItem.imageInsets = UIEdgeInsetsMake(5.f, 0.f, -5.f, 0.f);
}

-(void)createTabBarViewController {
	self.tabBarControllerContainerView.frame = self.view.bounds;
	self.tabBarController = [self.storyboard instantiateViewControllerWithIdentifier: TAB_BAR_CONTROLLER_ID];
	self.tabBarController.tabBarHeight = TAB_BAR_HEIGHT;
	[self.tabBarControllerContainerView addSubview:self.tabBarController.view];
	[self addChildViewController:self.tabBarController];
	self.tabBarController.delegate = self;
}

// Create a custom UIButton and add it over our adk icon
-(void) addTabBarCenterButtonOverDeadView {

	NSInteger numTabs = self.tabBarController.viewControllers.count;
	CGFloat tabWidth = self.tabBarController.tabBar.frame.size.width/numTabs;
	// covers up tab so that it won't go to blank view controller
	// Center tab out of 3
	UIView* tabView = [[UIView alloc] initWithFrame:CGRectMake(tabWidth*2, 0.f, tabWidth,
															   self.tabBarController.tabBarHeight)];
	[tabView setBackgroundColor:[UIColor clearColor]];

	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = tabView.frame;
	[button setBackgroundColor:[UIColor clearColor]];
	[button addTarget:self action:@selector(revealADK) forControlEvents:UIControlEventTouchUpInside];

	//[self.tabBarController.tabBar addSubview:tabView];
	[self.tabBarController.tabBar addSubview:button];
}

-(void) revealADK {
	//Clear memory from discover when bring up adk
	NSNotification * not = [[NSNotification alloc]initWithName:NOTIFICATION_FREE_MEMORY_DISCOVER object:nil userInfo:nil];
	[[NSNotificationCenter defaultCenter] postNotification:not];
	[[Analytics getSharedInstance] newADKSession];
	[self performSegueWithIdentifier:ADK_SEGUE sender:self];
}


-(void)userHasSignedOutNotification:(NSNotification *) notification{
	[self bringUpLogin];
}

#pragma mark - Handle Login -

//brings up the create account page if there is no user logged in
-(void) bringUpLogin {
	[self performSegueWithIdentifier:SIGN_IN_SEGUE sender:self];
}

//catches the unwind segue from login / create account or adk
- (IBAction) unwindToMasterNavVC: (UIStoryboardSegue *)segue {
    
	if ([segue.identifier isEqualToString: UNWIND_SEGUE_FROM_ADK_TO_MASTER]) {
		if ([[PublishingProgressManager sharedInstance] currentlyPublishing]) {
			[self.tabBarController setSelectedViewController:self.profileVC];
			[self.profileVC showPublishingProgress];
		}
		[[Analytics getSharedInstance] endOfADKSession];
	} else if ([segue.identifier isEqualToString: UNWIND_SEGUE_FROM_USER_SETTINGS_TO_LOGIN] ||
               [segue.identifier isEqualToString: UNWIND_SEGUE_FROM_LOGIN_TO_MASTER]) {


	}
}

#pragma mark - Feed VC Delegate -

-(void) showTabBar:(BOOL)show {
	if (show) {
		self.tabBarHidden = NO;
		[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
			[self setNeedsStatusBarAppearanceUpdate];
			self.tabBarController.tabBar.frame = self.tabBarFrameOnScreen;
		}];
	} else {
		self.tabBarHidden = YES;
		[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
			[self setNeedsStatusBarAppearanceUpdate];
			self.tabBarController.tabBar.frame = self.tabBarFrameOffScreen;
		}];
	}
}

//show the channels the current user can select to follow
-(void)presentChannelsToFollow{
	//[self presentShareSelectionViewStartOnChannels:YES];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{

}

#pragma mark - Memory Warning -

- (void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
	if (self.tabBarController.selectedViewController != self.discoverVC) {
		NSNotification * not = [[NSNotification alloc]initWithName:NOTIFICATION_FREE_MEMORY_DISCOVER object:nil userInfo:nil];
		[[NSNotificationCenter defaultCenter] postNotification:not];
	}
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
