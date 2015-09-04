//
//  PreviewDisplay.h
//  Verbatm

//	Class that loads the preview of an article from PinchViews onto a POVView and adds a publish button
// 	Allows this view to be moved on and off screen by user
//
//  Created by Sierra Kaplan-Nelson on 9/2/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PreviewDisplayDelegate <NSObject>

-(void) publishButtonPressed;

@end

@interface PreviewDisplayView : UIView

@property (strong, nonatomic) id<PreviewDisplayDelegate> delegate;

-(id) initWithFrame: (CGRect)frame;
-(void) displayPreviewPOVFromPinchViews: (NSArray*) pinchViews;

@end
