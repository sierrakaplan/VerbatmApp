//
//  VerbatmCameraView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/14/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "VerbatmCameraView.h"

@interface VerbatmCameraView() 
@end

@implementation VerbatmCameraView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.effectiveScale = 1.0f;
	}
	return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	if ([touch.view isKindOfClass:[UIControl class]]) {
		// we touched our control surface
		return NO; // ignore the touch
	}
	return YES; // handle the touch
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
		self.beginGestureScale = self.effectiveScale;
	}
	return YES;
}

@end
