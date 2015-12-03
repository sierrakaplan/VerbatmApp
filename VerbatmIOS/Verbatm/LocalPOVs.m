//
//  LocalPOVs.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/2/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "LocalPOVs.h"
#import "CollectionPinchView.h"
#import "VideoPinchView.h"
#import "PinchView.h"
#import "POV.h"

@interface LocalPOVs()

@end

@implementation LocalPOVs

-(instancetype) init {
	if (self = [super init]) {
		// Clears all user defaults
//		[[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
//		[self clearPOVsForThread:@"feed"];
	}
	return self;
}

+ (LocalPOVs*) sharedInstance {
	static LocalPOVs *_sharedInstance = nil;
	static dispatch_once_t onceSecurePredicate;
	dispatch_once(&onceSecurePredicate,^{
		_sharedInstance = [[LocalPOVs alloc] init];
	});

	return _sharedInstance;
}

- (void) storePOVWithThread: (NSString*) thread andPinchViews: (NSMutableArray*) pinchViews atIndex: (NSInteger) index {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		@synchronized(self) {
			NSString* threadKey = [self getKeyFromThreadName: thread];
			NSArray* threadPOVs = [[NSUserDefaults standardUserDefaults] objectForKey:threadKey];
			NSMutableArray* mutablePOVs = [[NSMutableArray alloc] init];
			if (threadPOVs) {
				mutablePOVs = [[NSMutableArray alloc] initWithArray:threadPOVs];
			}
			POV* pov = [[POV alloc] initWithThread:thread andPinchViews:pinchViews];
			NSData* povData = [self convertPOVToNSData:pov];
			if (index >= 0 && index < mutablePOVs.count) {
				[mutablePOVs insertObject:povData atIndex:index];
			} else {
				[mutablePOVs addObject: povData];
			}
			[[NSUserDefaults standardUserDefaults] setObject:mutablePOVs forKey:threadKey];
		}
	});
}

-(AnyPromise*) getPOVsFromThread: (NSString*) thread {
	NSString* threadKey = [self getKeyFromThreadName: thread];
	NSArray* povsAsData = [[NSUserDefaults standardUserDefaults] objectForKey:threadKey];
	NSMutableArray* povPromises = [[NSMutableArray alloc] init];
	for (NSData* data in povsAsData) {
		AnyPromise* povPromise = [self convertNSDataToPOV:data].then(^(POV* pov) {
			NSMutableArray* videoPinchViewPromises = [[NSMutableArray alloc] init];
			for (PinchView* pinchView in pov.pinchViews) {
				if ([pinchView isKindOfClass:[CollectionPinchView class]]) {
					for (VideoPinchView* videoPinchView in ((CollectionPinchView*)pinchView).videoPinchViews) {
						[videoPinchViewPromises addObject:[videoPinchView loadAVURLAssetFromPHAsset]];
					}
				} else if ([pinchView isKindOfClass:[VideoPinchView class]]) {
					[videoPinchViewPromises addObject:[(VideoPinchView*)pinchView loadAVURLAssetFromPHAsset]];
				}
			}
			return PMKWhen(videoPinchViewPromises).then(^(NSArray* videoAssets) {
				return pov;
			});
		});
		[povPromises addObject: povPromise];
	}
	return PMKWhen(povPromises).catch(^(NSError* error) {
		NSLog(@"Error loading local POVs: %@", error.description);
	});
}

-(NSString*) getKeyFromThreadName: (NSString*) threadName {
	return [threadName stringByAppendingString:@"_thread_key"];
}

-(NSData*) convertPOVToNSData: (POV*) pov {
	return [NSKeyedArchiver archivedDataWithRootObject:pov];
}

-(void) clearPOVsForThread: (NSString*) thread {
	NSString* threadKey = [self getKeyFromThreadName: thread];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:threadKey];
}

-(AnyPromise*) convertNSDataToPOV: (NSData*) data {
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
		resolve((POV*)[NSKeyedUnarchiver unarchiveObjectWithData:data]);
	}];
	return promise;
}

@end
