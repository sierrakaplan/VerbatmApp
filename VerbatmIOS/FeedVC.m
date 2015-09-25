//
//  feedDisplayTVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleDisplayVC.h"
#import "ArticleListVC.h"
#import "FeedTableViewCell.h"
#import "HomeNavPullBar.h"
#import "Icons.h"
#import "FeedVC.h"
#import "POVLoadManager.h"
#import "SwitchCategoryPullView.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "TopicsFeedVC.h"
#import "Durations.h"

@interface FeedVC ()<SwitchCategoryDelegate, HomeNavPullBarDelegate, ArticleListVCDelegate>

@property (strong, nonatomic) SwitchCategoryPullView *categorySwitch;
@property (strong, nonatomic) HomeNavPullBar* navPullBar;
// Keeps track of which cell is selected when an article is being viewed
@property (strong, nonatomic) FeedTableViewCell* selectedCell;

#pragma mark - Child View Controllers -

// There are two article list views faded between by the category switcher at the top
@property (weak, nonatomic) IBOutlet UIView *topListContainer;
@property (weak, nonatomic) IBOutlet UIView *bottomListContainer;

@property (strong,nonatomic) ArticleListVC* trendingVC;
@property (strong,nonatomic) ArticleListVC* mostRecentVC;
// NOT IN USE NOW
//@property (strong,nonatomic) TopicsFeedVC* topicsVC;

#define ID_FOR_TOPICS_VC @"topics_feed_vc"
#define ID_FOR_RECENT_VC @"most_recent_vc"
#define ID_FOR_TRENDING_VC @"trending_vc"

@end


@implementation FeedVC

-(void)viewDidLoad {
	[super viewDidLoad];
	[self.view setBackgroundColor:[UIColor colorWithRed:FEED_BACKGROUND_COLOR green:FEED_BACKGROUND_COLOR blue:FEED_BACKGROUND_COLOR alpha:1.f]];

	[self positionContainerViews];
	[self getAndFormatVCs];

	[self setUpNavPullBar];
	[self setUpCategorySwitcher];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

#pragma mark - Getting and formatting child view controllers -
//position the container views in appropriate places and set frames
-(void) positionContainerViews {
	float listContainerY = CATEGORY_SWITCH_HEIGHT + CATEGORY_SWITCH_OFFSET*2;
	self.topListContainer.frame = CGRectMake(0, listContainerY,
											 self.view.frame.size.width,
											 self.view.frame.size.height - listContainerY);
	self.bottomListContainer.frame = self.topListContainer.frame;
	self.bottomListContainer.alpha = 0;
}

//lays out all the containers in the right position and also sets the appropriate
//offset for the master SV
-(void) getAndFormatVCs {
	self.trendingVC = [self.storyboard instantiateViewControllerWithIdentifier:ID_FOR_TRENDING_VC];
	[self.trendingVC setPovLoadManager: [[POVLoadManager alloc] initWithType: POVTypeTrending]];
	self.trendingVC.delegate = self;

	self.mostRecentVC = [self.storyboard instantiateViewControllerWithIdentifier:ID_FOR_RECENT_VC];
	[self.mostRecentVC setPovLoadManager: [[POVLoadManager alloc] initWithType: POVTypeRecent]];
	self.mostRecentVC.delegate = self;
    
	[self.topListContainer addSubview: self.trendingVC.view];
	[self.bottomListContainer addSubview: self.mostRecentVC.view];
}

#pragma mark - Formatting sub views -

-(void) setUpNavPullBar {
	CGRect navPullBarFrame = CGRectMake(self.view.frame.origin.x,
										self.view.frame.size.height - NAV_BAR_HEIGHT,
										self.view.frame.size.width, NAV_BAR_HEIGHT);
	self.navPullBar = [[HomeNavPullBar alloc] initWithFrame:navPullBarFrame];
	self.navPullBar.delegate = self;
	[self.view addSubview: self.navPullBar];
}


-(void) setUpCategorySwitcher {
	float categorySwitchWidth = self.view.frame.size.width;
	CGRect categorySwitchFrame = CGRectMake((self.view.frame.size.width - categorySwitchWidth)/2.f,
											CATEGORY_SWITCH_OFFSET, categorySwitchWidth, CATEGORY_SWITCH_HEIGHT);
	self.categorySwitch = [[SwitchCategoryPullView alloc] initWithFrame:categorySwitchFrame andBackgroundColor: self.view.backgroundColor];
	self.categorySwitch.categorySwitchDelegate = self;
	[self.view addSubview:self.categorySwitch];
}

-(void) profileButtonPressed{
	[self.delegate profileButtonPressed];
}

-(void) adkButtonPressed {
	[self.delegate adkButtonPressed];
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

#pragma mark - Show recently published POV -

-(void) showPOVPublishingWithTitle: (NSString*) title andCoverPic: (UIImage*) coverPic {
	[self.categorySwitch snapToEdgeLeft:YES];
	[self.mostRecentVC showPOVPublishingWithTitle: (NSString*) title andCoverPic: (UIImage*) coverPic];
}

#pragma mark - Article List VC Delegate Methods (display articles) -
-(void)failedToRefreshFeed{
    [self.delegate refreshingFeedsFailed];
}

-(void) displayPOVOnCell:(FeedTableViewCell *)cell withLoadManager:(POVLoadManager *)loadManager {
	// Do this in the master vc so it can be above the main scroll view
	self.selectedCell = cell;
	[self.delegate displayPOVWithIndex: cell.indexPath.row fromLoadManager:loadManager];
}

-(void) deSelectCell {
	[self.selectedCell deSelect];
	self.selectedCell = nil;
}


@end
