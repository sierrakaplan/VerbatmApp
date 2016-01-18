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

#import "CustomTabBarController.h"
#import "ContentDevVC.h"
#import "Channel.h"
#import "CreateNewChannelView.h"
#import "ChannelOrUsernameCV.h"


#import "Durations.h"

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

#import "StoryboardVCIdentifiers.h"
#import "SharePOVView.h"
#import "SegueIDs.h"
#import "SizesAndPositions.h"
#import "Styles.h"

#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

#import "UIImage+ImageEffectsAndTransforms.h"
#import "UserSetupParameters.h"
#import "UserManager.h"
#import "UserPovInProgress.h"
#import "UserAndChannelListsTVC.h"


#import "VerbatmCameraView.h"

#import <Crashlytics/Crashlytics.h>


@interface MasterNavigationVC () <UITabBarControllerDelegate, FeedVCDelegate, ProfileVCDelegate, CreateNewChannelViewProtocol, SharePOVViewDelegate, UserAndChannelListsTVCDelegate>

#pragma mark - Tab Bar Controller -
@property (weak, nonatomic) IBOutlet UIView *tabBarControllerContainerView;
@property (strong, nonatomic) CustomTabBarController* tabBarController;
@property (nonatomic) CGRect tabBarFrameOnScreen;
@property (nonatomic) CGRect tabBarFrameOffScreen;

@property (strong, nonatomic) CreateNewChannelView * createNewChannelView;

@property (nonatomic) UIView * darkScreenCover;


#pragma mark View Controllers in tab bar Controller

@property (strong,nonatomic) ProfileVC* profileVC;
@property (strong,nonatomic) FeedVC * feedVC;

@property (nonatomic) SharePOVView * sharePOVView;

@property (nonatomic) UserAndChannelListsTVC * channelListView;

#define ANIMATION_NOTIFICATION_DURATION 0.5
#define TIME_UNTIL_ANIMATION_CLEAR 1.5



#define DARK_GRAY 0.6f
#define ADK_BUTTON_SIZE 40.f
#define SELECTED_TAB_ICON_COLOR [UIColor colorWithRed:0.5 green:0.1 blue:0.1 alpha:1.f]

#define CHANNEL_CREATION_VIEW_WALLOFFSET_X 30.f
#define CHANNEL_CREATION_VIEW_Y_OFFSET (PROFILE_NAV_BAR_HEIGHT + 90.f)
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
    
    UIViewController * deadView = [[UIViewController alloc] init];
    
    UIImage * deadViewTabImage = [self imageWithImage:[[UIImage imageNamed:ADK_NAV_ICON]
                                                       imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                        scaledToSize:CGSizeMake(40.f, 40.f)];
    
    deadView.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:deadViewTabImage selectedImage:nil];
    deadView.tabBarItem.imageInsets = UIEdgeInsetsMake(5.f, 0.f, -5.f, 0.f);

    self.tabBarController.viewControllers = @[self.profileVC, deadView, self.feedVC, self.channelListView];
    //add adk button to tab bar
	[self addTabBarCenterButtonOverDeadView];
    self.tabBarController.selectedViewController = self.profileVC;
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
	[self.tabBarController.tabBar setTintColor:SELECTED_TAB_ICON_COLOR];
	// Sets background of unselected UITabBarItem
	[self.tabBarController.tabBar setBackgroundImage: [self getUnselectedTabBarItemImageWithSize: tabBarItemSize]];
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
	return [UIImage makeImageWithColorAndSize:[UIColor colorWithWhite:1.0 alpha:TAB_BAR_ALPHA]
									  andSize: size];
}

-(UIImage*) getSelectedTabBarItemImageWithSize: (CGSize) size {
	return [UIImage makeImageWithColorAndSize:[UIColor colorWithWhite:DARK_GRAY alpha:TAB_BAR_ALPHA]
									  andSize: size];
}

