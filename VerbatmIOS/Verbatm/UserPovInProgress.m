//
//  UserPinchViews.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "PinchView.h"
#import "UserPovInProgress.h"

@interface UserPovInProgress()

//array of NSData convertible to PinchView
@property (strong, nonatomic) NSMutableArray* pinchViewsAsData;

#define TITLE_KEY @"user_title"
#define COVER_PHOTO_KEY @"user_cover_photo"
#define PINCHVIEWS_KEY @"user_pinch_views"

@end

@implementation UserPovInProgress

+ (UserPovInProgress *)sharedInstance {
	static UserPovInProgress *_sharedInstance = nil;
	static dispatch_once_t onceSecurePredicate;
	dispatch_once(&onceSecurePredicate,^{
		_sharedInstance = [[UserPovInProgress alloc] init];
	});

	return _sharedInstance;
}

-(void) addTitle: (NSString*) title {
	self.title = title;
	[[NSUserDefaults standardUserDefaults] setObject:self.title forKey:TITLE_KEY];
}

//adds pinch view and automatically saves pinchViews
-(void) addPinchView:(PinchView*)pinchView atIndex:(NSInteger) index {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		@synchronized(self) {
			if ([self.pinchViews containsObject:pinchView] || !pinchView) {
				return;
			}
            
            if(index < self.pinchViews.count && index >= 0) {
                [self.pinchViews insertObject:pinchView atIndex:index];
                NSData* pinchViewData = [self convertPinchViewToNSData:pinchView];
                [self.pinchViewsAsData insertObject:pinchViewData atIndex:index];
            }
		}
        
		[[NSUserDefaults standardUserDefaults]
		 setObject:self.pinchViewsAsData forKey:PINCHVIEWS_KEY];
	});
}

//removes pinch view and saves pinchViews
-(void) removePinchView:(PinchView*)pinchView {
	@synchronized(self) {
		if (![self.pinchViews containsObject: pinchView]) {
			return;
		}
		NSInteger pinchViewIndex = [self.pinchViews indexOfObject:pinchView];
		[self.pinchViews removeObjectAtIndex:pinchViewIndex];
		[self.pinchViewsAsData removeObjectAtIndex:pinchViewIndex];
	}
	[[NSUserDefaults standardUserDefaults]
	 setObject:self.pinchViewsAsData forKey:PINCHVIEWS_KEY];
}

-(void) removePinchView:(PinchView *) pv andReplaceWithPinchView:(PinchView *) newPv{
    @synchronized(self) {
        if (![self.pinchViews containsObject: pv]) {
            return;
        }
        NSInteger pinchViewIndex = [self.pinchViews indexOfObject:pv];
        [self removePinchView:pv];
        [self addPinchView:newPv atIndex:pinchViewIndex];
    }
}

-(void) swapPinchView: (PinchView *) pinchView1 andPinchView: (PinchView *) pinchView2 {
	@synchronized(self) {
		NSInteger index1 = [self.pinchViews indexOfObject: pinchView1];
		NSInteger index2 = [self.pinchViews indexOfObject: pinchView2];
		if (index1 == NSNotFound || index2 == NSNotFound) return;
		[self.pinchViews replaceObjectAtIndex: index1 withObject: pinchView2];
		[self.pinchViews replaceObjectAtIndex: index2 withObject: pinchView1];

		// swap data
		NSData* pinchViewData1 = self.pinchViewsAsData[index1];
		NSData* pinchViewData2 = self.pinchViewsAsData[index2];
		[self.pinchViewsAsData replaceObjectAtIndex: index1 withObject: pinchViewData2];
		[self.pinchViewsAsData replaceObjectAtIndex: index2 withObject: pinchViewData1];
	}
	[[NSUserDefaults standardUserDefaults]
	 setObject:self.pinchViewsAsData forKey:PINCHVIEWS_KEY];
}

-(void) updatePinchView: (PinchView*) pinchView {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		@synchronized(self) {
			NSInteger index = [self.pinchViews indexOfObject:pinchView];
			if (index == NSNotFound) return;
			NSData* pinchViewData = [self convertPinchViewToNSData:pinchView];
			[self.pinchViewsAsData replaceObjectAtIndex:index withObject:pinchViewData];
		}
		[[NSUserDefaults standardUserDefaults]
		 setObject:self.pinchViewsAsData forKey:PINCHVIEWS_KEY];
	});
}

//loads pinchviews from user defaults
-(void) loadPOVFromUserDefaults {
	[self clearPOVInProgress];
	self.title = [[NSUserDefaults standardUserDefaults]
				  objectForKey:TITLE_KEY];
	NSArray* pinchViewsData = [[NSUserDefaults standardUserDefaults]
							 objectForKey:PINCHVIEWS_KEY];
	@synchronized(self) {
		for (NSData* data in pinchViewsData) {
			PinchView* pinchView = [self convertNSDataToPinchView:data];
			[self.pinchViews addObject:pinchView];
		}
		self.pinchViewsAsData = [[NSMutableArray alloc] initWithArray:pinchViewsData copyItems:NO];
	}
}

//removes all pinch views
-(void) clearPOVInProgress {
	//thread safety
	@synchronized(self) {
		[self.pinchViewsAsData removeAllObjects];
	}
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:TITLE_KEY];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:COVER_PHOTO_KEY];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:PINCHVIEWS_KEY];
}

#pragma mark - Converting pinch views to data and back -

-(NSData*) convertPinchViewToNSData:(PinchView*)pinchView {
	return [NSKeyedArchiver archivedDataWithRootObject:pinchView];
}

-(PinchView*) convertNSDataToPinchView:(NSData*)data {
	return (PinchView*)[NSKeyedUnarchiver unarchiveObjectWithData: data];
}

#pragma mark - Lazy Instantiation -

-(NSMutableArray*) pinchViews {
	if(!_pinchViews) _pinchViews = [[NSMutableArray alloc] init];
	return _pinchViews;
}

-(NSMutableArray*) pinchViewsAsData {
	if(!_pinchViewsAsData) _pinchViewsAsData = [[NSMutableArray alloc] init];
	return _pinchViewsAsData;
}

@end
