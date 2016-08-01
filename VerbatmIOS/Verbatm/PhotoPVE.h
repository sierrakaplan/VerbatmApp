//
//  PhotoPVEDelegate.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//
//	Page View for photos

#import <UIKit/UIKit.h>
#import "PageViewingExperience.h"
#import "PinchView.h"

@protocol PhotoPVETextEntryDelegate <NSObject>

-(void) editContentViewTextIsEditing;
-(void) editContentViewTextDoneEditing;


-(void) repositioningPhotoPVE;
-(void) stopRepositioningPhotoPVE;

@end

@interface PhotoPVE : PageViewingExperience

@property (weak, nonatomic) id<PhotoPVETextEntryDelegate> textEntryDelegate;
@property (weak, nonatomic) UIScrollView * postScrollView;

// Will start loading icon until displayPhotos is called if halfScreen is false
-(instancetype) initWithFrame:(CGRect)frame small:(BOOL) small isPhotoVideoSubview:(BOOL)halfScreen;

//Photos is array of UIImage
-(void) displayPhotos:(NSArray*) photos;

// initializer for preview mode
// PinchView can be either ImagePinchView or CollectionPinchView
-(instancetype) initWithFrame:(CGRect)frame andPinchView:(PinchView *)pinchView
				inPreviewMode: (BOOL)inPreviewMode isPhotoVideoSubview:(BOOL)halfScreen;

@end
