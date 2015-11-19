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

//array of PinchViews
@property (strong, nonatomic) NSMutableArray* pinchedObjects;

//inits with an array of pinchviews
-(instancetype)initWithRadius:(float)radius withCenter:(CGPoint)center andPinchViews:(NSArray*)pinchViews;

-(NSInteger) getNumPinchViews;

//Pinches the given pinch view onto the collection
//returns self for chaining purposes
-(CollectionPinchView*) pinchAndAdd:(PinchView*)pinchView;

//Unpinches the given pinch view from the collection
//returns self for chaining purposes
-(CollectionPinchView*) unPinchAndRemove:(PinchView*)pinchView;

//updates all the media stored in the collection view
-(void) updateMedia;


/*These functions are for when content is rearranged by the user */

//returns an array of all the video pinchviews in the order they will be presented
-(NSMutableArray *) getVideoPinchViews;
//adds the array of video content back into the list -- removing all the videos in the list that are not in this array
-(void)replaceVideoPinchViesWithNewVPVs : (NSMutableArray *) pinchViews;

//returns an array of all the image pinchviews in the order they were added
-(NSMutableArray *) getImagePinchViews;

//adds the array of image content back into the list -- removing all the images in the list that are not in this array
-(void)replaceImagePinchViesWithNewVPVs : (NSMutableArray *) pinchViews;
@end
