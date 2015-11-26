//
//  UserPinchViews.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
// Saves User pinch views for when app crashes or if they turn off phone

#import <Foundation/Foundation.h>

@class CoverPicturePinchView;
@class PinchView;

@interface UserPovInProgress : NSObject

+ (UserPovInProgress *)sharedInstance;

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) UIImage* coverPhoto;
@property (strong, nonatomic) NSMutableArray* pinchViews;

-(void) addTitle: (NSString*) title;

-(void) addCoverPhoto: (UIImage*) coverPicture;

//adds pinch view and automatically saves pinchViews
-(void) addPinchView:(PinchView*)pinchView atIndex:(NSInteger) index;

//deletes the pv element and replaces it with the newPv
-(void) removePinchView:(PinchView *) pv andReplaceWithPinchView:(PinchView *) newPv;

//removes pinch view and automatically saves pinchViews
-(void) removePinchView:(PinchView*)pinchView;

//swaps the position of the two pinch views in order to maintain user ordering
-(void) swapPinchView: (PinchView *) pinchView1 andPinchView: (PinchView *) pinchView2;

// once a pinch view has changed, updates it in the user defaults
-(void) updatePinchView: (PinchView*) pinchView;

//loads pinchviews from user defaults
-(void) loadPOVFromUserDefaults;

//removes title, cover picture, and pinch views
-(void) clearPOVInProgress;


@end
