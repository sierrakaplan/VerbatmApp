//
//  profileVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "Durations.h"
#import "POVScrollView.h"
#import "ProfileVC.h"
#import "ProfileNavBar.h"
#import "SizesAndPositions.h"
#import "GTLVerbatmAppVerbatmUser.h"
#import "UserManager.h"
#import "ArticleDisplayVC.h"
#import "POVLoadManager.h"
#import "SegueIDs.h"

@interface ProfileVC() <ArticleDisplayVCDelegate, ProfileNavBarDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) POVScrollView* povScrollView;
@property (nonatomic, strong) ProfileNavBar* profileNavBar;
@property (nonatomic) CGRect profileNavBarFrameOnScreen;
@property (nonatomic) CGRect profileNavBarFrameOffScreen;
@property (nonatomic) BOOL contentCoveringScreen;
@property (weak, nonatomic) GTLVerbatmAppVerbatmUser* currentUser;
@property (strong, nonatomic) ArticleDisplayVC * postDisplayVC;
@property (nonatomic, strong) NSString * currentThreadInView;

@property (strong, nonatomic) NSArray* threads;

@end

@implementation ProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
	self.contentCoveringScreen = YES;
    
    //this is where you'd fetch the threads
    self.threads = @[@"Entrepreneurship", @"Social Justice", @"Music"];
    [self addPOVScrollView];
    [self createNavigationBar];
    [self addClearScreenGesture];
}

-(void) viewWillAppear:(BOOL)animated {
	
	//TODO: get POVs
//        [self.povScrollView displayPOVs: povs];
//        [self.povScrollView playPOVOnScreen];

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
    self.profileNavBarFrameOnScreen = CGRectMake(0.f, 0.f, self.view.frame.size.width, PROFILE_NAV_BAR_HEIGHT);
	self.profileNavBarFrameOffScreen = CGRectMake(0.f, -PROFILE_NAV_BAR_HEIGHT, self.view.frame.size.width, PROFILE_NAV_BAR_HEIGHT);
    [self updateUserInfo];
    self.profileNavBar = [[ProfileNavBar alloc] initWithFrame:self.profileNavBarFrameOnScreen
												   andThreads:self.threads andUserName:self.currentUser.name];
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
}

-(void)newChannelSelectedWithName:(NSString *) channelName{
    if(![channelName isEqualToString:self.currentThreadInView]){
		[self.povScrollView clearPOVs];
		//TODO: get POVS
//			[self.povScrollView displayPOVs: povs];
//			[self.povScrollView playPOVOnScreen];
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

#pragma mark - Article Display Delegate methods -

-(void) userLiked:(BOOL)liked POV:(PovInfo *)povInfo {
	// do nothing
}

@end
