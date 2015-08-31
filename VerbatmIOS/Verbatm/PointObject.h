//
//  CGPointWrapper.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
// Alternative for CGPoint since a struct can't be put into an array

#import <Foundation/Foundation.h>

@interface PointObject : NSObject

@property (nonatomic) float x;
@property (nonatomic) float y;

-(CGPoint) getCGPoint;

@end