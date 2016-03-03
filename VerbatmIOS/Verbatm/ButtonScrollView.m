//
//  ButtonScrollView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/2/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//
//	Scrollview that can be covered in buttons and still drag

#import "ButtonScrollView.h"

@implementation ButtonScrollView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
	if ([view isKindOfClass:[UIButton class]] ) {
		return YES;
	}

	return [super touchesShouldCancelInContentView:view];
}

@end
