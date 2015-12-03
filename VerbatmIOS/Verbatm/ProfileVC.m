//
//  profileVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "LocalPOVs.h"
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
@property (weak, nonatomic) GTLVerbatmAppVerbatmUser* currentUser;
@property (strong, nonatomic) ArticleDisplayVC * postDisplayVC;
@property (nonatomic, strong) NSString * currentThreadInView;

@end

@implementation ProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

-(void) viewWillAppear:(BOOL)animated{
    //this is where you'd fetch the threads
    NSArray * testThreads = @[@"Entrepreneurship", @"Music", @"Social Justice"];
    
//    [self createContentListViewWithStartThread:testThreads[0]];
	[self addPOVScrollViewWithThreads: testThreads];
    [self createNavigationBarWithThreads: testThreads];
    [self addClearScreenGesture];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void) addPOVScrollViewWithThreads: (NSArray*) threads {
	self.povScrollView = [[POVScrollView alloc] initWithFrame:self.view.bounds];
    self.povScrollView.delegate = self;
	[[LocalPOVs sharedInstance] getPOVsFromThread:threads[0]].then(^(NSArray* povs) {
		[self.povScrollView displayPOVs: povs];
		[self.povScrollView playPOVOnScreen];
		povs = nil;
	});
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

-(void) createNavigationBarWithThreads:(NSArray *) threads {
    CGRect navBarFrame = CGRectMake(0.f, 0.f, self.view.frame.size.width, PROFILE_NAV_BAR_HEIGHT);
    [self updateUserInfo];
    self.profileNavBar = [[ProfileNavBar alloc] initWithFrame:navBarFrame andThreads:threads andUserName:self.currentUser.name];
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
		[[LocalPOVs sharedInstance] getPOVsFromThread:channelName].then(^(NSArray* povs) {
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
    if(self.profileNavBar.superview){
        [self.profileNavBar removeFromSuperview];
        [self.delegate showTabBar:NO];
    }else{
        [self.view addSubview:self.profileNavBar];
        [self.delegate showTabBar:YES];
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
