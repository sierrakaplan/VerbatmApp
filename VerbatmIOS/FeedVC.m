//
//  feedDisplayTVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleDisplayVC.h"
#import "Icons.h"
#import "FeedVC.h"
#import "Notifications.h"
#import "LocalPOVs.h"
#import "POVScrollView.h"
#import "SegueIDs.h"
#import "SizesAndPositions.h"

@interface FeedVC () <ArticleDisplayVCDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIView* header;

@property (strong, nonatomic) ArticleDisplayVC * postDisplayVC;
@property (nonatomic) BOOL contentCoveringScreen;

@property (strong, nonatomic) POVScrollView* povScrollView;

#define TRENDING_VC_ID @"trending_vc"

#define HEADER_HEIGHT 50.f
#define VERBATM_LOGO_WIDTH 150.f
@end

@implementation FeedVC

-(void)viewDidLoad {
	[super viewDidLoad];
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
	[self setHeader];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
//    [self createContentListView];
	[self addPOVScrollView];
    [self addClearScreenGesture];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void) setHeader {
	self.header = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.bounds.size.width,
															  HEADER_HEIGHT)];
	[self.header setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.5f]];
	UIImageView* verbatmTitleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:VERBATM_LOGO]];
	verbatmTitleView.contentMode = UIViewContentModeScaleAspectFit;
	verbatmTitleView.frame = CGRectMake(self.view.frame.size.width/2.f - VERBATM_LOGO_WIDTH/2.f,
										BELOW_STATUS_BAR, VERBATM_LOGO_WIDTH, HEADER_HEIGHT - BELOW_STATUS_BAR);
	[self.header addSubview:verbatmTitleView];
	[self.view addSubview:self.header];
}

-(void) addPOVScrollView {
	self.povScrollView = [[POVScrollView alloc] initWithFrame:self.view.bounds];
	[[LocalPOVs sharedInstance] getPOVsFromThread:@"feed"].then(^(NSArray* povs) {
		[self.povScrollView displayPOVs: povs];
        
	});
    self.povScrollView.delegate = self;
	[self.view insertSubview:self.povScrollView belowSubview:self.header];
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
    if(self.contentCoveringScreen){
		[self.header removeFromSuperview];
        [self.delegate showTabBar:NO];
        self.contentCoveringScreen = NO;
    } else {
		[self.view addSubview: self.header];
        [self.delegate showTabBar:YES];
        self.contentCoveringScreen = YES;
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
