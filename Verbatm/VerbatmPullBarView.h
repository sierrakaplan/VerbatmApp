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
@end
