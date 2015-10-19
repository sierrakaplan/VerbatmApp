//
//  verbatmMasterNavigationViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 5/20/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <AVFoundation/AVAudioSession.h>

#import "ArticleDisplayVC.h"

#import "FeedVC.h"

#import "GTLVerbatmAppVerbatmUser.h"

#import "Icons.h"
#import "internetConnectionMonitor.h"

#import "MasterNavigationVC.h"
#import "MediaSessionManager.h"
#import "MediaDevVC.h"

#import "Notifications.h"

#import "POVPublisher.h"
#import "PreviewDisplayView.h"
#import "ProfileVC.h"

#import "SegueIDs.h"
#import "SizesAndPositions.h"

#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

#import "UserSetupParameters.h"
#import "UserManager.h"
#import "UserPovInProgress.h"

#import "VerbatmCameraView.h"


@interface MasterNavigationVC () <FeedVCDelegate, MediaDevDelegate, PreviewDisplayDelegate,
UIGestureRecognizerDelegate, UserManagerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView * masterSV;
@property (weak, nonatomic) IBOutlet UIButton *accessCodePresenter_Button;

#pragma mark - Child View Controllers -
@property (weak, nonatomic) IBOutlet UIView * profileContainer;
@property (weak, nonatomic) IBOutlet UIView * adkContainer;
@property (weak, nonatomic) IBOutlet UIView * feedContainer;

@property (strong,nonatomic) ProfileVC* profileVC;
@property (strong,nonatomic) FeedVC* feedVC;
@property (strong,nonatomic) MediaDevVC* mediaDevVC;

@property (strong, nonatomic) ArticleDisplayVC* articleDisplayVC;

// VC that displays articles in scroll view when clicked
@property (weak, nonatomic) IBOutlet UIView *articleDisplayContainer;
// article display list slides in from right and can be pulled off when a screen edge pan
@property (nonatomic) CGRect articleDisplayContainerFrameOffScreen;

@property (strong, nonatomic) UserManager* userManager;


#pragma mark - Preview -
@property (nonatomic) PreviewDisplayView* previewDisplayView;

@property (nonatomic, strong) NSMutableArray * pagesToDisplay;
@property (nonatomic, strong) NSMutableArray * pinchViewsToDisplay;
@property (nonatomic) CGPoint previousGesturePoint;

@property (strong, nonatomic) internetConnectionMonitor * connectionMonitor;

#define MAIN_SCROLLVIEW_SCROLL_DURATION 0.5
#define NUMBER_OF_CHILD_VCS 3
#define LEFT_FRAME CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
#define CENTER_FRAME CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)
#define RIGHT_FRAME CGRectMake(self.view.frame.size.width * 2, 0, self.view.frame.size.width, self.view.frame.size.height)
#define ANIMATION_NOTIFICATION_DURATION 0.5
#define TIME_UNTIL_ANIMATION_CLEAR 1.5
#define ARTICLE_DISPLAY_REMOVAL_ANIMATION_DURATION 0.4f
//the amount of space that must be pulled to exit
#define EXIT_EPSILON 60

#define ID_FOR_FEEDVC @"feed_vc"
#define ID_FOR_MEDIADEVVC @"media_dev_vc"
#define ID_FOR_PROFILEVC @"profile_vc"
#define ID_FOR_DISPLAY_VC @"article_display_vc"

@end

@implementation MasterNavigationVC

- (void)viewDidLoad {
	[super viewDidLoad];
	[self formatMainScrollView];
	[self getAndFormatVCs];
	self.connectionMonitor = [[internetConnectionMonitor alloc] init];
	[self registerForNotifications];
	if (![PFUser currentUser].isAuthenticated &&
		![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        self.masterSV.scrollEnabled = NO;

    	} else {
		[self.userManager queryForCurrentUser];
	}
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    //check if they have entered an access code - if not then present the entry page
    if(![UserSetupParameters accessCodeEntered]) {
        [self.accessCodePresenter_Button sendActionsForControlEvents:UIControlEventTouchUpInside];
    }else if(![UserSetupParameters blackCircleInstructionShown]) {
		[self alertPullTrendingIcon];
	}
    
}

-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

-(void)registerForNotifications{
	//gets notified if there is no internet connection
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(networkConnectionUpdate:)
												 name:INTERNET_CONNECTION_NOTIFICATION
											   object:nil];
}

