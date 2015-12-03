//
//  LocalPOVs.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/2/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "LocalPOVs.h"
#import "POV.h"

@interface LocalPOVs()

@end

@implementation LocalPOVs

+ (LocalPOVs*) sharedInstance {
	static LocalPOVs *_sharedInstance = nil;
	static dispatch_once_t onceSecurePredicate;
	dispatch_once(&onceSecurePredicate,^{
		_sharedInstance = [[LocalPOVs alloc] init];
	});

	return _sharedInstance;
}

- (void) storePOVWithThread: (NSString*) thread andPinchViews: (NSMutableArray*) pinchViews {
	NSString* threadKey = [self getKeyFromThreadName: thread];
	NSArray* threadPOVs = [[NSUserDefaults standardUserDefaults] objectForKey:threadKey];
	NSMutableArray* mutablePOVs = [[NSMutableArray alloc] init];
	if (threadPOVs) {
		mutablePOVs = [[NSMutableArray alloc] initWithArray:threadPOVs];
	}
	[mutablePOVs addObject: [[POV alloc] initWithThread:thread andPinchViews:pinchViews]];
	[[NSUserDefaults standardUserDefaults] setObject:mutablePOVs forKey:threadKey];
}

-(NSArray*) getPOVsFromThread: (NSString*) thread {
	NSString* threadKey = [self getKeyFromThreadName: thread];
	return [[NSUserDefaults standardUserDefaults] objectForKey:threadKey];
}

-(NSString*) getKeyFromThreadName: (NSString*) threadName {
	return [threadName stringByAppendingString:@"_thread_key"];
}

@end
