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

// stores NSString thread as key to an array of povs
@property(strong, nonatomic) NSMutableDictionary* povThreads;

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
		POV* pov = [[POV alloc] initWithThread:thread andPinchViews:pinchViews
								andCreatorName:@"Humans of New York"
						   andCreatorImageName:@"hony_profile_image"
								andChannelName:@"Immigrant Stories"];
		@synchronized(self) {
			NSString* threadKey = [self getKeyFromThreadName: thread];
			NSMutableArray* povs = [[NSMutableArray alloc] init];
			if ([self.povThreads objectForKey:threadKey]) {
				NSArray* povArray = [self.povThreads objectForKey:threadKey];
				povs = [NSMutableArray arrayWithArray:povArray];
			}
			if (index >= 0 && index < povs.count) {
				[povs insertObject:pov atIndex:index];
			} else {
				[povs addObject: pov];
			}
			self.povThreads[threadKey] = povs;

			NSArray* threadPOVs = [[NSUserDefaults standardUserDefaults] objectForKey:threadKey];
			NSMutableArray* mutablePOVs = [[NSMutableArray alloc] init];
			if (threadPOVs) {
				mutablePOVs = [[NSMutableArray alloc] initWithArray:threadPOVs];
			}

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
	if ([self.povThreads objectForKey:threadKey]) {
		return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
			resolve([self.povThreads objectForKey:threadKey]);
		}];
	}
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
	return PMKWhen(povPromises).then(^(NSMutableArray* povs) {
		self.povThreads[threadKey] = povs;
		return povs;
	}).catch(^(NSError* error) {
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

#pragma mark - Lazy Instantiation -

-(NSMutableDictionary*) povThreads {
	if (!_povThreads) {
		_povThreads = [[NSMutableDictionary alloc] init];
	}
	return _povThreads;
}

@end
