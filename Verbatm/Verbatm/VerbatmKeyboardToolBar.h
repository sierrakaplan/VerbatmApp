//
//  VerbatmKeyboardToolBar.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/25/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KeyboardToolBarDelegate <NSObject>

-(void)doneButtonPressed;

@end

@interface VerbatmKeyboardToolBar : UIView

@property (nonatomic, strong) id<KeyboardToolBarDelegate> delegate;

@end
