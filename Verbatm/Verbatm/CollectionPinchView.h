//
//  CollectionPinchView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "PinchView.h"
#import "VideoPlayerView.h"
#import "VideoPinchView.h"

@interface CollectionPinchView : PinchView

//array of PinchViews
@property (strong, nonatomic) NSMutableArray* pinchedObjects;

@property (nonatomic) VideoFormat videoFormat;
@property (strong, nonatomic) VideoPlayerView *videoView;

//inits with an array of pinchviews
-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andPinchViews:(NSArray*)pinchViews;

-(NSInteger) getNumPinchViews;

//Pinches the given pinch view onto the collection
//returns self for chaining purposes
-(CollectionPinchView*) pinchAndAdd:(PinchView*)pinchView;

//Unpinches the given pinch view from the collection
//returns self for chaining purposes
-(CollectionPinchView*) unPinchAndRemove:(PinchView*)pinchView;

//updates all the media stored in the collection view
-(void) updateMedia;

@end
