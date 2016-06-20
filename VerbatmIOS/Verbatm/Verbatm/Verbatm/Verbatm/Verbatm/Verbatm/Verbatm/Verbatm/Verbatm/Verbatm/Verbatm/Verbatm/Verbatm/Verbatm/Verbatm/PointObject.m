//
//  CGPointWrapper.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "PointObject.h"

@implementation PointObject

-(CGPoint) getCGPoint {
	return CGPointMake(self.x, self.y);
}

@end

