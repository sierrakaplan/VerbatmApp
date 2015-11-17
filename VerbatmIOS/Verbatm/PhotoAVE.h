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

// Lets super class (with scroll view) know if the circle is currently dragging
-(void) startedDraggingAroundCircle;
-(void) stoppedDraggingAroundCircle;

@end

@interface PhotoAVE : UIView

@property (strong, nonatomic) id<PhotoAVEDelegate> delegate;
//this is used with the tap gesture in the photovideoave -- we pass it in in order to prevent them from intercepting each other
@property (nonatomic, strong) UITapGestureRecognizer * photoAveTapGesture;
@property (weak, nonatomic) UIScrollView * povScrollView;//set before showAndRemoveCircle is called. This allows us to make the pan gestures not interact
//photos are UIImage*
-(instancetype) initWithFrame:(CGRect)frame andPhotoArray: (NSArray *) photos  orPinchviewArray:(NSMutableArray *) pinchViewArray;

-(void) showAndRemoveCircle;//be sure to set povScrollView

@end
