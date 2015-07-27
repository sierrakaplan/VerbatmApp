//
//  verbatmCustomPinchView.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 11/15/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@class CollectionPinchView;

@interface PinchView : UIView <NSCoding>

@property(strong,nonatomic) UIView* background;
//tells you if the object is selected for panning
@property (nonatomic) BOOL selected;

@property (nonatomic) BOOL containsText;
@property (nonatomic) BOOL containsImage;
@property (nonatomic) BOOL containsVideo;

//This creates a new pinch object with a particular radius and a center
-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center;

/*
 allows you to change the width and height of the object without changing it's center
 note that the object frame is a square so width == height
 */
-(void) changeWidthTo: (double) width;

/*
 *This sets the frame of the pinch object
*/
-(void)specifyFrame:(CGRect)frame;

-(NSInteger) numTypesOfMedia;

//This merges two verbatm pinch objects into one.
// Unless they are both text, the result will be a collection
+(PinchView*) pinchTogether:(NSArray*) pinchViews;

//for intructing to render media
-(void)renderMedia;

//zeros out the border for the pinch view
-(void)removeBorder;


#pragma mark Should be overriden in subclasses
-(NSString*) getText;
-(NSArray*) getPhotos;
-(NSArray*) getVideos;

-(void)onScreen;
-(void)offScreen;


@end
