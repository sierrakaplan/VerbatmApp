//
//  MathOperations.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/24/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "MathOperations.h"

@implementation MathOperations

//Returns point with x and y relative to center of a circle, starting at top
+(PointObject*) getPointFromCircleRadius:(float)radius andCurrentPointIndex:(NSInteger)index withTotalPoints:(NSUInteger)total {

	float theta = ((M_PI*2.f) / (float)total);
	float angle = (theta * index) - (M_PI/2.f);

	PointObject* point = [[PointObject alloc] init];

	point.x = (radius * cos(angle));
	point.y = (radius * sin(angle));

	return point;
}

+ (BOOL) point:(CGPoint)point onCircleWithRadius:(float)radius andOrigin:(CGPoint)origin withThreshold:(float)threshold{
	//location needs to be relative to origin
	point.x = point.x - origin.x;
	point.y = point.y - origin.y;

	float diff = sqrt(fabs(pow(point.x, 2) + pow(point.y, 2) - pow(radius, 2)))/2.f;

	if (diff < threshold) {
		return YES;
	}
	return NO;
}

+ (float) distanceBetweenTwoPoints:(CGPoint)pointOne and:(CGPoint)pointTwo {
	return sqrt(fabs(pointOne.x - pointTwo.x) + fabs(pointOne.y - pointTwo.y));
}

// in radians from top of circle (so 90 degrees)
+ (float) calculateAngleClockwiseBetweenTwoPoints:(CGPoint)pointOne and:(CGPoint)pointTwo onCircleWithOrigin: (CGPoint) origin {

	float angleOne = (M_PI/2.f) + atan2f((pointOne.y - origin.y),(pointOne.x - origin.x));
	float angleTwo = (M_PI/2.f) + atan2f((pointTwo.y - origin.y),(pointTwo.x - origin.x));

	NSLog(@"Angle One: %f and Angle Two: %f", angleOne, angleTwo);
	float angle = (angleTwo - angleOne);
	if (angle < 0) {
		angle = angle + (2*M_PI);
	}

	NSLog(@"Angle: %f", angle);

	float angleDeg = angle * (180/M_PI);
	NSLog(@"Degrees between points: %f", angleDeg);
	return angle;
}

+ (float) distanceClockwiseBetweenTwoPoints:(CGPoint)pointOne and:(CGPoint)pointTwo onCircleWithRadius:(float) radius andOrigin: (CGPoint) origin{

	float angle = [self calculateAngleClockwiseBetweenTwoPoints:pointOne and:pointTwo onCircleWithOrigin:origin];
	float fractionOfCircle = angle / (2*M_PI);
	NSLog(@"Fraction of circle: %f", fractionOfCircle);
	return fractionOfCircle * 2* M_PI *radius;
}

@end
