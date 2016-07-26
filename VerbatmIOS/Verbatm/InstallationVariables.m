//
//  InstallationVariables.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "InstallationVariables.h"

@implementation InstallationVariables

+ (InstallationVariables *)sharedInstance {
	static dispatch_once_t onceToken;
	static InstallationVariables *instance = nil;
	dispatch_once(&onceToken, ^{
		instance = [[InstallationVariables alloc] init];
	});
	return instance;
}

@end
