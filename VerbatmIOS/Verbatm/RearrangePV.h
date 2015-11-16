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
@interface RearrangePV : UIView
-(instancetype) initWithFrame:(CGRect)frame andPinchView: (PinchView *) pinchView;
@end
