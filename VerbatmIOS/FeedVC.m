//
//  feedDisplayTVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "Durations.h"

#import "FeedVC.h"

#import "Icons.h"

#import "Notifications.h"

#import "PostListVC.h"
#import <Parse/PFUser.h>

#import "SharePostView.h"
#import "SegueIDs.h"
#import "SizesAndPositions.h"

@interface FeedVC () <UIScrollViewDelegate, SharePostViewDelegate, PostListVCProtocol>

@property (nonatomic) BOOL contentCoveringScreen;

@property (nonatomic) CGRect povScrollViewFrame;
@property (strong, nonatomic) PostListVC * postListVC;

@property (weak, nonatomic) IBOutlet UIView *postListContainerView;

@property (nonatomic) SharePostView * sharePostView;
@property (nonatomic) BOOL didJustLoadForTheFirstTime;

#define VERBATM_LOGO_WIDTH 150.f

@end

@implementation FeedVC

-(void)viewDidLoad {
	[super viewDidLoad];
    [self addPostListVC];
    [self addClearScreenGesture];
    self.didJustLoadForTheFirstTime = YES;
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    if(self.postListVC && !self.didJustLoadForTheFirstTime){
       [self.postListVC continueVideoContent];
    }
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(self.postListVC)[self.postListVC stopAllVideoContent];
    self.didJustLoadForTheFirstTime = NO;
}

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

#pragma mark - POVListSVController -

-(void) shareOptionSelectedForParsePostObject: (PFObject* ) post{
	[self presentShareSelectionViewStartOnChannels:YES];
    [self.delegate shareButtonSelectedForPostObject: post];
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
    if(self.sharePostView){
        [self.sharePostView removeFromSuperview];
        self.sharePostView = nil;
    }
    
    CGRect onScreenFrame = CGRectMake(0.f, self.view.frame.size.height/2.f, self.view.frame.size.width, self.view.frame.size.height/2.f);
    CGRect offScreenFrame = CGRectMake(0.f, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.f);
    self.sharePostView = [[SharePostView alloc] initWithFrame:offScreenFrame shouldStartOnChannels:startOnChannels];
    self.sharePostView.delegate = self;
    [self.view addSubview:self.sharePostView];
    [self.view bringSubviewToFront:self.sharePostView];
    [UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
        if(self.contentCoveringScreen) {
            [self removeContentFromScreen];
        }
        self.sharePostView.frame = onScreenFrame;
    }];
}

-(void) cancelButtonSelected{
    [self removeSharePostView];
}

-(void) postPostToChannels:(NSMutableArray *)channels {
    [self removeSharePostView];
}

-(void)removeSharePostView{
    if(self.sharePostView){
        CGRect offScreenFrame = CGRectMake(0.f, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.f);
        
        [UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
            self.sharePostView.frame = offScreenFrame;
        }completion:^(BOOL finished) {
            if(finished){
                [self.sharePostView removeFromSuperview];
                self.sharePostView = nil;
            }
        }];
    }
}

//todo:
-(void) channelSelected:(Channel *)channel withOwner:(PFUser *)owner {
	//todo:
}

#pragma mark - Share Post Delegate -

-(void) sharePostWithComment: (NSString *)comment {
	//todo:
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
