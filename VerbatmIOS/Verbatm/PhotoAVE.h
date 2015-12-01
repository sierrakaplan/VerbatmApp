//
//  PhotoAVE.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PinchView.h"


@protocol PhotoAVEDelegate <NSObject>

-(void) startedDraggingAroundCircle;
-(void) stoppedDraggingAroundCircle;

@end

@protocol AVETextEntryDelegate <NSObject>

-(void) editContentViewTextIsEditing;
-(void) editContentViewTextDoneEditing;

@end

@interface PhotoAVE : ArticleViewingExperience

@property (strong, nonatomic) id<PhotoAVEDelegate> delegate;

@property (strong, nonatomic) id<PhotoAVETextEntryDelegate> textEntryDelegate;

//this is used with the tap gesture in the photovideoave -- we pass it in in order to prevent them from intercepting each other
@property (nonatomic, strong) UITapGestureRecognizer * photoAveTapGesture;

@property (weak, nonatomic) UIScrollView * povScrollView;

//Photos is array of UIImage
-(instancetype) initWithFrame:(CGRect)frame andPhotoArray: (NSArray *) photos  orPinchview:(PinchView *) pinchView
     isSubViewOfPhotoVideoAve:(BOOL) isPVSubview;

-(void) showAndRemoveCircle;//be sure to set povScrollView

@end
