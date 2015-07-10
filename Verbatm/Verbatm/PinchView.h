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

@interface PinchView : UIView <NSCoding>

-(void)onScreen;
-(void)offScreen;

/*
 allows you to change the width and height of the object without changing it's center
 note that the object frame is a square so width == height
 */
-(void) changeWidthTo: (double) width;


/*This adds a picture to the pinch object
 *The method return nothing.
 */
-(void)changePicture:(UIImage*)image;

/*This adds text to the pinch object
 *The method return nothing.
 */

-(void) changeText:(UITextView *) textview;
/*
 *This sets the frame of the pinch object
 *
 */
-(void)specifyFrame:(CGRect)frame;

//funcitons allow you to mute and unmute the video on the pinch object- not if there is no video the
//result is undefined
-(void)unmuteVideo;
-(void)muteVideo;

//lets you specify a center and in turn sets the frame of the pinchview
//should only be use when panning the object because it relies on the current from of the object which must be set before this is called
-(void)specifyCenter:(CGPoint) center;


/*This creates a new pinch object with a particular radius, superview and a center
 *as specified by the passed parameters
 */
-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andMedia:(NSMutableArray*)mediaArray;

//This merges several pinch objects in the to_be_merged array into a singe verbatmCustomPinchView
//null is returned if the array has fewer than 2 objects. The array, along with references to the pinch objects
//is destroyed to avoid memory leaks.
+(PinchView*)pinchTogether:(NSMutableArray*)toBeMerged;

//Pinches apart two media that were previously pinched together.
//The function returns null if the object to be pinched apart does not actually consist
//of more than one media object.
//The array returned consist of two verbatmCustomPinchViews.
+(NSMutableArray*)pinchApart:(PinchView*)collection;


//this function pulls a pinch object apart into the componenent media.
//It returns an array of pinch objects
+(NSMutableArray*)openCollection:(PinchView*)collection;

//creates an identical PV to the one handed to it
+(PinchView *)pinchObjectFromPinchObject: (PinchView *) pv;

//restarts the video playing
//Should only be called if the player layer of the video has been removed (perhaps due to a preview)
//and we want to restart the video 
//-(void) restartVideo;

//Tells whether it is a collection consisting of more than one type of media
-(BOOL)isCollection;

//tells you if the pinch object has multiple media objects in its array.
//This applies, whether it is a collection or not.
-(BOOL)hasMultipleMedia;

//Pauses the video if the pinch object has a video playing.
-(void)pauseVideo;


//restarts a paused video, continuing from where it was paused
-(void)continueVideo;


//marks the video as selected
-(void)markAsSelected;

//mark as unselected
-(void)unmarkAsSelected;

//add red ring to show it's about to be deleted
-(void)markAsDeleting;

//get rid of red ring when it's not being deleted
-(void)unmarkAsDeleting;

//for intructing to render media
-(void)renderMedia;

//creates a shadow around the pinch object
-(void)createLensingEffect:(float)radius;

//zeros out the border for the pinch view
-(void)removeBorder;

@property (nonatomic) BOOL selected;//tells you if the object is selected for panning
@property (readonly,nonatomic) BOOL there_is_text;
@property (readonly, nonatomic) BOOL there_is_video;
@property (readonly, nonatomic) BOOL there_is_picture;
@property (nonatomic) BOOL inDataFormat;

/*Getting media from the pinch object*/
-(NSMutableArray*)getVideos;
-(NSMutableArray*)getPhotos;

//returns all the strings of the media in the media array which are textfields.
-(NSString*)getTextFromPinchObject;


//returns all the verbatmCustomImageViews that make up the media of the pinch
//object.
-(NSMutableArray*)mediaObjects;

@property (weak, nonatomic) IBOutlet UIView *videoView;
@end