#pragma mark - User Manager Delegate -

-(void) successfullyLoggedInUser:(GTLVerbatmAppVerbatmUser *)user {
	[self.profileVC updateUserInfo];
}

-(void) errorLoggingInUser:(NSError *)error {
	NSLog(@"Error finding current user: %@", error.description);
}

#pragma mark - Getting and formatting child view controllers -

//lays out all the containers in the right position and also sets the appropriate
//offset for the master SV
-(void) getAndFormatVCs {
	self.profileContainer.frame = LEFT_FRAME;
	self.feedContainer.frame = CENTER_FRAME;
	self.adkContainer.frame = RIGHT_FRAME;
	self.articleDisplayContainer.frame = self.view.bounds;

	self.feedVC = [self.storyboard instantiateViewControllerWithIdentifier:ID_FOR_FEEDVC];
	[self.feedContainer addSubview: self.feedVC.view];
	[self addChildViewController:self.feedVC];
	self.feedVC.delegate = self;

	self.mediaDevVC = [self.storyboard instantiateViewControllerWithIdentifier:ID_FOR_MEDIADEVVC];
	[self.adkContainer addSubview: self.mediaDevVC.view];
	[self addChildViewController:self.mediaDevVC];
	self.mediaDevVC.delegate = self;

	self.profileVC = [self.storyboard instantiateViewControllerWithIdentifier:ID_FOR_PROFILEVC];
	[self.profileContainer addSubview: self.profileVC.view];
	[self addChildViewController:self.profileVC];
    
    self.profileContainer.clipsToBounds = YES;
    
	self.articleDisplayVC = [self.storyboard instantiateViewControllerWithIdentifier:ID_FOR_DISPLAY_VC];
	[self.articleDisplayContainer addSubview: self.articleDisplayVC.view];
	self.articleDisplayContainer.alpha = 0;
	self.articleDisplayContainerFrameOffScreen = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
    
	[self addScreenEdgePanToArticleDisplay];
}

-(void) formatMainScrollView {
	self.masterSV.frame = self.view.bounds;
	self.masterSV.contentSize = CGSizeMake(self.view.frame.size.width* 3, 0);
	self.masterSV.contentOffset = CGPointMake(self.view.frame.size.width, 0);
	self.masterSV.pagingEnabled = YES;
	self.masterSV.scrollEnabled = YES;
    self.masterSV.delegate = self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.x < self.view.frame.size.width){
        [scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:NO];
    }
}


#pragma mark - Feed VC Delegate -

#pragma mark Article Display

-(void) displayPOVWithIndex:(NSInteger)index fromLoadManager:(POVLoadManager *)loadManager {
	[self.articleDisplayVC loadStory:index fromLoadManager:loadManager];
	[self.articleDisplayContainer setFrame:self.view.bounds];
	[self.articleDisplayContainer setBackgroundColor:[UIColor whiteColor]];
	self.articleDisplayContainer.alpha = 1;
	[self.view bringSubviewToFront: self.articleDisplayContainer];
	// Now tell selected cell in feed to be unpinched
	[self.feedVC deSelectCell];
}

#pragma mark Nav Buttons

