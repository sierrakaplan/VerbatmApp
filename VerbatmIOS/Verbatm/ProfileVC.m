//
//  profileVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleDisplayVC.h"
#import "ArticleListVC.h"
#import "Durations.h"
#import "FeedTableViewCell.h"
#import "GTLVerbatmAppVerbatmUser.h"
#import "InternetConnectionMonitor.h"
#import "POVLoadManager.h"
#import "ProfileVC.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "UserManager.h"
#import "UserDraftsVC.h"

@interface ProfileVC() <UITabBarDelegate, UIGestureRecognizerDelegate, ArticleListVCDelegate, ArticleDisplayVCDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
// weak reference to shared reference
@property (weak, nonatomic) GTLVerbatmAppVerbatmUser* currentUser;

#pragma mark - Tab Bar -

@property (strong, nonatomic) UITabBar* customTabBar;

#pragma mark Tab Bar Items
@property (strong, nonatomic) UITabBarItem* storiesTab;
@property (strong, nonatomic) UITabBarItem* draftsTab;

#pragma mark - Tab View Controllers -

@property (weak, nonatomic) IBOutlet UIView *storiesContainerView;
@property (weak, nonatomic) IBOutlet UIView *draftsContainerView;

#define USER_STORIES_VC_ID @"user_stories_vc"
#define USER_DRAFTS_VC_ID @"user_drafts_vc"

@property (strong, nonatomic) ArticleListVC* userStoriesVC;
@property (strong, nonatomic) UserDraftsVC* userDraftsVC;

#pragma mark - Article Display View Controller -

@property (nonatomic) CGRect articleDisplayContainerFrameOffScreen;
@property (weak, nonatomic) IBOutlet UIView *articleDisplayContainerView;
@property (strong, nonatomic) ArticleDisplayVC* articleDisplayVC;

#pragma mark Gesture for pulling out of article display view

@property (nonatomic) CGPoint previousGesturePoint;

#define ARTICLE_DISPLAY_VC_ID @"user_article_display_vc"

#define TITLE_FONT_SIZE 24.f
#define TAB_BAR_HEIGHT 60.f

@end

@implementation ProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
	[self updateUserInfo];
    [self formatTitleLabel];
	[self addTabBar];
	[self formatContainerViews];
	[self setUpTabVCs];
	[self setUpArticleDisplayVC];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void) updateUserInfo {
	self.currentUser = [[UserManager sharedInstance] getCurrentUser];
	self.userNameLabel.text = self.currentUser.name;
}

-(void) formatTitleLabel {
    self.userNameLabel.frame = CGRectMake(self.view.center.x - (self.userNameLabel.frame.size.width/2),
										  self.userNameLabel.frame.origin.y, self.userNameLabel.frame.size.width,
                                          self.userNameLabel.frame.size.height);
	self.userNameLabel.font = [UIFont fontWithName:TITLE_TEXT_FONT size:TITLE_FONT_SIZE];
}

-(void) addTabBar {
	self.customTabBar.items = @[self.storiesTab, self.draftsTab];
	self.customTabBar.selectedItem = self.storiesTab;
	[self.view addSubview:self.customTabBar];
}

-(void) formatContainerViews {
	CGFloat tabViewYPos = self.customTabBar.frame.origin.y + self.customTabBar.frame.size.height;
	CGRect tabViewFrame = CGRectMake(0.f, tabViewYPos, self.view.frame.size.width, self.view.frame.size.height - tabViewYPos);
	self.storiesContainerView.frame = tabViewFrame;
	self.draftsContainerView.frame = tabViewFrame;

	self.storiesContainerView.alpha = 1;
	self.draftsContainerView.alpha = 0;

	[self.storiesContainerView setBackgroundColor:[UIColor redColor]];
}

-(void) setUpTabVCs {
	self.userDraftsVC = [self.storyboard instantiateViewControllerWithIdentifier:USER_DRAFTS_VC_ID];
	self.userStoriesVC = [self.storyboard instantiateViewControllerWithIdentifier:USER_STORIES_VC_ID];
	//TODO: delete this
	NSNumber* aishwaryaId = [NSNumber numberWithLongLong:5432098273886208];
	[self.userStoriesVC setPovLoadManager:[[POVLoadManager alloc] initWithUserId: aishwaryaId]//self.currentUser.identifier]
				   andCellBackgroundColor:[UIColor whiteColor]];
	self.userStoriesVC.delegate = self;

	[self.storiesContainerView addSubview:self.userStoriesVC.view];
	[self.draftsContainerView addSubview:self.userDraftsVC.view];
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


#pragma mark - Tab Bar Delegate methods -

-(void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
	if (item == self.storiesTab) {
		self.storiesContainerView.alpha = 1;
		self.draftsContainerView.alpha = 0;
	} else if (item == self.draftsTab) {
		self.storiesContainerView.alpha = 0;
		self.draftsContainerView.alpha = 1;
	}
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
	// do nothing
}

#pragma mark - Lazy Instantiation -

-(UITabBar*) customTabBar {
	if (!_customTabBar) {
		_customTabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0.f, self.userNameLabel.frame.origin.y + self.userNameLabel.frame.size.height,
																	   self.view.frame.size.width, TAB_BAR_HEIGHT)];
		_customTabBar.barTintColor = [UIColor whiteColor];
		_customTabBar.tintColor = [UIColor lightGrayColor];
		_customTabBar.delegate = self;
	}
	return _customTabBar;
}

-(UITabBarItem*) storiesTab {
	if (!_storiesTab) {
		_storiesTab = [[UITabBarItem alloc] initWithTitle:@"STORIES" image:nil selectedImage:nil];
	}
	return _storiesTab;
}

-(UITabBarItem*) draftsTab {
	if (!_draftsTab) {
		_draftsTab = [[UITabBarItem alloc] initWithTitle:@"DRAFTS" image:nil selectedImage:nil];
	}
	return _draftsTab;
}

@end
