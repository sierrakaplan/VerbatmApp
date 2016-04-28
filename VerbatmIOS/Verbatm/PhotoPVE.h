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

@protocol PhotoPVEDelegate <NSObject>

@end

@protocol PhotoPVETextEntryDelegate <NSObject>

-(void) editContentViewTextIsEditing;
-(void) editContentViewTextDoneEditing;

@end

@interface PhotoPVE : PageViewingExperience

@property (weak, nonatomic) id<PhotoPVEDelegate> delegate;

@property (weak, nonatomic) id<PhotoPVETextEntryDelegate> textEntryDelegate;

@property (weak, nonatomic) UIScrollView * postScrollView;

//Photos is array of UIImage
-(instancetype) initWithFrame:(CGRect)frame andPhotoArray:(NSArray *)photos
						small:(BOOL) small isPhotoVideoSubview:(BOOL)halfScreen;

// initializer for preview mode
// PinchView can be either ImagePinchView or CollectionPinchView
-(instancetype) initWithFrame:(CGRect)frame andPinchView:(PinchView *)pinchView
				inPreviewMode: (BOOL)inPreviewMode isPhotoVideoSubview:(BOOL)halfScreen;

@end
