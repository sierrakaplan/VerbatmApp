//
//  NoAnimationSegue.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/15/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "NoAnimationSegue.h"

@implementation NoAnimationSegue

-(void) perform{
	[[[self sourceViewController] navigationController] pushViewController:[self destinationViewController] animated:NO];
}

@end
