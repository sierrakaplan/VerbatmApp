//
//  verbatmDashLineView.m
//  Verbatm
//
//  Created by Iain Usiri on 10/4/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "DashLineView.h"

@interface DashLineView ()
    @property (nonatomic, strong) CAShapeLayer * border;
@end

@implementation DashLineView

-(void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGFloat dashes[] = {6,6};
    CGContextSetLineDash(context, 0.0, dashes, 2);
    CGContextSetLineWidth(context, 4.0);
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextSetShouldAntialias(context, NO);
    CGContextStrokePath(context);
}

@end
