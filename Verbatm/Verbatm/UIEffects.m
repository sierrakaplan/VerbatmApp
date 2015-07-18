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

+ (UIImage*) imageOverlayed:(UIImage*)image withColor:(UIColor*)color {
	//create context
	UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
	CGContextRef context = UIGraphicsGetCurrentContext();

	//drawingcode
	CGRect rect = CGRectMake(0.0, 0.0, image.size.width, image.size.height);

	[image drawInRect:rect];

	CGContextSetBlendMode(context, kCGBlendModeMultiply);
	CGContextSetFillColorWithColor(context, color.CGColor);
	CGContextFillRect(context, rect);

	[image drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
	UIImage *newimage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return newimage;
}

@end
