//
//  HomeNavPullBar.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/4/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HomeNavBarDelegate <NSObject>

-(void) profileButtonPressed;
-(void) adkButtonPressed;
-(void) homeButtonPressed;

@end

@interface HomeNavBar : UIView

@property (strong, nonatomic) id<HomeNavBarDelegate> delegate;

@end
