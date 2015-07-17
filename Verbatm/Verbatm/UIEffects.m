//
//  BlurView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/15/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "UIEffects.h"

@interface UIEffects () {

}

@end

@implementation UIEffects


+ (UIVisualEffectView*) createBlurViewOnView: (UIView*)view {
	view.backgroundColor = [UIColor clearColor];
	UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
	UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	blurEffectView.frame = view.frame;
	[view insertSubview:blurEffectView atIndex:0];

	[blurEffectView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
	[view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
	[view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
	[view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
	return blurEffectView;
}

+(void) addShadowToView: (UIView *) view {
	UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
	view.layer.masksToBounds = NO;
	view.layer.shadowColor = [UIColor blackColor].CGColor;
	view.layer.shadowOffset = CGSizeMake(3.0f, 0.3f);
	view.layer.shadowOpacity = 0.8f;
	view.layer.shadowPath = shadowPath.CGPath;
}

@end
