//
//  PhotoAVE.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageViewingExperience.h"
#import "PinchView.h"

@protocol PhotoPVEDelegate <NSObject>

-(void) startedDraggingAroundCircle;
-(void) stoppedDraggingAroundCircle;

-(void) viewTapped;

@end

@protocol PhotoPVETextEntryDelegate <NSObject>

-(void) editContentViewTextIsEditing;
-(void) editContentViewTextDoneEditing;

@end

@interface PhotoPVE : PageViewingExperience

@property (strong, nonatomic) id<PhotoPVEDelegate> delegate;

@property (strong, nonatomic) id<PhotoPVETextEntryDelegate> textEntryDelegate;

@property (nonatomic) BOOL isPhotoVideoSubview;

//this is used with the tap gesture in the photovideoave -- we pass it in in order to prevent them from intercepting each other
@property (nonatomic, strong) UITapGestureRecognizer * photoAveTapGesture;

@property (weak, nonatomic) UIScrollView * postScrollView;

//Photos is array of UIImage
-(instancetype) initWithFrame:(CGRect)frame andPhotoArray: (NSArray *)photos;;

// initializer for preview mode
// PinchView can be either ImagePinchView or CollectionPinchView
-(instancetype) initWithFrame:(CGRect)frame andPinchView:(PinchView *)pinchView inPreviewMode: (BOOL) inPreviewMode;

//be sure to set povScrollView
-(void) showAndRemoveCircle;

@end
