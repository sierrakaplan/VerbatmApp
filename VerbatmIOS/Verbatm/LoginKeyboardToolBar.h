//
//  LoginKeyboardToolBar.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/24/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginKeyboardToolBarDelegate <NSObject>

-(void) nextButtonPressed;

@end

@interface LoginKeyboardToolBar : UIView

@property (strong, nonatomic) id<LoginKeyboardToolBarDelegate> delegate;

-(void) setNextButtonText:(NSString*)text;

@end
