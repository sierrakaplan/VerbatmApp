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

@protocol RearrangePVProtocol <NSObject>

//tells the delegate
-(void)exitPV;

@end

@interface RearrangePV : UIView
    -(instancetype) initWithFrame:(CGRect)frame andPinchView: (PinchView *) pinchView;
    @property (strong, nonatomic) id<RearrangePVProtocol> delegate;
@end
