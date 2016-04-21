//
//  UserPinchViews.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "PinchView.h"
#import "PostInProgress.h"
#import "VideoPinchView.h"

@interface PostInProgress()

//array of NSData convertible to PinchView
@property (strong, nonatomic) NSMutableArray* pinchViewsAsData;

#define TITLE_KEY @"user_title"
#define COVER_PHOTO_KEY @"user_cover_photo"
#define PINCHVIEWS_KEY @"user_pinch_views"

@end

@implementation PostInProgress

+ (PostInProgress *)sharedInstance {
	static PostInProgress *_sharedInstance = nil;
	static dispatch_once_t onceSecurePredicate;
	dispatch_once(&onceSecurePredicate,^{
		_sharedInstance = [[PostInProgress alloc] init];
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
            if(index <= self.pinchViews.count && index >= 0) {
                NSData* pinchViewData = [self convertPinchViewToNSData:pinchView];
                [self.pinchViewsAsData insertObject:pinchViewData atIndex:index];
				
                //call on main queu because we are creating and formating uiview
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Insert copy of pinch view not pinch view itself
                    [self.pinchViews insertObject:[self convertNSDataToPinchView:pinchViewData] atIndex:index];
                });
				
            }
		}
		[[NSUserDefaults standardUserDefaults]
		 setObject:self.pinchViewsAsData forKey:PINCHVIEWS_KEY];
	});
}

//removes pinch view and saves pinchViews
-(void) removePinchViewAtIndex: (NSInteger) index {
	@synchronized(self) {
		[self.pinchViews removeObjectAtIndex:index];
		[self.pinchViewsAsData removeObjectAtIndex:index];
	}
	[[NSUserDefaults standardUserDefaults]
	 setObject:self.pinchViewsAsData forKey:PINCHVIEWS_KEY];
}

-(void) removePinchViewAtIndex:(NSInteger)index andReplaceWithPinchView:(PinchView *)newPinchView {
	if (!newPinchView) return; //todo: make sure this never happens
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		@synchronized(self) {
			if(index <= self.pinchViews.count && index >= 0) {
				NSData* pinchViewData = [self convertPinchViewToNSData: newPinchView];
				[self.pinchViews replaceObjectAtIndex:index withObject: newPinchView];
				[self.pinchViewsAsData replaceObjectAtIndex:index withObject: pinchViewData];
			}
		}
		[[NSUserDefaults standardUserDefaults]
		 setObject:self.pinchViewsAsData forKey:PINCHVIEWS_KEY];
	});
}

-(void) swapPinchViewsAtIndex:(NSInteger)index1 andIndex:(NSInteger)index2 {
	@synchronized(self) {
		PinchView *pinchView1 = self.pinchViews[index1];
		PinchView *pinchView2 = self.pinchViews[index2];
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

//loads pinchviews from user defaults
-(void) loadPostFromUserDefaults {
    self.title = [[NSUserDefaults standardUserDefaults]
				  objectForKey:TITLE_KEY];
	NSArray* pinchViewsData = [[NSUserDefaults standardUserDefaults]
							 objectForKey:PINCHVIEWS_KEY];
	@synchronized(self) {
		self.pinchViewsAsData = [[NSMutableArray alloc] initWithArray:pinchViewsData copyItems:NO];
		for (int i = 0; i < pinchViewsData.count; i++) {
			NSData* data = pinchViewsData[i];
			PinchView* pinchView = [self convertNSDataToPinchView:data];
			if ([pinchView isKindOfClass:[VideoPinchView class]]) {
				[(VideoPinchView*)pinchView loadAVURLAssetFromPHAsset].then(^(AVURLAsset* video) {
					[self.pinchViews insertObject:pinchView atIndex:i];
				});
			} else {
				[self.pinchViews addObject:pinchView];
			}
		}
	}
}

//removes all pinch views
-(void) clearPostInProgress {
	//thread safety
	@synchronized(self) {
		[self.pinchViews removeAllObjects];
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
