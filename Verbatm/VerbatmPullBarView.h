//
//  customPullBarView.h
//  Verbatm
//
//  Created by Iain Usiri on 1/10/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>
#import <UIKit/UIKitDefines.h>

@protocol PullBarDelegate <NSObject>

-(void)undoButtonPressed;
-(void)previewButtonPressed;
//-(void)keyboardButtonPressed;
//-(void)saveButtonPressed;

@end

@interface VerbatmPullBarView : UIView
    @property (nonatomic, strong) id<PullBarDelegate> customDelegate;

-(void)switchToPullUp;
-(void)switchToPullDown;

#define PULLBAR_HEIGHT_DOWN 50.f
#define PULLBAR_HEIGHT_UP 30.f

@end
