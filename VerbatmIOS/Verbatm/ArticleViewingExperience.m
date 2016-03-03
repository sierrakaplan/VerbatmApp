//
//  BaseAVE.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/1/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "ArticleViewingExperience.h"

@implementation ArticleViewingExperience

-(instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if(self){
        self.clipsToBounds = YES;
        [self createBorder];
    }
    
    return self;
}


-(void)createBorder{
    [self.layer setBorderWidth:0.5];
    [self.layer setCornerRadius:0.0];
    [self.layer setBorderColor:[UIColor blackColor].CGColor];
}


-(void)onScreen {}

-(void)offScreen {}

-(void)almostOnScreen {}

@end
