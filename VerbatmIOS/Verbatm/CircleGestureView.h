//
//  CircleGestureView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
// View contains circle and points that allow for transitioning between views (like photoave)

#import <UIKit/UIKit.h>

@interface CircleGestureView : UIView

@property (strong, nonatomic) NSMutableArray* pointsOnCircle;
@property (nonatomic) CGPoint originPoint;
@property (nonatomic) float circleRadius;

-(id) initWithFrame:(CGRect)frame andRadius:(float)radius andNumDots:(NSInteger) numDots;
-(void) highlightDotAtIndex:(NSInteger) index;

@end
