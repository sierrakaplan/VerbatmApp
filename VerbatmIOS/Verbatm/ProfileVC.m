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

#import "UIView+Effects.h"
#import "UserManager.h"

@interface ProfileVC() <ArticleDisplayVCDelegate, ProfileNavBarDelegate,UIScrollViewDelegate,CreateNewChannelViewProtocol, POVScrollViewDelegate>

@property (strong, nonatomic) POVScrollView* povScrollView;
@property (nonatomic, strong) ProfileNavBar* profileNavBar;
@property (nonatomic) CGRect profileNavBarFrameOnScreen;
@property (nonatomic) CGRect profileNavBarFrameOffScreen;
@property (nonatomic) BOOL contentCoveringScreen;
@property (weak, nonatomic) GTLVerbatmAppVerbatmUser* currentUser;
@property (strong, nonatomic) ArticleDisplayVC * postDisplayVC;
@property (nonatomic, strong) NSString * currentThreadInView;

@property (strong, nonatomic) NSArray* channels;



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
    
    //simulates downloading threads
    Channel * enterpreneurship = [[Channel alloc] initWithChannelName:@"Entrepreneurship" numberOfFollowers:@(50) andUserName:@"Iain Usiri"];
    
    Channel * socialJustice = [[Channel alloc] initWithChannelName:@"Social Justice" numberOfFollowers:@(500) andUserName:@"Iain Usiri"];
    
    Channel * music = [[Channel alloc] initWithChannelName:@"Music" numberOfFollowers:@(10000) andUserName:@"Iain Usiri"];
    
    
    self.channels = @[enterpreneurship, socialJustice, music];
    block();//after downloading threads we call this block to build the profile
}



-(void) viewWillAppear:(BOOL)animated{
    NSString * channel = ((Channel *)self.channels[0]).name;
//    
//    [[LocalPOVs sharedInstance] getPOVsFromChannel:channel].then(^(NSArray* povs) {
//        [self.povScrollView displayPOVs: povs];
//        [self.povScrollView playPOVOnScreen];
//    });
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
    self.povScrollView.customDelegate = self;
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
    self.profileNavBarFrameOnScreen = CGRectMake(0.f, 0.f, self.view.frame.size.width, PROFILE_NAV_BAR_HEIGHT + ARROW_EXTENSION_BAR_HEIGHT);
    //frame when off screen
	self.profileNavBarFrameOffScreen = CGRectMake(0.f, - (PROFILE_NAV_BAR_HEIGHT+ ARROW_EXTENSION_BAR_HEIGHT), self.view.frame.size.width, PROFILE_NAV_BAR_HEIGHT + ARROW_EXTENSION_BAR_HEIGHT);
    [self updateUserInfo];
    self.profileNavBar = [[ProfileNavBar alloc] initWithFrame:self.profileNavBarFrameOnScreen
												   andChannels:self.channels andUserName:self.currentUser.name isCurrentLoggedInUser:self.isCurrentUserProfile];
    self.profileNavBar.delegate = self;
    [self.view addSubview:self.profileNavBar];
}




-(void) updateUserInfo {
    self.currentUser = [[UserManager sharedInstance] getCurrentUser];
}

-(void)addClearScreenGesture{
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearScreen:)];
    singleTap.numberOfTapsRequired = 1;
    [self.povScrollView addGestureRecognizer:singleTap];
    
    
    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likePOVOnScreen:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.povScrollView addGestureRecognizer:doubleTap];
}


-(void)likePOVOnScreen:(UITapGestureRecognizer *) tapGesture{
    
}


#pragma mark -POV ScrollView custom delegate -

-(void) povLikeButtonLiked: (BOOL)liked onPOV: (PovInfo*) povInfo{
    [self.delegate profilePovLikeLiked:liked forPOV:povInfo];
}

-(void) povshareButtonSelectedForPOVInfo:(PovInfo *) povInfo{
    [self.delegate profilePovShareButtonSeletedForPOV:povInfo];
}


#pragma mark - Profile Nav Bar Delegate Methods -

//current user selected to follow a channel
-(void) followOptionSelected{
    [self.delegate presentChannelsToFollow];
}

//current user wants to see their own followers
-(void) followersOptionSelected{
    [self.delegate presentFollowersListMyID:nil];//to-do
}

//current user wants to see who they follow
-(void) followingOptionSelected {
    [self.delegate presentWhoIFollowMyID:nil];//to-do
}

-(void) settingsButtonClicked {
    [self performSegueWithIdentifier:SETTINGS_PAGE_MODAL_SEGUE sender:self];
    
}

//ProfileNavBarDelegate protocol
-(void) createNewChannel{
    [self.delegate createNewChannel];
}
//the current user has selected the back button
-(void)exitCurrentProfile {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    }];
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
            [self.profileNavBar setFrame:[self getProfileNavBarFrameOfScreen:YES]];
		}];
		[self.delegate showTabBar:NO];
		self.contentCoveringScreen = NO;
        [self.povScrollView headerShowing:NO];
	} else {
		[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
			[self.profileNavBar setFrame:[self getProfileNavBarFrameOfScreen:NO]];
		}];
		[self.delegate showTabBar:YES];
		self.contentCoveringScreen = YES;
        [self.povScrollView headerShowing:YES];

	}
}


-(CGRect)getProfileNavBarFrameOfScreen:(BOOL) getOffScreenFrame{
    
    if(getOffScreenFrame){
        return CGRectMake(0, -1 * self.profileNavBar.frame.size.height,
                          self.profileNavBar.frame.size.width,
                          self.profileNavBar.frame.size.height);
    }else{
        return CGRectMake(0, 0,
                          self.profileNavBar.frame.size.width,
                          self.profileNavBar.frame.size.height);
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
