//
//  NoAnimationSegue.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/15/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "NoAnimationUnwindSegue.h"

@implementation NoAnimationUnwindSegue

-(void) perform{
	[[[self sourceViewController] navigationController] popToViewController:[self destinationViewController] animated:NO];
}

@end