//the view controllers that will be tabbed
-(void)createViewControllers {
    
    self.channelListView = [[UserAndChannelListsTVC alloc] init];
    self.channelListView.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Search"
                                                                    image:nil
                                                            selectedImage:nil];
    
    [self.channelListView presentAllVerbatmChannels];
    
    self.channelListView.listDelegate = self;
    
    
     
    self.profileVC = [self.storyboard instantiateViewControllerWithIdentifier:PROFILE_VC_ID];
    
    self.profileVC.delegate = self;
    self.profileVC.isCurrentUserProfile = YES;
    self.feedVC = [self.storyboard instantiateViewControllerWithIdentifier:FEED_VC_ID];
    self.feedVC.delegate = self;

	self.profileVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@""
															  image:[[UIImage imageNamed:PROFILE_NAV_ICON]
																	 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
													  selectedImage:[UIImage imageNamed:PROFILE_NAV_ICON]]; //imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

	self.feedVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@""
															  image:[[UIImage imageNamed:HOME_NAV_ICON]
																	 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
													  selectedImage:[UIImage imageNamed:HOME_NAV_ICON]]; //imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
	// images need to be centered this way for some reason
	self.profileVC.tabBarItem.imageInsets = UIEdgeInsetsMake(5.f, 0.f, -5.f, 0.f);
	self.feedVC.tabBarItem.imageInsets = UIEdgeInsetsMake(5.f, 0.f, -5.f, 0.f);
}

-(void)createTabBarViewController{
    self.tabBarControllerContainerView.frame = self.view.bounds;
    self.tabBarController = [self.storyboard instantiateViewControllerWithIdentifier: TAB_BAR_CONTROLLER_ID];
	self.tabBarController.tabBarHeight = TAB_BAR_HEIGHT;
    [self.tabBarControllerContainerView addSubview:self.tabBarController.view];
    [self addChildViewController:self.tabBarController];
    self.tabBarController.delegate = self;
}

// Create a custom UIButton and add it over our adk icon
-(void) addTabBarCenterButtonOverDeadView{

	NSInteger numTabs = self.tabBarController.viewControllers.count;
	CGFloat tabWidth = self.tabBarController.tabBar.frame.size.width/numTabs;
	// covers up tab so that it won't go to blank view controller
	// Center tab out of 3
	UIView* tabView = [[UIView alloc] initWithFrame:CGRectMake(tabWidth, 0.f, tabWidth,
															self.tabBarController.tabBarHeight)];
	[tabView setBackgroundColor:[UIColor clearColor]];

	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = tabView.frame;
	[button setBackgroundColor:[UIColor clearColor]];
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
	if ([segue.identifier  isEqualToString: UNWIND_SEGUE_FROM_LOGIN_TO_MASTER]) {
		// TODO: have variable set and go to profile or adk
		[self.profileVC updateUserInfo];
	} else if ([segue.identifier isEqualToString: UNWIND_SEGUE_FROM_ADK_TO_MASTER]) {
        
        [self playContentOnSelectedViewController:YES];
		[[Analytics getSharedInstance] endOfADKSession];
	}
}

//prepare for segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:ADK_SEGUE])
    {
        // Get reference to the destination view controller
         ContentDevVC * vc = [segue destinationViewController];
        
        
        //get the channels that the user owns here
        
        Channel * enterpreneurship = [[Channel alloc] initWithChannelName:@"Entrepreneurship" numberOfFollowers:@(50) andUserName:@"Iain Usiri"];
        
        Channel * socialJustice = [[Channel alloc] initWithChannelName:@"Social Justice" numberOfFollowers:@(500) andUserName:@"Iain Usiri"];
        
        Channel * music = [[Channel alloc] initWithChannelName:@"Music" numberOfFollowers:@(10000) andUserName:@"Iain Usiri"];
        vc.userChannels = @[enterpreneurship, socialJustice, music];
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
		[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
			self.tabBarController.tabBar.frame = self.tabBarFrameOnScreen;
		}];
	} else {
		[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
			self.tabBarController.tabBar.frame = self.tabBarFrameOffScreen;
		}];
	}
}

//show the list of followers of the current user
-(void)presentFollowersListMyID:(id) userID {
    UserAndChannelListsTVC * newList = [[UserAndChannelListsTVC alloc] init];
    [newList presentChannelsForUser:userID shouldDisplayFollowers:YES];
    newList.listDelegate = self;
    
    [self presentViewController:newList animated:YES completion:^{
        
    }];
    
}
//show list of people the user follows
-(void)presentWhoIFollowMyID:(id) userID {
    
    UserAndChannelListsTVC * newList = [[UserAndChannelListsTVC alloc] init];
    [newList presentWhoIsFollowedBy:userID];
    newList.listDelegate = self;
    
    [self presentViewController:newList animated:YES completion:^{
        
    }];
    
    
    
}

//show the channels the current user can select to follow
-(void)presentChannelsToFollow{
    [self presentShareSelectionViewStartOnChannels:YES];
}

