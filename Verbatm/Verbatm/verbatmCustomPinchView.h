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

@interface verbatmCustomPinchView : UIView

/*This adds a text to the media of the pinch object
 *The method return nothing. 
 */
-(void)addTextToCurrentMedia:(UITextView*)textview;

/*This adds a video object to the pinch object
 *The method return nothing.
 */
-(void)addVideoToCurrentMedia:(MPMoviePlayerController *)video;

/*This adds a picture to the pinch object
 *The method return nothing.
 */
-(void)addPictureToCurrentMedia:(UIImageView*)imageview;

/*
 *This sets the frame of the pinch object
 *
 */
-(void)specifyFrame:(CGRect)frame;

/*This creates a new pinch object with a particular radius, superview and a center
 *as specified by the passed parameters
 */
-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andMedia:(id)medium;

//This merges several pinch objects in the to_be_merged array into a singe verbatmCustomPinchView
//null is returned if the array has fewer than 2 objects. The array, along with references to the pinch objects
//is destroyed to avoid memory leaks.
+(verbatmCustomPinchView*)pinchTogether:(NSMutableArray*)to_be_merged;

//Pinches apart two media that were previously pinched together.
//The function returns null if the object to be pinched apart does not actually consist
//of more than one media object.
//The array returned consist of two verbatmCustomPinchViews.
+(NSMutableArray*)pinchApart:(verbatmCustomPinchView*)to_be_pinched_apart;


//this function pulls a pinch object apart into the componenent media.
//It returns an array of pinch objects
+(NSMutableArray*)openCollection:(verbatmCustomPinchView*)to_be_seperated;


//returns all the strings of the media in the media array which are textfields.
-(NSString*)getTextFromPinchObject;

//Tells whether it is a collection consisting of more than one type of media
-(BOOL)isCollection;

//tells you if the pinch object has multiple media objects in its array.
//This applies, whether it is a collection or not.
-(BOOL)hasMultipleMedia;

//returns all the verbatmCustomImageViews that make up the media of the pinch
//object.
-(NSMutableArray*)mediaObjects;



@property (readonly,nonatomic) BOOL there_is_text;
@property (readonly, nonatomic) BOOL there_is_video;
@property (readonly, nonatomic) BOOL there_is_picture;
@end
