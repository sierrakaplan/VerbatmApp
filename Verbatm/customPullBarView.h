//
//  customPullBarView.h
//  Verbatm
//
//  Created by Iain Usiri on 1/10/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol pullBarDelegate <NSObject>

-(void)undoButtonPressed;
-(void)previewButtonPressed;
-(void)keyboardButtonPressed;

@end

@interface customPullBarView : UIView
    @property (nonatomic, strong) id<pullBarDelegate> customeDelegate;
@end
