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
#import "Intro_Instruction_Notification_View.h"

#import "Notifications.h"

#import "PostListVC.h"
#import <Parse/PFUser.h>
#import "ProfileVC.h"

#import "SharePostView.h"

#import "SegueIDs.h"
#import "SizesAndPositions.h"

#import "UserSetupParameters.h"

@interface FeedVC () <UIScrollViewDelegate, PostListVCProtocol,
Intro_Notification_Delegate, UIGestureRecognizerDelegate>

@property (nonatomic) BOOL contentCoveringScreen;

@property (nonatomic) CGRect povScrollViewFrame;
@property (strong, nonatomic) PostListVC * postListVC;

@property (weak, nonatomic) IBOutlet UIView *postListContainerView;

@property (nonatomic) SharePostView * sharePostView;
@property (nonatomic) BOOL didJustLoadForTheFirstTime;

@property (nonatomic) Intro_Instruction_Notification_View * introInstruction;

@end

@implementation FeedVC

-(void)viewDidLoad {
	[super viewDidLoad];
	[self addClearScreenGesture];
	self.didJustLoadForTheFirstTime = YES;
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	self.didJustLoadForTheFirstTime = NO;
	[self.postListVC display:nil asPostListType:listFeed withListOwner:[PFUser currentUser]
		isCurrentUserProfile:NO andStartingDate:nil];
	if(self.postListVC && !self.didJustLoadForTheFirstTime){
        [self.postListVC refreshPosts];
	}
	[self checkIntroNotification];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
    [self.postListVC offScreen];
    [self.postListVC clearViews];
    @autoreleasepool {
        self.postListVC = nil;
    }
}

-(void)checkIntroNotification{
	if(![[UserSetupParameters sharedInstance] checkAndSetFeedInstructionShown]){
		self.introInstruction = [[Intro_Instruction_Notification_View alloc] initWithCenter:self.view.center andType:Feed];
		self.introInstruction.custom_delegate = self;
		[self.view addSubview:self.introInstruction];
		[self.view bringSubviewToFront:self.introInstruction];
	}
}

-(void)notificationDoneAnimatingOut {
	if (self.introInstruction) {
		[self.introInstruction removeFromSuperview];
		self.introInstruction = nil;
	}
}

//not implemented because we are not using this feed anymore
-(void)noPostFound{
    
}
-(void)postsFound{
    
}
-(void)cellSelectedAtPostIndex:(NSIndexPath *) cellPath{
    
}

-(void) addPostListVC {
	UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
	flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	[flowLayout setMinimumInteritemSpacing:0.3];
	[flowLayout setMinimumLineSpacing:0.0f];
	[flowLayout setItemSize:self.view.frame.size];
	self.postListVC = [[PostListVC alloc] initWithCollectionViewLayout:flowLayout];
	self.postListVC.postListDelegate = self;
	[self.postListContainerView setFrame:self.view.bounds];
	[self.postListContainerView addSubview:self.postListVC.view];
	[self.view addSubview:self.postListContainerView];
}

#pragma mark - POVListSVController -

-(void) shareOptionSelectedForParsePostObject: (PFObject* ) post{
	[self presentSharePostView];
}

#pragma mark -POVListSVController-

-(void)hideNavBarIfPresent{
	[self removeContentFromScreen];
}

-(void)channelSelected:(Channel *) channel{
	ProfileVC * userProfile = [[ProfileVC alloc] init];
	userProfile.isCurrentUserProfile = NO;
	userProfile.isProfileTab = NO;
	userProfile.ownerOfProfile = channel.channelCreator;
	userProfile.channel = channel;
	[self presentViewController:userProfile animated:YES completion:^{
	}];
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
	tap.delegate = self;
	[self.view addGestureRecognizer:tap];
	self.contentCoveringScreen = YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return  (![touch.view isKindOfClass:[Intro_Instruction_Notification_View class]]);
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

-(void)presentSharePostView {
	if(self.sharePostView){
		[self.sharePostView removeFromSuperview];
		self.sharePostView = nil;
	}
	CGRect onScreenFrame = CGRectMake(0.f, self.view.frame.size.height/2.f, self.view.frame.size.width, self.view.frame.size.height/2.f);
	CGRect offScreenFrame = CGRectMake(0.f, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.f);
	self.sharePostView = [[SharePostView alloc] initWithFrame:offScreenFrame];
	[self.view addSubview:self.sharePostView];
	[self.view bringSubviewToFront:self.sharePostView];
	[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
		if(self.contentCoveringScreen) {
			[self removeContentFromScreen];
		}
		self.sharePostView.frame = onScreenFrame;
	}];
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

#pragma mark - Network Connection Lost -

-(void)networkConnectionUpdate: (NSNotification *) notification{
	NSDictionary * userInfo = [notification userInfo];
	BOOL thereIsConnection = [(NSNumber*)[userInfo objectForKey:INTERNET_CONNECTION_KEY] boolValue];
	if(!thereIsConnection){
		[self userLostInternetConnection];
	}
}

-(void) userLostInternetConnection {
	UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"No Network" message:@"Please make sure you're connected WiFi or turn on data for this app in Settings." preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
													handler:^(UIAlertAction * action) {}];
	[newAlert addAction:defaultAction];
	[self presentViewController:newAlert animated:YES completion:nil];
}

-(void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(PostListVC *) postListVC{
    if(!_postListVC){
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        [flowLayout setMinimumInteritemSpacing:0.3];
        [flowLayout setMinimumLineSpacing:0.0f];
        [flowLayout setItemSize:self.view.frame.size];
        _postListVC = [[PostListVC alloc] initWithCollectionViewLayout:flowLayout];
        _postListVC.postListDelegate = self;
        [self.postListContainerView setFrame:self.view.bounds];
        [self.postListContainerView addSubview:_postListVC.view];
        [self.view addSubview:self.postListContainerView];
        
    }
    return _postListVC;
}

@end
