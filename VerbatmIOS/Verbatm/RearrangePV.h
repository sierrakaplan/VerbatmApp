//
//  RearrangePV.h
//  Verbatm
//
//  Created by Iain Usiri on 11/15/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PinchView.h"
/*
 Holds the scrollview that displays an open pinchivew 
 */

@protocol RearrangePVDelegate <NSObject>

//tells the delegate to exit and gives the final array order
-(void)exitPVWithFinalArray:(NSMutableArray *) pvArray;

@end

@interface RearrangePV : UIView
    -(instancetype) initWithFrame:(CGRect)frame andPinchViewArray:(NSMutableArray * ) pinchViewArray;
    @property (strong, nonatomic) id<RearrangePVDelegate> delegate;
    -(void) exitRearrangeView;
@end
