//
//  UserPinchViews.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "UserPovInProgress.h"

@interface UserPovInProgress()

//array of NSData convertible to PinchView
@property (strong, nonatomic) NSMutableArray* pinchViewsAsData;
@property (strong, nonatomic) NSData* coverPhotoData;

#define TITLE_KEY @"user_title"
#define COVER_PHOTO_KEY @"user_cover_photo"
#define PINCHVIEWS_KEY @"user_pinch_views"
#define CONVERTING_PINCHVIEW_DISPATCH_KEY "converting_pinchviews"

@end

@implementation UserPovInProgress

- (id) init {
	self = [super init];
	if (self) {
	}
	return self;
}

+ (UserPovInProgress *)sharedInstance {
	static UserPovInProgress *_sharedInstance = nil;
	static dispatch_once_t onceSecurePredicate;
	dispatch_once(&onceSecurePredicate,^{
		_sharedInstance = [[self alloc] init];
	});

	return _sharedInstance;
}

-(void) addTitle: (NSString*) title {
	self.title = title;
	[[NSUserDefaults standardUserDefaults]
	setObject:self.title forKey:TITLE_KEY];
}

-(void) addCoverPhoto: (UIImage*) coverPicture {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		@synchronized(self) {
			self.coverPhoto = coverPicture;
			self.coverPhotoData = UIImagePNGRepresentation(coverPicture);
		}
		[[NSUserDefaults standardUserDefaults]
		 setObject:self.coverPhotoData forKey:COVER_PHOTO_KEY];
	});
}

//adds pinch view and automatically saves pinchViews
-(void) addPinchView:(PinchView*)pinchView {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		@synchronized(self) {
			if ([self.pinchViews containsObject:pinchView]) {
				return;
			}
			[self.pinchViews addObject:pinchView];
			NSData* pinchViewData = [self convertPinchViewToNSData:pinchView];
			[self.pinchViewsAsData addObject:pinchViewData];
		}
		[[NSUserDefaults standardUserDefaults]
		 setObject:self.pinchViewsAsData forKey:PINCHVIEWS_KEY];
	});
}

//removes pinch view and automatically saves pinchViews
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

-(void) swapPinchView: (PinchView *) pinchView1 andPinchView: (PinchView *) pinchView2 {
	@synchronized(self) {
		NSInteger index1 = [self.pinchViews indexOfObject: pinchView1];
		NSInteger index2 = [self.pinchViews indexOfObject: pinchView2];
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
-(void) loadPOVFromUserDefaults {
	//clears user defaults
//	[self clearPOVInProgress];

	self.title = [[NSUserDefaults standardUserDefaults]
				  objectForKey:TITLE_KEY];
	NSData* coverPhotoData = [[NSUserDefaults standardUserDefaults] objectForKey:COVER_PHOTO_KEY];
	self.pinchViewsAsData = [[NSUserDefaults standardUserDefaults]
							 objectForKey:PINCHVIEWS_KEY];

	@synchronized(self) {
		if (coverPhotoData) {
			self.coverPhoto = [UIImage imageWithData:coverPhotoData];
		}
		for (NSData* data in self.pinchViewsAsData) {
			PinchView* pinchView = [self convertNSDataToPinchView:data];
			[self.pinchViews addObject:pinchView];
		}
		self.pinchViewsAsData = [[NSMutableArray alloc] initWithArray:self.pinchViewsAsData copyItems:NO];
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
