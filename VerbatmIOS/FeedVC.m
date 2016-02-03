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

//#import "PostListVC.h"
#import "POVScrollView.h"

#import "SegueIDs.h"
#import "SizesAndPositions.h"

@interface FeedVC () <ArticleDisplayVCDelegate, UIScrollViewDelegate, POVScrollViewDelegate>
@property (strong, nonatomic) ArticleDisplayVC * postDisplayVC;
@property (nonatomic) BOOL contentCoveringScreen;

@property (nonatomic) CGRect povScrollViewFrame;
@property (strong, nonatomic) POVScrollView* povScrollView;

//@property (nonatomic) PostListVC * postListView;
@property (weak, nonatomic) IBOutlet UIView *postListContainerView;



#define TRENDING_VC_ID @"trending_vc"
#define VERBATM_LOGO_WIDTH 150.f

@end

@implementation FeedVC

-(void)viewDidLoad {
	[super viewDidLoad];
    //[self addPostListVC];
    [self addClearScreenGesture];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.povScrollView clearPOVs];
}

-(void) addPostListVC {
//    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
//    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    [flowLayout setMinimumInteritemSpacing:0.3];
//    [flowLayout setMinimumLineSpacing:0.0f];
//    [flowLayout setItemSize:self.view.frame.size];
//    self.postListView = [[PostListVC alloc] initWithCollectionViewLayout:flowLayout];
//    
//    [self.postListContainerView setFrame:self.view.bounds];
//    [self.postListContainerView addSubview:self.postListView.view];
//    [self.view addSubview:self.postListContainerView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.povScrollView playPOVOnScreen];
}

-(void) createContentListView {
    self.postDisplayVC = [self.storyboard instantiateViewControllerWithIdentifier:ARTICLE_DISPLAY_VC_ID];
    self.postDisplayVC.view.frame = self.view.bounds;
    self.postDisplayVC.view.backgroundColor = [UIColor blackColor];
    [self.postDisplayVC presentContentWithPOVType:POVTypeTrending andChannel:@""];
    [self addChildViewController:self.postDisplayVC];
    [self.view addSubview:self.postDisplayVC.view];
    [self.postDisplayVC didMoveToParentViewController:self];
    self.postDisplayVC.delegate = self;
}

//articledisplay delegate method
-(void) userLiked:(BOOL)liked POV:(PovInfo *)povInfo{
    
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
		[self.povScrollView headerShowing:NO];
    } else {
        [self.delegate showTabBar:YES];
        self.contentCoveringScreen = YES;
		[self.povScrollView headerShowing:YES];
    }
}

-(void)offScreen{
    [self.postDisplayVC offScreen];
}

-(void)onScreen{
    [self.postDisplayVC onScreen];
}

//not implemented
// animates the fact that a recent POV is publishing
-(void) showPOVPublishingWithUserName: (NSString*)userName andTitle: (NSString*) title
                    andProgressObject:(NSProgress *)publishingProgress{
    
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
