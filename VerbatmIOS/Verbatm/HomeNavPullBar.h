//
//  HomeNavPullBar.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/4/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HomeNavPullBarDelegate <NSObject>

-(void) profileButtonPressed;
-(void) adkButtonPressed;

@end

@interface HomeNavPullBar : UIView

@property (strong, nonatomic) id<HomeNavPullBarDelegate> delegate;

@end
