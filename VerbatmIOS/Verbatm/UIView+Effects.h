//
//  UIView+Effects.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 10/6/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Effects)

- (UIVisualEffectView*) createLessBlurViewOnViewWithStyle:(UIBlurEffectStyle) blurStyle;

- (UIVisualEffectView*) createBlurViewOnViewWithStyle:(UIBlurEffectStyle) blurStyle;

- (UIVisualEffectView*) createBlurViewOnViewFromEffect:(UIBlurEffect*)blurEffect;

- (void) addShadowToView;

- (void) addDashedBorderToViewWithFrame:(CGRect) frame;

- (void) addDashedBorderToView;

- (UIActivityIndicatorView *) startActivityIndicatorOnViewWithCenter: (CGPoint) center
															andStyle:(UIActivityIndicatorViewStyle)style;

//make sure to set the frame of the view before calling for a screenshot
-(UIImage *)getViewScreenshotWithTextView:(UITextView *) textView;
@end
