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
#import "SegueIDs.h"

@interface ProfileVC()<ArticleDisplayVCDelegate, POVLoadManagerDelegate, profileNavBarDelegate>

@property (nonatomic, strong) profileNavBar * profileNavBar;
@property (weak, nonatomic) GTLVerbatmAppVerbatmUser* currentUser;
@property (strong, nonatomic) ArticleDisplayVC * postDisplayVC;
@property (nonatomic, strong) NSString * currentThreadInView;

@end

@implementation ProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
	
    //this is where you'd fetch the threads
    NSArray * testThreads = @[@"Parties", @"Selfies", @"The Diaspora", @"Entrepreneur", @"Demo Day"];
    
    
    [self createContentListViewWithStartThread:testThreads[0]];
    [self createNavigationBarWithThreads:testThreads];
    [self addClearScreenGesture];
    
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
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
    CGRect navBarFrame = CGRectMake(0.f, 0.f, self.view.frame.size.width,(CUSTOM_NAV_BAR_HEIGHT*2));
    [self updateUserInfo];
    self.profileNavBar = [[profileNavBar alloc] initWithFrame:navBarFrame andThreads:threads andUserName:self.currentUser.name];
    self.profileNavBar.delegate = self;
    [self.view addSubview:self.profileNavBar];
    
}

-(void) updateUserInfo {
    self.currentUser = [[UserManager sharedInstance] getCurrentUser];
}


-(void)addClearScreenGesture{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearScreen:)];
    [self.view addGestureRecognizer:tap];
}

//nav bar delegate method
-(void)newChannelSelectedWithName:(NSString *) channelName{
    if(![channelName isEqualToString:self.currentThreadInView]){
        [self switchStoryListToThread:channelName];
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





@end
