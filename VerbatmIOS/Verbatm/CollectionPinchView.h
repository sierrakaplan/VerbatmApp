//
//  CollectionPinchView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "PinchView.h"
#import "VideoPinchView.h"

@interface CollectionPinchView : PinchView

// pinched objects in the collection view
@property (strong, nonatomic) NSMutableArray* imagePinchViews;
@property (strong, nonatomic) NSMutableArray* videoPinchViews;
@property (strong, nonatomic) AVAsset *videoAsset; //stores fused asset of videoPinchViews

// keeps track of order of elements pinched together
@property (strong, nonatomic, readonly) NSMutableArray* pinchedObjects;

//Takes an array of SingleMediaAndTextPinchViews which are being pinched together
-(instancetype)initWithRadius:(CGFloat)radius withCenter:(CGPoint)center andPinchViews:(NSArray*)pinchViews;

-(NSInteger) getNumPinchViews;

//Pinches the given pinch view onto the collection
//returns self for chaining purposes
-(CollectionPinchView*) pinchAndAdd:(SingleMediaAndTextPinchView*)pinchView;

//Unpinches the given pinch view from the collection
//returns self for chaining purposes
-(CollectionPinchView*) unPinchAndRemove:(SingleMediaAndTextPinchView*)pinchView;
-(void)publishingPinchView;
@end
