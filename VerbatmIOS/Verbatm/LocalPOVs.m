//
//  LocalPOVs.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/2/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "LocalPOVs.h"

@implementation LocalPOVs

+ (LocalPOVs*) sharedInstance {
	static LocalPOVs *_sharedInstance = nil;
	static dispatch_once_t onceSecurePredicate;
	dispatch_once(&onceSecurePredicate,^{
		_sharedInstance = [[LocalPOVs alloc] init];
	});

	return _sharedInstance;
}



@end