-(void)profilePovShareButtonSeletedForPOV:(PovInfo *) pov{
    [self presentShareSelectionViewStartOnChannels:NO];
}

-(void)profilePovLikeLiked:(BOOL) liked forPOV:(PovInfo *) pov{
    
}

-(void)feedPovShareButtonSeletedForPOV:(PovInfo *) pov {
    [self presentShareSelectionViewStartOnChannels:NO];
}


-(void)feedPovLikeLiked:(BOOL) liked forPOV:(PovInfo *) pov {
    
    
    
}

-(void)presentShareSelectionViewStartOnChannels:(BOOL) startOnChannels{
    if(self.sharePOVView){
        [self.sharePOVView removeFromSuperview];
        self.sharePOVView = nil;
    }
    
    
    //temp
    //simulates getting threads
    Channel * enterpreneurship = [[Channel alloc] initWithChannelName:@"Entrepreneurship" numberOfFollowers:@(50) andUserName:@"Iain Usiri"];
    
    Channel * socialJustice = [[Channel alloc] initWithChannelName:@"Social Justice" numberOfFollowers:@(500) andUserName:@"Iain Usiri"];
    
    Channel * music = [[Channel alloc] initWithChannelName:@"Music" numberOfFollowers:@(10000) andUserName:@"Iain Usiri"];
    
    
    CGRect onScreenFrame = CGRectMake(0.f, self.view.frame.size.height/2.f, self.view.frame.size.width, self.view.frame.size.height/2.f);
    CGRect offScreenFrame = CGRectMake(0.f, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.f);
    self.sharePOVView = [[SharePOVView alloc] initWithFrame:offScreenFrame andChannels:@[enterpreneurship, socialJustice, music] shouldStartOnChannels:startOnChannels];
    self.sharePOVView.delegate = self;
    [self.view addSubview:self.sharePOVView];
    [self.view bringSubviewToFront:self.sharePOVView];
    [UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
        self.sharePOVView.frame = onScreenFrame;
    }];
}

-(void)removeSharePOVView{
    if(self.sharePOVView){
        CGRect offScreenFrame = CGRectMake(0.f, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.f);
        
        [UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
            self.sharePOVView.frame = offScreenFrame;
        }completion:^(BOOL finished) {
            if(finished){
                [self.sharePOVView removeFromSuperview];
                self.sharePOVView = nil;
            }
        }];
    }
}


#pragma mark -Share Seletion View Protocol -
-(void)cancelButtonSelected{
    [self removeSharePOVView];
}
-(void)postPOVToChannel:(Channel *) channel {
    
}
-(void)sharePostWithComment:(NSString *) comment{
    
}


#pragma mark -create new channel prompt-
//notified from selection of channel bar to prompt the user to creat a new channel
-(void) createNewChannel{
    if(!self.createNewChannelView){
        [self darkenScreen];
        CGFloat viewHeight = self.view.frame.size.height/2.f -
                            (CHANNEL_CREATION_VIEW_WALLOFFSET_X *7);
        
        CGRect newChannelViewFrame = CGRectMake(CHANNEL_CREATION_VIEW_WALLOFFSET_X, CHANNEL_CREATION_VIEW_Y_OFFSET, self.view.frame.size.width - (CHANNEL_CREATION_VIEW_WALLOFFSET_X *2),viewHeight);
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

-(void)removeScreenDarkener{
    if(self.darkScreenCover){
        [self.darkScreenCover removeFromSuperview];
        self.darkScreenCover = nil;
    }
}

//new channel view creation protocol
-(void) cancelCreation{
    [self clearChannelCreationView];
}
-(void) createChannelWithName:(NSString *) channelName{
    //create a new channel and save it
    [self clearChannelCreationView];
}


-(void)clearChannelCreationView{
    if(self.createNewChannelView){
        [self removeScreenDarkener];
        [self.createNewChannelView removeFromSuperview];
        self.createNewChannelView = nil;
    }
}



#pragma mark - Delegate for channel list view -
-(void)openChannel:(Channel *) channel {
    
}

-(void)selectedUser:(id)userId {
    
}

//either you specify a start channel or you send in nil which goes to default
-(void)presentUserProfileWithChannel:(Channel *) specificChannel{
    
    if(specificChannel){
        
    }else{
        
    }
    
    
    
}

#pragma mark - Memory Warning -

- (void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
