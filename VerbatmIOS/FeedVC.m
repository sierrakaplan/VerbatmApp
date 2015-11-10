//
//  feedDisplayTVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleDisplayVC.h"
#import "ArticleListVC.h"
#import "Durations.h"
#import "FeedTableViewCell.h"
#import "Icons.h"
#import "InternetConnectionMonitor.h"
#import "FeedVC.h"
#import "Notifications.h"
#import "POVLoadManager.h"
#import "SwitchCategoryPullView.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "TopicsFeedVC.h"
#import "Durations.h"

@interface FeedVC () <SwitchCategoryDelegate, ArticleListVCDelegate, ArticleDisplayVCDelegate, UIGestureRecognizerDelegate>

#pragma mark - Category Switcher -

@property (strong, nonatomic) SwitchCategoryPullView *categorySwitch;

#pragma mark - List View Controllers (trending + recent) -

// There are two article list views faded between by the category switcher at the top
@property (weak, nonatomic) IBOutlet UIView *topListContainer;
@property (weak, nonatomic) IBOutlet UIView *bottomListContainer;

@property (strong,nonatomic) ArticleListVC* trendingVC;
@property (strong,nonatomic) ArticleListVC* mostRecentVC;
// NOT IN USE NOW
//@property (strong,nonatomic) TopicsFeedVC* topicsVC;

#define TOPICS_VC_ID @"topics_feed_vc"
#define RECENT_VC_ID @"most_recent_vc"
#define TRENDING_VC_ID @"trending_vc"

#pragma mark - Article Display View Controller -

@property (nonatomic) CGRect articleDisplayContainerFrameOffScreen;
@property (weak, nonatomic) IBOutlet UIView *articleDisplayContainerView;
@property (strong, nonatomic) ArticleDisplayVC* articleDisplayVC;

#define ARTICLE_DISPLAY_VC_ID @"article_display_vc"

#pragma mark Gesture for pulling out of article display view

@property (nonatomic) CGPoint previousGesturePoint;

@end


@implementation FeedVC

-(void)viewDidLoad {
	[super viewDidLoad];
	[self.view setBackgroundColor:[UIColor colorWithRed:FEED_BACKGROUND_COLOR green:FEED_BACKGROUND_COLOR blue:FEED_BACKGROUND_COLOR alpha:1.f]];

	[self setUpCategorySwitcher];
	[self positionContainerViews];
	[self setUpListVCs];
	[self setUpArticleDisplayVC];
	[self registerForNotifications];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void)registerForNotifications{
	//gets notified if there is no internet connection
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(networkConnectionUpdate:)
												 name:INTERNET_CONNECTION_NOTIFICATION
											   object:nil];
}

#pragma mark - Getting and formatting child view controllers -

-(void) setUpCategorySwitcher {
	float categorySwitchWidth = self.view.frame.size.width;
	CGRect categorySwitchFrame = CGRectMake((self.view.frame.size.width - categorySwitchWidth)/2.f,
											BELOW_STATUS_BAR, categorySwitchWidth, TITLE_BAR_HEIGHT);
	self.categorySwitch = [[SwitchCategoryPullView alloc] initWithFrame:categorySwitchFrame andBackgroundColor: self.view.backgroundColor];
	self.categorySwitch.categorySwitchDelegate = self;
	[self.view addSubview:self.categorySwitch];
}

//position the container views in appropriate places and set frames
-(void) positionContainerViews {
	float listContainerY = self.categorySwitch.frame.origin.y + self.categorySwitch.frame.size.height;
	self.topListContainer.frame = CGRectMake(0, listContainerY,
											 self.view.frame.size.width,
											 self.view.frame.size.height - listContainerY);
	self.bottomListContainer.frame = self.topListContainer.frame;
	self.bottomListContainer.alpha = 0;
}

//lays out all the containers in the right position and also sets the appropriate
//offset for the master SV
-(void) setUpListVCs {
	self.trendingVC = [self.storyboard instantiateViewControllerWithIdentifier:TRENDING_VC_ID];
	[self.trendingVC setPovLoadManager: [[POVLoadManager alloc]
										 initWithType: POVTypeTrending] andCellBackgroundColor:self.view.backgroundColor];
	self.trendingVC.delegate = self;

	self.mostRecentVC = [self.storyboard instantiateViewControllerWithIdentifier:RECENT_VC_ID];
	[self.mostRecentVC setPovLoadManager: [[POVLoadManager alloc] initWithType: POVTypeRecent] andCellBackgroundColor:self.view.backgroundColor];
	self.mostRecentVC.delegate = self;
    
	[self.topListContainer addSubview: self.trendingVC.view];
	[self.bottomListContainer addSubview: self.mostRecentVC.view];
}

-(void) setUpArticleDisplayVC {
	self.articleDisplayContainerFrameOffScreen = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
	self.articleDisplayContainerView.frame = self.view.bounds;
	[self.articleDisplayContainerView setBackgroundColor:[UIColor AVE_BACKGROUND_COLOR]];
	self.articleDisplayContainerView.alpha = 0;

	self.articleDisplayVC = [self.storyboard instantiateViewControllerWithIdentifier:ARTICLE_DISPLAY_VC_ID];
	[self.articleDisplayContainerView addSubview: self.articleDisplayVC.view];
	[self addChildViewController:self.articleDisplayVC];
	self.articleDisplayVC.delegate = self;
	[self addScreenPanToArticleDisplay];
}

