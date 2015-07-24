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

+ (float) distanceBetweenTwoPoints:(CGPoint)pointOne and:(CGPoint)pointTwo onCircleWithRadius:(float) radius andOrigin:(CGPoint)origin {
	pointOne.x = pointOne.x -origin.x;
	pointOne.y = pointOne.y -origin.y;
	pointTwo.x = pointTwo.x -origin.x;
	pointTwo.y = pointTwo.y -origin.y;

	float fractionOfCircle = fabs(atanf(pointOne.y/pointOne.x) - atanf(pointTwo.y/pointTwo.x));
	return fractionOfCircle * 2* M_PI *radius;
}

@end
