//
//  feedDisplayTVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "feedDisplayTVC.h"
#import "userFeedCategorySwitch.h"
#import "SizesAndPositions.h"

@interface feedDisplayTVC ()<userFeedCategorySwitchProtocal>

@property (weak, nonatomic) IBOutlet userFeedCategorySwitch *categorySwitch;
@property (weak, nonatomic) IBOutlet UIButton *profileNavButton;
@property (weak, nonatomic) IBOutlet UIButton *adkNavButton;

@property (weak, nonatomic) IBOutlet UIView *articleListContainer;
@property (weak, nonatomic) IBOutlet UIView *topicsListContainer;


#define CATEGORY_SWITCH_HEIGHT 80 //frame height

@end


@implementation feedDisplayTVC

-(void)viewDidLoad {
    self.categorySwitch.categorySwitchDelegate = self;
	[self setUpNavButtons];
}

//position the nav views in appropriate places and set frames
-(void)setUpNavButtons {
	self.profileNavButton.frame = CGRectMake(self.view.frame.size.width + NAVICON_WALL_OFFSET, self.view.frame.size.height - NAVICON_WALL_OFFSET -
											 NAVICON_HEIGHT, NAVICON_WIDTH, NAVICON_HEIGHT);
	self.adkNavButton.frame = CGRectMake((self.view.frame.size.width*2) - NAVICON_WALL_OFFSET - NAVICON_WIDTH,
										 self.profileNavButton.frame.origin.y, NAVICON_WIDTH, NAVICON_HEIGHT);

	[self.profileNavButton addTarget:self action:@selector(profileButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.adkNavButton addTarget:self action:@selector(adkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

	[self.view bringSubviewToFront:self.profileNavButton];
	[self.view bringSubviewToFront:self.adkNavButton];
}

-(void) profileButtonPressed:(UIButton*) sender {
	[self.navButtonsDelegate profileButtonPressed];
}

-(void) adkButtonPressed:(UIButton*) sender {
	[self.navButtonsDelegate adkButtonPressed];
}

-(void)pullCircleDidPan:(CGFloat) pullCirclePositionRatio {
    self.articleListContainer.alpha = pullCirclePositionRatio;
    self.topicsListContainer.alpha = 1 - pullCirclePositionRatio;
}

//tells a delegate object that the user just switched to trending content
-(void) switchedToTrending {
    self.articleListContainer.alpha = 1;
    self.topicsListContainer.alpha = 0;
}

//tells a delegate object that the user just switched to topics content
-(void) switchedToTopics {
    self.articleListContainer.alpha = 0;
    self.topicsListContainer.alpha = 1;
}

//position the views in appropriate places and set frames
-(void) positionViews {
    self.articleListContainer.frame = CGRectMake(0, CATEGORY_SWITCH_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - CATEGORY_SWITCH_HEIGHT);
    self.categorySwitch.frame = CGRectMake(0, 0, self.view.frame.size.width,CATEGORY_SWITCH_HEIGHT);
    self.topicsListContainer.frame = self.articleListContainer.frame;
    self.topicsListContainer.alpha = 0;
}


-(void) viewWillAppear:(BOOL)animated {
    [self positionViews];
}

-(void) viewDidAppear:(BOOL)animated {
    
}




@end
