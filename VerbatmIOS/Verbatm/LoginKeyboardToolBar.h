//
//  LoginKeyboardToolBar.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/24/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//
// 	This class is the large orange button that appears over the keyboard during
// 	the login flow.

#import <UIKit/UIKit.h>

@protocol LoginKeyboardToolBarDelegate <NSObject>

-(void) nextButtonPressed;

@end

@interface LoginKeyboardToolBar : UIView

@property (weak, nonatomic) id<LoginKeyboardToolBarDelegate> delegate;

-(void) setNextButtonText:(NSString*)text;

@end