//nav button is pressed - so we move the SV left to the profile
-(void) profileButtonPressed {
	if (![PFUser currentUser].isAuthenticated &&
		![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
		[self bringUpLogin];
	} else {
		[self showProfile];
	}
}

//nav button is pressed so we move the SV right to the ADK
-(void) adkButtonPressed {
	if (![PFUser currentUser].isAuthenticated &&
		![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
		[self bringUpLogin];
	} else {
		[self showADK];
        //[self performSegueWithIdentifier:@"presentADK" sender:self];
	}
}

// Scrolls the main scroll view over to reveal the ADK
-(void) showADK {
	[UIView animateWithDuration: MAIN_SCROLLVIEW_SCROLL_DURATION animations:^{
		self.masterSV.contentOffset = CGPointMake(self.view.frame.size.width * 2, 0);
	}];
}

-(void) showProfile {
	[UIView animateWithDuration: MAIN_SCROLLVIEW_SCROLL_DURATION animations:^{
		self.masterSV.contentOffset = CGPointMake(0, 0);
	}];
}

// Scrolls the main scroll view over to reveal the feed
-(void) showFeed {
	[UIView animateWithDuration: MAIN_SCROLLVIEW_SCROLL_DURATION animations:^{
		self.masterSV.contentOffset = CGPointMake(self.view.frame.size.width, 0);
	}completion:^(BOOL finished) {
		if(finished) {
		}
	}];
}

#pragma mark - Left edge screen pull for exiting article display vc -

-(void) addScreenEdgePanToArticleDisplay {
	UIPanGestureRecognizer* leftEdgePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(exitArticleDisplayView:)];
	leftEdgePanGesture.delegate = self;
	leftEdgePanGesture.minimumNumberOfTouches = 1;
	leftEdgePanGesture.maximumNumberOfTouches = 1;
	[self.articleDisplayContainer addGestureRecognizer: leftEdgePanGesture];
}


//called from left edge pan
- (void) exitArticleDisplayView:(UIPanGestureRecognizer *)sender {
	switch (sender.state) {
		case UIGestureRecognizerStateBegan: {
			if (sender.numberOfTouches < 1) return;
            CGPoint touchLocation = [sender locationOfTouch:0 inView: self.view];
            
            if((self.view.frame.size.height - CIRCLE_RADIUS - CIRCLE_OFFSET - 100)  < touchLocation.y) {
                //this ends the gesture
                sender.enabled = NO;
                sender.enabled =YES;
				return;
			}
			
			self.previousGesturePoint  = touchLocation;
			break;
		}
		case UIGestureRecognizerStateChanged: {
			if (sender.numberOfTouches < 1) return;
			CGPoint touchLocation = [sender locationOfTouch:0 inView: self.view];
			CGPoint currentPoint = touchLocation;
			int diff = currentPoint.x - self.previousGesturePoint.x;
            
            if((diff < 0) && ((self.articleDisplayContainer.frame.origin.x + diff) < 0)) //swiping left which is wrong so we end the gesture
            {
                //this ends the gesture
                sender.enabled = NO;
                sender.enabled =YES;
                break;
            }else {
                
                self.previousGesturePoint = currentPoint;
                self.articleDisplayContainer.frame = CGRectOffset(self.articleDisplayContainer.frame, diff, 0);
                break;
            }
		}
        case UIGestureRecognizerStateCancelled:{
            //should just fall into the next call
        }case UIGestureRecognizerStateEnded: {
			if(self.articleDisplayContainer.frame.origin.x > EXIT_EPSILON) {
				//exit article
				[self revealArticleDisplay:NO];
			}else{
				//return view to original position
				[self revealArticleDisplay:YES];
			}
			break;
		}
		default:
			break;
	}
}

// if show, return container view to its viewing position
// else remove it
-(void) revealArticleDisplay: (BOOL) show {
	if(show)  {
		[UIView animateWithDuration:ARTICLE_DISPLAY_REMOVAL_ANIMATION_DURATION animations:^{
			self.articleDisplayContainer.frame = self.view.bounds;
		} completion:^(BOOL finished) {
		}];
	}else {
		[UIView animateWithDuration:ARTICLE_DISPLAY_REMOVAL_ANIMATION_DURATION animations:^{
			self.articleDisplayContainer.frame = self.articleDisplayContainerFrameOffScreen;
		}completion:^(BOOL finished) {
			if(finished) {
				[self.articleDisplayVC cleanUp];
				[self.articleDisplayContainer setAlpha:0];
			}
		}];
	}
}

#pragma mark - PreviewDisplay delegate Methods (publish button pressed)

-(void) publishWithTitle:(NSString *)title andCoverPhoto:(UIImage *)coverPhoto andPinchViews:(NSArray *)pinchViews {
	
	if (![title length]) {
		[self.mediaDevVC alertAddTitle];
	} else if (!coverPhoto) {
		[self.mediaDevVC alertAddCoverPhoto];
	} else {

		if(![pinchViews count]) {
//			NSLog(@"Can't publish with no pinch objects");
			return;
		}

		POVPublisher* publisher = [[POVPublisher alloc] initWithPinchViews: pinchViews andTitle: title andCoverPic: coverPhoto];
		[publisher publish];

		NSString* userName = [self.userManager getCurrentUser].name;
		[self.feedVC showPOVPublishingWithUserName:userName andTitle: (NSString*) title andCoverPic: (UIImage*) coverPhoto andProgressObject: publisher.publishingProgress];
		[self showFeed];

		[self.mediaDevVC povPublished];
	}
}

#pragma mark - Media dev delegate methods -

-(void)adkViewChange:(BOOL)inCameraMode {
    
    if(inCameraMode){
        //turn off navigation scrollview
        self.masterSV.scrollEnabled = NO;
    }else{
        //turn on naviagtion scrollview
        self.masterSV.scrollEnabled = YES;
    }
    
}

-(void) backButtonPressed {
	[self showFeed];
}

-(void) previewPOVFromPinchViews:(NSArray *)pinchViews andCoverPic:(UIImage *)coverPic andTitle: (NSString*) title{
	[self.view bringSubviewToFront:self.previewDisplayView];
	[self.previewDisplayView displayPreviewPOVWithTitle:title andCoverPhoto:coverPic andPinchViews:pinchViews];
}

//for ios8- To hide the status bar
-(BOOL)prefersStatusBarHidden {
	return YES;
}


#pragma mark - Handle Login -


//brings up the create account page if there is no user logged in
-(void) bringUpLogin {
	//TODO: check user defaults and do login if they have logged in before
	[self performSegueWithIdentifier:CREATE_ACCOUNT_SEGUE sender:self];
}

//catches the unwind segue from login / create account
- (IBAction) unwindToMasterNavVC: (UIStoryboardSegue *)segue {
	self.masterSV.scrollEnabled = YES;
	// TODO: have variable set and go to profile or adk
	[self.profileVC updateUserInfo];
}


#pragma mark - Alerts -

-(void)alertPullTrendingIcon {
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Slide the black circle!" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[UserSetupParameters set_trendingCirle_InstructionAsShown];
}

-(void) userLostInternetConnection {
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Network. Please make sure you're connected WiFi or turn on data for this app in Settings." message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
}

#pragma mark - Network Connection Lost -

-(void)networkConnectionUpdate: (NSNotification *) notification{
    NSDictionary * userInfo = [notification userInfo];
    BOOL thereIsConnection = [self isThereConnectionFromString:[userInfo objectForKey:INTERNET_CONNECTION_KEY]];
    if(!thereIsConnection){
        [self userLostInternetConnection];
    }
}

-(BOOL)isThereConnectionFromString:(NSString *) key{
    if([key isEqualToString:@"YES"]){
        return YES;
    }
    return NO;
}


//delegate method from the Feed - prompts us to check internet connectivity
-(void) refreshingFeedsFailed {
    [self.connectionMonitor isConnectedToInternet_asynchronous];
}


#pragma mark - Memory Warning -
- (void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Lazy Instantiation -

-(UserManager*) userManager {
	if (!_userManager) _userManager = [UserManager sharedInstance];
	_userManager.delegate = self;
	return _userManager;
}

-(PreviewDisplayView*) previewDisplayView {
	if(!_previewDisplayView){
		_previewDisplayView = [[PreviewDisplayView alloc] initWithFrame: self.view.frame];
		_previewDisplayView.delegate = self;
		[self.view addSubview:_previewDisplayView];
	}
	return _previewDisplayView;
}

@end
