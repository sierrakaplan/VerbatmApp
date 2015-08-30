//
//  feedDisplayTVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "feedDisplayTVC.h"
#import "userFeedCategorySwitch.h"

@interface feedDisplayTVC ()
@property (weak, nonatomic) IBOutlet UIView *articleListContainer;
@property (weak, nonatomic) IBOutlet userFeedCategorySwitch *categorySwitch;


#define CATEGORY_SWITCH_HEIGHT 80 //frame height

@end


@implementation feedDisplayTVC

-(void)viewDidLoad {
    
}

//position the views in appropriate places and set frames
-(void)positionViews {
    
    self.articleListContainer.frame = CGRectMake(0, CATEGORY_SWITCH_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - CATEGORY_SWITCH_HEIGHT);
    self.categorySwitch.frame = CGRectMake(0, 0, self.view.frame.size.width,CATEGORY_SWITCH_HEIGHT);
}


-(void)viewWillAppear:(BOOL)animated {
    [self positionViews];
}

-(void)viewDidAppear:(BOOL)animated {
    
}




@end
