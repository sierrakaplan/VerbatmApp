//
//  feedDisplayTVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleDisplayVC.h"
#import "Channel_BackendObject.h"
#import "Durations.h"

#import "FeedVC.h"

#import "Icons.h"

#import "LocalPOVs.h"

#import "Notifications.h"

#import "PostListVC.h"
//#import "POVListScrollViewVC.h"
#import <Parse/PFUser.h>

#import "SharePOVView.h"
#import "SegueIDs.h"
#import "SizesAndPositions.h"

@interface FeedVC () <ArticleDisplayVCDelegate, UIScrollViewDelegate,SharePOVViewDelegate, PostListVCProtocol>
@property (strong, nonatomic) ArticleDisplayVC * postDisplayVC;
@property (nonatomic) BOOL contentCoveringScreen;

@property (nonatomic) CGRect povScrollViewFrame;
@property (strong, nonatomic) PostListVC * postListVC;

//@property (nonatomic) PostListVC * postListView;
@property (weak, nonatomic) IBOutlet UIView *postListContainerView;


@property (nonatomic) SharePOVView * sharePOVView;

#define TRENDING_VC_ID @"trending_vc"
#define VERBATM_LOGO_WIDTH 150.f

@end

@implementation FeedVC

-(void)viewDidLoad {
	[super viewDidLoad];
    //[self createContentListView];
    [self addPostListVC];
    [self addClearScreenGesture];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    if(self.postListVC){
        [self.postListVC continueVideoContent];
    }
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(self.postListVC)[self.postListVC stopAllVideoContent];
}


//-(void) createContentListView {
//    self.postListVC = [[POVListScrollViewVC alloc] init];
//    self.postListVC.listOwner = [PFUser currentUser];
//    self.postListVC.listType = listFeed;
//    self.postListVC.isHomeProfileOrFeed =YES;
//   // self.postListVC.delegate = self;
//    [self.view addSubview:self.postListVC.view];
//    self.postDisplayVC.delegate = self;
//    [self.postDisplayVC didMoveToParentViewController:self];
//}


-(void) addPostListVC {
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [flowLayout setMinimumInteritemSpacing:0.3];
    [flowLayout setMinimumLineSpacing:0.0f];
    [flowLayout setItemSize:self.view.frame.size];
    self.postListVC = [[PostListVC alloc] initWithCollectionViewLayout:flowLayout];
    self.postListVC.listType = listFeed;
    self.postListVC.isHomeProfileOrFeed = YES;
    self.postListVC.listOwner = [PFUser currentUser];
    self.postListVC.delegate = self;
    [self.postListContainerView setFrame:self.view.bounds];
    [self.postListContainerView addSubview:self.postListVC.view];
    [self.view addSubview:self.postListContainerView];
}



#pragma mark -POVListSVController-
-(void)hideNavBarIfPresent{
    [self removeContentFromScreen];
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
        [self removeContentFromScreen];
    } else {
        [self returnContentToScreen];

    }
}
-(void)returnContentToScreen{
    [self.delegate showTabBar:YES];
    self.contentCoveringScreen = YES;
    [self.postListVC footerShowing:YES];
}

-(void)removeContentFromScreen{
    [self.delegate showTabBar:NO];
    self.contentCoveringScreen = NO;
    [self.postListVC footerShowing:NO];
}

-(void)presentShareSelectionViewStartOnChannels:(BOOL) startOnChannels{
    if(self.sharePOVView){
        [self.sharePOVView removeFromSuperview];
        self.sharePOVView = nil;
    }
    
    CGRect onScreenFrame = CGRectMake(0.f, self.view.frame.size.height/2.f, self.view.frame.size.width, self.view.frame.size.height/2.f);
    CGRect offScreenFrame = CGRectMake(0.f, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.f);
    self.sharePOVView = [[SharePOVView alloc] initWithFrame:offScreenFrame shouldStartOnChannels:startOnChannels];
    self.sharePOVView.delegate = self;
    [self.view addSubview:self.sharePOVView];
    [self.view bringSubviewToFront:self.sharePOVView];
    [UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
        if(self.contentCoveringScreen) {
            [self removeContentFromScreen];
        }
        self.sharePOVView.frame = onScreenFrame;
    }];
}

-(void)cancelButtonSelected{
    [self removeSharePOVView];
}
-(void)postPOVToChannel:(Channel *) channel{
    [self removeSharePOVView];
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



//TODO
//#pragma mark -POVScrollview delegate-
//-(void) povLikeButtonLiked: (BOOL)liked onPOV: (PovInfo*) povInfo{
//    [self.delegate feedPovLikeLiked:liked forPOV:povInfo];
//}
//-(void) povshareButtonSelectedForPOVInfo:(PovInfo *) povInfo{
//    [self.delegate feedPovShareButtonSeletedForPOV:povInfo];
//}

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
