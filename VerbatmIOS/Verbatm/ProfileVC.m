//
//  profileVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//
#import "ArticleDisplayVC.h"

#import "Channel.h"
#import "CreateNewChannelView.h"

#import "Durations.h"

#import "GTLVerbatmAppVerbatmUser.h"

#import "LocalPOVs.h"

#import "POVScrollView.h"
#import "ProfileVC.h"
#import "ProfileNavBar.h"
#import "POVLoadManager.h"

#import "SegueIDs.h"
#import "SizesAndPositions.h"
#import "SettingsVC.h"
#import "UserManager.h"
#import "SharePOVView.h"

@interface ProfileVC() <ArticleDisplayVCDelegate, ProfileNavBarDelegate,UIScrollViewDelegate,CreateNewChannelViewProtocol>

@property (strong, nonatomic) POVScrollView* povScrollView;
@property (nonatomic, strong) ProfileNavBar* profileNavBar;
@property (nonatomic) CGRect profileNavBarFrameOnScreen;
@property (nonatomic) CGRect profileNavBarFrameOffScreen;
@property (nonatomic) BOOL contentCoveringScreen;
@property (weak, nonatomic) GTLVerbatmAppVerbatmUser* currentUser;
@property (strong, nonatomic) ArticleDisplayVC * postDisplayVC;
@property (nonatomic, strong) NSString * currentThreadInView;

@property (strong, nonatomic) NSArray* channels;

@property (strong, nonatomic) CreateNewChannelView * createNewChannelView;

#define CHANNEL_CREATION_VIEW_WALLOFFSET_X 30.f

@end

@implementation ProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
	self.contentCoveringScreen = YES;
    
    //this is where you'd fetch the threads
    [self getChannelsWithCompletionBlock:^{
        [self addPOVScrollView];
        [self createNavigationBar];
        [self addClearScreenGesture];
    }];
    
}

//this is where downloading of channels should happen
-(void) getChannelsWithCompletionBlock:(void(^)())block{
    
    Channel * enterpreneurship = [[Channel alloc] initWithChannelName:@"Entrepreneurship" numberOfFollowers:@(50) andUserName:@"Iain Usiri"];
    
    Channel * socialJustice = [[Channel alloc] initWithChannelName:@"Social Justice" numberOfFollowers:@(500) andUserName:@"Iain Usiri"];
    
    Channel * music = [[Channel alloc] initWithChannelName:@"Music" numberOfFollowers:@(10000) andUserName:@"Iain Usiri"];
    
    
    self.channels = @[enterpreneurship, socialJustice, music];
    block();//after downloading threads we call this block to build the profile
}



-(void) viewWillAppear:(BOOL)animated{
    NSString * channel = ((Channel *)self.channels[0]).name;
    
    [[LocalPOVs sharedInstance] getPOVsFromChannel:channel].then(^(NSArray* povs) {
        [self.povScrollView displayPOVs: povs];
        [self.povScrollView playPOVOnScreen];
    });
//    [self createContentListViewWithStartThread:testThreads[0]];
	
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}


-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.povScrollView clearPOVs];
}

-(void) addPOVScrollView {
	self.povScrollView = [[POVScrollView alloc] initWithFrame:self.view.bounds];
    self.povScrollView.delegate = self;
	[self.view addSubview:self.povScrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	[self.povScrollView playPOVOnScreen];
}

-(void) createContentListViewWithStartThread:(NSString *)startThread{
    self.postDisplayVC = [self.storyboard instantiateViewControllerWithIdentifier:ARTICLE_DISPLAY_VC_ID];
    self.postDisplayVC.view.frame = self.view.bounds;
    self.postDisplayVC.view.backgroundColor = [UIColor blackColor];
    [self.postDisplayVC presentContentWithPOVType:POVTypeUser andChannel:startThread];
    
    self.currentThreadInView = startThread;
    
    [self addChildViewController:self.postDisplayVC];
    [self.view addSubview:self.postDisplayVC.view];
    [self.postDisplayVC didMoveToParentViewController:self];
    self.postDisplayVC.delegate = self;
}

-(void) createNavigationBar {
    //frame when on screen
    self.profileNavBarFrameOnScreen = CGRectMake(0.f, 0.f, self.view.frame.size.width, PROFILE_NAV_BAR_HEIGHT);
    //frame when off screen
	self.profileNavBarFrameOffScreen = CGRectMake(0.f, - PROFILE_NAV_BAR_HEIGHT, self.view.frame.size.width, PROFILE_NAV_BAR_HEIGHT);
    [self updateUserInfo];
    self.profileNavBar = [[ProfileNavBar alloc] initWithFrame:self.profileNavBarFrameOnScreen
												   andChannels:self.channels andUserName:self.currentUser.name];
    self.profileNavBar.delegate = self;
    [self.view addSubview:self.profileNavBar];
    
}

-(void) updateUserInfo {
    self.currentUser = [[UserManager sharedInstance] getCurrentUser];
}

-(void)addClearScreenGesture{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearScreen:)];
    [self.povScrollView addGestureRecognizer:tap];
}

