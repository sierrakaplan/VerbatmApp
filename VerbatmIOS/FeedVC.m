//
//  feedDisplayTVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "HomeNavPullBar.h"
#import "Icons.h"
#import "FeedVC.h"
#import "SwitchCategoryPullView.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "Durations.h"

@interface FeedVC ()<SwitchCategoryDelegate, HomeNavPullBarDelegate>

@property (strong, nonatomic) SwitchCategoryPullView *categorySwitch;
@property (strong, nonatomic) HomeNavPullBar* navPullBar;

@property (weak, nonatomic) IBOutlet UIView *articleListContainer;
@property (weak, nonatomic) IBOutlet UIView *topicsListContainer;

@end


@implementation FeedVC

-(void)viewDidLoad {
	[super viewDidLoad];
	[self.view setBackgroundColor:[UIColor colorWithRed:FEED_BACKGROUND_COLOR green:FEED_BACKGROUND_COLOR blue:FEED_BACKGROUND_COLOR alpha:1.f]];

	[self positionViews];
	[self setUpNavPullBar];
	[self setUpCategorySwitcher];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void) setUpNavPullBar {
	CGRect navPullBarFrame = CGRectMake(self.view.frame.origin.x,
										self.view.frame.size.height - HOME_NAV_HEIGHT,
										self.view.frame.size.width, HOME_NAV_HEIGHT);
	self.navPullBar = [[HomeNavPullBar alloc] initWithFrame:navPullBarFrame];
	self.navPullBar.delegate = self;
	[self.view addSubview:self.navPullBar];
}

-(void) setUpCategorySwitcher {
	float categorySwitchWidth = self.view.frame.size.width * 3.f/4.f;
	CGRect categorySwitchFrame = CGRectMake((self.view.frame.size.width - categorySwitchWidth)/2.f,
											CATEGORY_SWITCH_OFFSET, categorySwitchWidth, CATEGORY_SWITCH_HEIGHT);
	self.categorySwitch = [[SwitchCategoryPullView alloc] initWithFrame:categorySwitchFrame andBackgroundColor:self.view.backgroundColor];
	self.categorySwitch.categorySwitchDelegate = self;
	[self.view addSubview:self.categorySwitch];
}

-(void) profileButtonPressed {
	[self.delegate profileButtonPressed];
}

-(void) adkButtonPressed {
	[self.delegate adkButtonPressed];
}


#pragma mark - Switch Category Pull View delegate methods -

// pull circle was panned ratio of the total distance
-(void) pullCircleDidPan: (CGFloat)ratio {
    self.articleListContainer.alpha = ratio;
    self.topicsListContainer.alpha = 1 - ratio;
}

// pull circle was released and snapped to one edge or the other
-(void) snapped: (BOOL)snappedLeft {

	[UIView animateWithDuration:SNAP_ANIMATION_DURATION animations: ^ {
		if (snappedLeft) {
			self.articleListContainer.alpha = 0;
			self.topicsListContainer.alpha = 1;
		} else {
			self.articleListContainer.alpha = 1;
			self.topicsListContainer.alpha = 0;
		}
	}];
}

//position the views in appropriate places and set frames
-(void) positionViews {
	float listContainerY = CATEGORY_SWITCH_HEIGHT + CATEGORY_SWITCH_OFFSET*2;
    self.articleListContainer.frame = CGRectMake(0, listContainerY,
												 self.view.frame.size.width,
												 self.view.frame.size.height - listContainerY);
    self.topicsListContainer.frame = self.articleListContainer.frame;
    self.topicsListContainer.alpha = 0;
}

-(void) refreshFeed {
	//TODO: refresh whatever feed is in view
}





@end
