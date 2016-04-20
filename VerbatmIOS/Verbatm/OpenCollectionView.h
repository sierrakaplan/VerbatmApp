//
//  RearrangePV.h
//  Verbatm
//
//  Created by Iain Usiri on 11/15/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//
//	Holds a scrollview that displays an open collection pinch view, so that it can be edited

#import <UIKit/UIKit.h>
#import "PinchView.h"


@protocol OpenCollectionViewDelegate <NSObject>

//tells the delegate to exit and gives the final array order
-(void) collectionClosedWithFinalArray:(NSMutableArray *) pinchViews;

-(void)pinchViewSelected:(PinchView *) pv;

@end

@interface OpenCollectionView : UIView

@property (strong, nonatomic) id<OpenCollectionViewDelegate> delegate;

// array of PinchView
-(instancetype) initWithFrame:(CGRect)frame andPinchViewArray:(NSMutableArray *) pinchViewArray;

-(void) exitView;

@end