#pragma mark - Profile Nav Bar Delegate Methods -

-(void) settingsButtonClicked {
	// TODO: go to settings
    [self performSegueWithIdentifier:SETTINGS_PAGE_MODAL_SEGUE sender:self];
    
}

//notified from selection of channel bar to prompt the user to creat a new channel
-(void) createNewChannel{
    CGRect newChannelViewFrame = CGRectMake(CHANNEL_CREATION_VIEW_WALLOFFSET_X, PROFILE_NAV_BAR_HEIGHT + CHANNEL_CREATION_VIEW_WALLOFFSET_X, self.view.frame.size.width - (CHANNEL_CREATION_VIEW_WALLOFFSET_X *2), self.view.frame.size.height/2.f - PROFILE_NAV_BAR_HEIGHT - (CHANNEL_CREATION_VIEW_WALLOFFSET_X *4));
    self.createNewChannelView = [[CreateNewChannelView alloc] initWithFrame:newChannelViewFrame];
    self.createNewChannelView.delegate = self;
    [self.view addSubview:self.createNewChannelView];
    [self.view bringSubviewToFront:self.createNewChannelView];
}

//new channel view creation protocol
-(void) cancelCreation{
    [self.createNewChannelView removeFromSuperview];
    self.createNewChannelView = nil;
}
-(void) createChannelWithName:(NSString *) channelName{
        //create a new channel and save it
}


-(void)newChannelSelectedWithName:(NSString *) channelName{
    if(![channelName isEqualToString:self.currentThreadInView]){
		[self.povScrollView clearPOVs];
		[[LocalPOVs sharedInstance] getPOVsFromChannel:channelName].then(^(NSArray* povs) {
			[self.povScrollView displayPOVs: povs];
			[self.povScrollView playPOVOnScreen];
			povs = nil;
		});
    }
}



-(void) switchStoryListToThread:(NSString *) newChannel{
    [self.postDisplayVC cleanUp];
    [self.postDisplayVC presentContentWithPOVType:POVTypeUser andChannel:newChannel];
}

-(void)clearScreen:(UIGestureRecognizer *) tapGesture {
	if(self.contentCoveringScreen) {
		[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
			[self.profileNavBar setFrame:self.profileNavBarFrameOffScreen];
		}];
		[self.delegate showTabBar:NO];
		self.contentCoveringScreen = NO;
	} else {
		[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
			[self.profileNavBar setFrame:self.profileNavBarFrameOnScreen];
		}];
		[self.delegate showTabBar:YES];
		self.contentCoveringScreen = YES;
	}
}

-(void) offScreen{
    [self.postDisplayVC offScreen];
}
-(void)onScreen{
    [self.postDisplayVC onScreen];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:SETTINGS_PAGE_MODAL_SEGUE]){
        // Get reference to the destination view controller
        SettingsVC * vc = [segue destinationViewController];
        
        //set the username of the currently logged in user
        vc.userName  = @"Aishwarya Vardhana";
    }
}




#pragma mark - Article Display Delegate methods -

-(void) userLiked:(BOOL)liked POV:(PovInfo *)povInfo {
	// do nothing
}

@end
