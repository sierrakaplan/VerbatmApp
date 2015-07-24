//
//  MathOperations.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/24/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "MathOperations.h"

@implementation MathOperations

//Returns point with x and y relative to center of a circle
+(PointObject*) getPointFromCircleRadius:(float)radius andCurrentPointIndex:(NSInteger)index withTotalPoints:(NSUInteger)total {

	float theta = ((M_PI*2.f) / (float)total);
	float angle = (theta * index);

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

// in radians
+ (float) calculateAngleClockwiseBetweenTwoPoints:(CGPoint)pointOne and:(CGPoint)pointTwo onCircleWithOrigin: (CGPoint) origin {

	float angleOne = atan2f((pointOne.y - origin.y),(pointOne.x - origin.x));
	float angleTwo = atan2f((pointTwo.y - origin.y),(pointTwo.x - origin.x));
	float angle = (2*M_PI) - (angleOne - angleTwo);

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
