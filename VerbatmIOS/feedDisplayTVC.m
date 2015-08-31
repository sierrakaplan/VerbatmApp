//
//  feedDisplayTVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "feedDisplayTVC.h"
#import "userFeedCategorySwitch.h"

@interface feedDisplayTVC ()<userFeedCategorySwitchProtocal>
@property (weak, nonatomic) IBOutlet UIView *articleListContainer;
@property (weak, nonatomic) IBOutlet userFeedCategorySwitch *categorySwitch;
@property (weak, nonatomic) IBOutlet UIView *topicsListContainer;


#define CATEGORY_SWITCH_HEIGHT 80 //frame height

@end


@implementation feedDisplayTVC

-(void)viewDidLoad {
    self.categorySwitch.categorySwitchDelegate = self;
}

-(void)pullCircleDidPan:(CGFloat) pullCirlcePostionRatio {
    self.articleListContainer.alpha = pullCirlcePostionRatio;
    self.topicsListContainer.alpha = 1 - pullCirlcePostionRatio;
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
