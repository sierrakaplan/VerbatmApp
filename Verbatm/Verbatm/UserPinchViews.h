//
//  UserPinchViews.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
// Saves User pinch views for when app crashes or if they turn off phone

#import <Foundation/Foundation.h>

@class PinchView;

@interface UserPinchViews : NSObject

+ (UserPinchViews *)sharedInstance;

@property (strong, nonatomic) NSMutableArray* pinchViews;

//adds pinch view and automatically saves pinchViews
-(void) addPinchView:(PinchView*)pinchView;

//removes pinch view and automatically saves pinchViews
-(void) removePinchView:(PinchView*)pinchView;

//loads pinchviews from user defaults
-(void) loadPinchViewsFromUserDefaults;

//removes all pinch views
-(void) clearPinchViews;


@end
