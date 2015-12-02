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

-(void) publishWithTitle: (NSString*)title andPinchViews: (NSArray*) pinchViews;
-(void) aboutToShowPreview;
-(void) aboutToRemovePreview;
@end

@interface PreviewDisplayView : UIView

@property (strong, nonatomic) id<PreviewDisplayDelegate> delegate;

-(id) initWithFrame: (CGRect)frame;

//the start index is the page that we should start viewing at not including cover page
-(void) displayPreviewPOVWithTitle: (NSString*) title andPinchViews: (NSArray*) pinchViews withStartIndex: (NSInteger) index;

@end
