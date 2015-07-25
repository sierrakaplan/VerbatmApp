//
//  MathOperations.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/24/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PointObject.h"

@interface MathOperations : NSObject

+(PointObject*) getPointFromCircleRadius:(float)radius andCurrentPointIndex:(NSInteger)index withTotalPoints:(NSUInteger)total;
+ (BOOL) point:(CGPoint)point onCircleWithRadius:(float)radius andOrigin:(CGPoint)origin withThreshold:(float)threshold;
+ (float) distanceBetweenTwoPoints:(CGPoint)pointOne and:(CGPoint)pointTwo;

// angle and distance can be negative
+ (float) calculateAngleBetweenTwoPoints:(CGPoint)pointOne and:(CGPoint)pointTwo onCircleWithOrigin: (CGPoint) origin;
+ (float) distanceBetweenTwoPoints:(CGPoint)pointOne and:(CGPoint)pointTwo onCircleWithRadius:(float) radius andOrigin: (CGPoint) origin;

+ (float) calculateAngleClockwiseBetweenTwoPoints:(CGPoint)pointOne and:(CGPoint)pointTwo onCircleWithOrigin: (CGPoint) origin;
+ (float) distanceClockwiseBetweenTwoPoints:(CGPoint)pointOne and:(CGPoint)pointTwo onCircleWithRadius:(float) radius andOrigin: (CGPoint) origin;
@end
