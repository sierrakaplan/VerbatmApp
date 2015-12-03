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
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		@synchronized(self) {
			NSString* threadKey = [self getKeyFromThreadName: thread];
			NSArray* threadPOVs = [[NSUserDefaults standardUserDefaults] objectForKey:threadKey];
			NSMutableArray* mutablePOVs = [[NSMutableArray alloc] init];
			if (threadPOVs) {
				mutablePOVs = [[NSMutableArray alloc] initWithArray:threadPOVs];
			}
			POV* pov = [[POV alloc] initWithThread:thread andPinchViews:pinchViews];
			[mutablePOVs addObject: [self convertPOVToNSData:pov]];
			[[NSUserDefaults standardUserDefaults] setObject:mutablePOVs forKey:threadKey];
		}
	});
}

-(NSArray*) getPOVsFromThread: (NSString*) thread {
	NSString* threadKey = [self getKeyFromThreadName: thread];
	NSArray* povsAsData = [[NSUserDefaults standardUserDefaults] objectForKey:threadKey];
	NSMutableArray* povs = [[NSMutableArray alloc] init];
	for (NSData* data in povsAsData) {
		POV* pov = [self convertNSDataToPOV:data];
		[povs addObject: pov];
	}
	return povs;
}

-(NSString*) getKeyFromThreadName: (NSString*) threadName {
	return [threadName stringByAppendingString:@"_thread_key"];
}

-(NSData*) convertPOVToNSData: (POV*) pov {
	return [NSKeyedArchiver archivedDataWithRootObject:pov];
}

-(POV*) convertNSDataToPOV: (NSData*) data {
	return (POV*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end
