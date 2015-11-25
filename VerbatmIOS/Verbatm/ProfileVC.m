//
//  profileVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//


#import "ProfileVC.h"
#import "profileNavBar.h"
#import "SizesAndPositions.h"
#import "GTLVerbatmAppVerbatmUser.h"
#import "UserManager.h"
#import "ArticleDisplayVC.h"
#import "POVLoadManager.h"

@interface ProfileVC()<ArticleDisplayVCDelegate, POVLoadManagerDelegate>

@property (nonatomic, strong) profileNavBar * profileNavBar;
@property (weak, nonatomic) GTLVerbatmAppVerbatmUser* currentUser;
@property (strong, nonatomic) ArticleDisplayVC * postDisplayVC;
@property (strong, nonatomic) POVLoadManager * profileLoadManager;
#define ARTICLE_DISPLAY_VC_ID @"article_display_vc"
#define NUM_POVS_IN_SECTION 10
@end

@implementation ProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
	
    NSArray * testThreads = @[@"Parties", @"Selfies", @"The Diaspora", @"Entrepreneur", @"Demo Day"];
    [self createLoadManger];
    [self createContentListView];
    [self createNavigationBarWithThreads:testThreads];
    [self addClearScreenGesture];
    
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void)createLoadManger{
    NSNumber* aishwaryaId = [NSNumber numberWithLongLong:5432098273886208];
    self.profileLoadManager = [[POVLoadManager alloc] initWithUserId: aishwaryaId];
    self.profileLoadManager.delegate = self;
    [self.profileLoadManager reloadPOVs: NUM_POVS_IN_SECTION];
}

-(void) createContentListView{
   
    
    self.postDisplayVC = [self.storyboard instantiateViewControllerWithIdentifier:ARTICLE_DISPLAY_VC_ID];
    self.postDisplayVC.view.frame = self.view.bounds;
    self.postDisplayVC.view.backgroundColor = [UIColor blackColor];
    
    [self addChildViewController:self.postDisplayVC];
    [self.view addSubview:self.postDisplayVC.view];
    [self.postDisplayVC didMoveToParentViewController:self];
    self.postDisplayVC.delegate = self;
   
}

//load manager protocol
-(void) povsRefreshed{
    if(self.postDisplayVC)[self.postDisplayVC loadStoryAtIndex:0.f fromLoadManager:self.profileLoadManager];
}

-(void) createNavigationBarWithThreads:(NSArray *) threads {
    CGRect navBarFrame = CGRectMake(0.f, 0.f, self.view.frame.size.width,(CUSTOM_NAV_BAR_HEIGHT*2));
    [self updateUserInfo];
    self.profileNavBar = [[profileNavBar alloc] initWithFrame:navBarFrame andThreads:threads andUserName:self.currentUser.name];
    [self.view addSubview:self.profileNavBar];
    
}

-(void) updateUserInfo {
    self.currentUser = [[UserManager sharedInstance] getCurrentUser];
}


// Successfully loaded more POV's
-(void) morePOVsLoaded: (NSInteger) numLoaded {
    
}
// Was unable to load more POV's for some reason
-(void) failedToLoadMorePOVs{
    
}
// Was unable to refresh POV's for some reason
-(void) povsFailedToRefresh{
    
}


-(void)addClearScreenGesture{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearScreen:)];
    [self.view addGestureRecognizer:tap];
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





@end
