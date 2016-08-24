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

-(UIImage *)getViewScreenshot;

- (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth;

- (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth;

- (void)addLeftBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth;

- (void)addRightBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth;

@end
