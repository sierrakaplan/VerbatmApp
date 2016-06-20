//
//  UserPinchViews.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
// Saves User pinch views for when app crashes or if they turn off phone

#import <Foundation/Foundation.h>

@class PinchView;

@interface PostInProgress : NSObject

+ (PostInProgress *) sharedInstance;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSMutableArray *pinchViews;

-(void) addTitle: (NSString*) title;

//adds pinch view and automatically saves pinchViews
-(void) addPinchView:(PinchView*) pinchView atIndex:(NSInteger) index;

//deletes the pv element and replaces it with the newPv
-(void) removePinchViewAtIndex:(NSInteger)index andReplaceWithPinchView:(PinchView *)newPinchView;

//removes pinch view and automatically saves pinchViews
-(void) removePinchViewAtIndex: (NSInteger) index;

//swaps the position of the two pinch views in order to maintain user ordering
-(void) swapPinchViewsAtIndex:(NSInteger)index1 andIndex:(NSInteger)index2;

//loads pinchviews from user defaults
-(void) loadPostFromUserDefaults;

//removes title, cover picture, and pinch views
-(void) clearPostInProgress;


@end
