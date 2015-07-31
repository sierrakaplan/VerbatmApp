//
//  UserPinchViews.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "UserPinchViews.h"

@interface UserPinchViews()

//array of NSData convertible to PinchView
@property (strong, nonatomic) NSMutableArray* pinchViewsAsData;

#define PINCHVIEWS_KEY @"user_pinch_views"
#define CONVERTING_PINCHVIEW_DISPATCH_KEY "converting_pinchviews"

@end

@implementation UserPinchViews

- (id) init {
	self = [super init];
	if (self) {
	}
	return self;
}

+ (UserPinchViews *)sharedInstance {
	static UserPinchViews *_sharedInstance = nil;
	static dispatch_once_t onceSecurePredicate;
	dispatch_once(&onceSecurePredicate,^
				  {
					  _sharedInstance = [[self alloc] init];
				  });

	return _sharedInstance;
}

//lazy instantiation
-(NSMutableArray*) pinchViews {
	if(!_pinchViews) _pinchViews = [[NSMutableArray alloc] init];
	return _pinchViews;
}

//lazy instantiation
-(NSMutableArray*) pinchViewsAsData {
	if(!_pinchViewsAsData) _pinchViewsAsData = [[NSMutableArray alloc] init];
	return _pinchViewsAsData;
}

-(NSData*) convertPinchViewToNSData:(PinchView*)pinchView {
	return [NSKeyedArchiver archivedDataWithRootObject:pinchView];
}

-(PinchView*) convertNSDataToPinchView:(NSData*)data {
	return (PinchView*)[NSKeyedUnarchiver unarchiveObjectWithData: data];
}

//adds pinch view and automatically saves pinchViews
-(void) addPinchView:(PinchView*)pinchView {
	dispatch_queue_t convertPinchViewQueue = dispatch_queue_create(CONVERTING_PINCHVIEW_DISPATCH_KEY, NULL);
	dispatch_async(convertPinchViewQueue, ^{
		NSData* pinchViewData = [self convertPinchViewToNSData:pinchView];

		//thread safety
		@synchronized(self) {

			if (![self.pinchViewsAsData containsObject:pinchViewData]) {
				[self.pinchViewsAsData addObject:pinchViewData];

				[[NSUserDefaults standardUserDefaults]
				 setObject:self.pinchViewsAsData forKey:PINCHVIEWS_KEY];
			}
			
		}
	});
}

//removes pinch view and automatically saves pinchViews
-(void) removePinchView:(PinchView*)pinchView {
	dispatch_queue_t convertPinchViewQueue = dispatch_queue_create(CONVERTING_PINCHVIEW_DISPATCH_KEY, NULL);
	dispatch_async(convertPinchViewQueue, ^{
		NSData* pinchViewData = [self convertPinchViewToNSData:pinchView];

		//thread safety
		@synchronized(self) {

			if ([self.pinchViewsAsData containsObject:pinchViewData]) {
				[self.pinchViewsAsData removeObject:pinchViewData];

				[[NSUserDefaults standardUserDefaults]
				 setObject:self.pinchViewsAsData forKey:PINCHVIEWS_KEY];
			}
			
		}
	});
}

//loads pinchviews from user defaults
-(void) loadPinchViewsFromUserDefaults {
//	[[NSUserDefaults standardUserDefaults] removeObjectForKey:PINCHVIEWS_KEY];
	self.pinchViewsAsData = [[NSUserDefaults standardUserDefaults]
					   objectForKey:PINCHVIEWS_KEY];
	for (NSData* data in self.pinchViewsAsData) {
		PinchView* pinchView = [self convertNSDataToPinchView:data];
		[self.pinchViews addObject:pinchView];
	}
	NSMutableArray* mutablePinchViews = [[NSMutableArray alloc] initWithArray:self.pinchViewsAsData copyItems:YES];
	self.pinchViewsAsData = mutablePinchViews;
}

//removes all pinch views
-(void) clearPinchViews {
	//thread safety
	@synchronized(self) {
		[self.pinchViewsAsData removeAllObjects];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:PINCHVIEWS_KEY];
	}
}

@end