#pragma mark - Switch Category Pull View delegate methods -

// pull circle was panned ratio of the total distance
-(void) pullCircleDidPan: (CGFloat)ratio {
    self.topListContainer.alpha = ratio;
    self.bottomListContainer.alpha = 1 - ratio;
}

// pull circle was released and snapped to one edge or the other
-(void) snapped: (BOOL)snappedLeft {
	[UIView animateWithDuration:SNAP_ANIMATION_DURATION animations: ^ {
		if (snappedLeft) {
			self.topListContainer.alpha = 0;
			self.bottomListContainer.alpha = 1;
		} else {
			self.topListContainer.alpha = 1;
			self.bottomListContainer.alpha = 0;
		}
	}];
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

#pragma mark - Show recently published POV -

-(void) showPOVPublishingWithUserName: (NSString*)userName andTitle: (NSString*) title andCoverPic: (UIImage*) coverPic
					andProgressObject:(NSProgress *)publishingProgress {
	[self.categorySwitch snapToEdgeLeft:YES];
	[self.mostRecentVC showPOVPublishingWithUserName:userName andTitle: (NSString*) title
										 andCoverPic: (UIImage*) coverPic andProgressObject: publishingProgress];
}

#pragma mark - Article List VC Delegate Methods (display articles) -

-(void)failedToRefreshFeed{
	[[InternetConnectionMonitor sharedInstance] isConnectedToInternet_asynchronous];
}

-(void) displayPOVOnCell:(FeedTableViewCell *)cell withLoadManager:(POVLoadManager *)loadManager {
	[self.delegate showTabBar:NO];
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	[self.articleDisplayVC loadStoryAtIndex:cell.indexPath.row fromLoadManager:loadManager];
	self.articleDisplayContainerView.frame = self.view.bounds;
	self.articleDisplayContainerView.alpha = 1;
	[self.view bringSubviewToFront: self.articleDisplayContainerView];

	// notify cell it can unpinch now
	[cell deSelect];
}

#pragma mark - Left screen pull for exiting article display vc -

-(void) addScreenPanToArticleDisplay {
	UIPanGestureRecognizer* leftEdgePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(exitArticleDisplayView:)];
	leftEdgePanGesture.delegate = self;
	leftEdgePanGesture.minimumNumberOfTouches = 1;
	leftEdgePanGesture.maximumNumberOfTouches = 1;
	[self.articleDisplayContainerView addGestureRecognizer: leftEdgePanGesture];
}

//called from left edge pan
- (void) exitArticleDisplayView:(UIPanGestureRecognizer *)sender {
	switch (sender.state) {
		case UIGestureRecognizerStateBegan: {
			if (sender.numberOfTouches < 1) return;
			CGPoint touchLocation = [sender locationOfTouch:0 inView: self.view];

			if((self.view.frame.size.height - CIRCLE_RADIUS - CIRCLE_OFFSET - 100) < touchLocation.y) {
				//this ends the gesture
				sender.enabled = NO;
				sender.enabled =YES;
				return;
			}
			self.previousGesturePoint = touchLocation;
			break;
		}
		case UIGestureRecognizerStateChanged: {
			if (sender.numberOfTouches < 1) return;
			CGPoint touchLocation = [sender locationOfTouch:0 inView: self.view];
			CGPoint currentPoint = touchLocation;
			int diff = currentPoint.x - self.previousGesturePoint.x;
			//swiping left which is wrong so we end the gesture
			if((diff < 0) && ((self.articleDisplayContainerView.frame.origin.x + diff) < 0)) {
				//this ends the gesture
				sender.enabled = NO;
				sender.enabled =YES;
				break;
			}else {
				self.previousGesturePoint = currentPoint;
				self.articleDisplayContainerView.frame = CGRectOffset(self.articleDisplayContainerView.frame, diff, 0);
				break;
			}
		}case UIGestureRecognizerStateCancelled:
		 case UIGestureRecognizerStateEnded: {
			if(self.articleDisplayContainerView.frame.origin.x > ARTICLE_DISPLAY_EXIT_EPSILON) {
				[self revealArticleDisplay:NO];
			} else{
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
			self.articleDisplayContainerView.frame = self.view.bounds;
		} completion:^(BOOL finished) {
		}];
	}else {
		[UIView animateWithDuration:ARTICLE_DISPLAY_REMOVAL_ANIMATION_DURATION animations:^{
			self.articleDisplayContainerView.frame = self.articleDisplayContainerFrameOffScreen;
		}completion:^(BOOL finished) {
			if(finished) {
				[self.articleDisplayVC cleanUp];
				[self.articleDisplayContainerView setAlpha:0];
				[self.delegate showTabBar:YES];
				[[UIApplication sharedApplication] setStatusBarHidden:NO];
			}
		}];
	}
}

#pragma mark - Article Display Delegate methods -

-(void) userLiked:(BOOL)liked POV:(PovInfo *)povInfo {
	[self.mostRecentVC userHasLikedPOV:liked withPovInfo:povInfo];
	[self.trendingVC userHasLikedPOV:liked withPovInfo:povInfo];
}

@end
