//
//  feedDisplayTVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleDisplayVC.h"

#import "Durations.h"

#import "FeedVC.h"

#import "Icons.h"

#import "LocalPOVs.h"

#import "Notifications.h"

#import "POVListScrollViewVC.h"

#import "SegueIDs.h"
#import "SizesAndPositions.h"

@interface FeedVC () <ArticleDisplayVCDelegate, UIScrollViewDelegate, POVListViewProtocol>
@property (strong, nonatomic) ArticleDisplayVC * postDisplayVC;
@property (nonatomic) BOOL contentCoveringScreen;

@property (nonatomic) CGRect povScrollViewFrame;
@property (strong, nonatomic) POVListScrollViewVC* postListVC;

//@property (nonatomic) PostListVC * postListView;
@property (weak, nonatomic) IBOutlet UIView *postListContainerView;



#define TRENDING_VC_ID @"trending_vc"
#define VERBATM_LOGO_WIDTH 150.f

@end

@implementation FeedVC

-(void)viewDidLoad {
	[super viewDidLoad];
    [self createContentListView];
    [self addClearScreenGesture];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    if(self.postListVC)[self.postListVC continueVideoContent];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(self.postListVC)[self.postListVC stopAllVideoContent];
}


-(void) createContentListView {
    self.postListVC = [[POVListScrollViewVC alloc] init];
    self.postListVC.listOwner = [PFUser currentUser];
    self.postListVC.listType = listFeed;
    self.postListVC.delegate = self;
    [self.view addSubview:self.postListVC.view];
    self.postDisplayVC.delegate = self;
    [self.postDisplayVC didMoveToParentViewController:self];
}


#pragma mark -POVListSVController-
-(void) shareOptionSelectedForParsePostObject: (PFObject* ) pov{
    
}


-(void)registerForNotifications{
	//gets notified if there is no internet connection
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(networkConnectionUpdate:)
												 name:INTERNET_CONNECTION_NOTIFICATION
											   object:nil];
}

-(void)addClearScreenGesture{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearScreen:)];
    [self.view addGestureRecognizer:tap];
    self.contentCoveringScreen = YES;
}

-(void)clearScreen:(UIGestureRecognizer *) tapGesture {
    if(self.contentCoveringScreen) {
        [self.delegate showTabBar:NO];
        self.contentCoveringScreen = NO;
        [self.postListVC footerShowing:NO];
    } else {
        [self.delegate showTabBar:YES];
        self.contentCoveringScreen = YES;
        [self.postListVC footerShowing:YES];

    }
}



#pragma mark -POVScrollview delegate-
-(void) povLikeButtonLiked: (BOOL)liked onPOV: (PovInfo*) povInfo{
    [self.delegate feedPovLikeLiked:liked forPOV:povInfo];
}
-(void) povshareButtonSelectedForPOVInfo:(PovInfo *) povInfo{
    [self.delegate feedPovShareButtonSeletedForPOV:povInfo];
}

#pragma mark - Network Connection Lost -

-(void)networkConnectionUpdate: (NSNotification *) notification{
    NSDictionary * userInfo = [notification userInfo];
    BOOL thereIsConnection = [(NSNumber*)[userInfo objectForKey:INTERNET_CONNECTION_KEY] boolValue];
    if(!thereIsConnection){
        [self userLostInternetConnection];
    }
}

-(void) userLostInternetConnection {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Network. Please make sure you're connected WiFi or turn on data for this app in Settings." message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}
@end
