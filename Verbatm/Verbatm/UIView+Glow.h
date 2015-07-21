//
//  UIView+Glow.m
//
//  Created by Jon Manning on 29/05/12.
//  Copyright (c) 2012 Secret Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Glow)

@property (nonatomic, readonly) UIView* glowView;
@property (nonatomic, readonly) UIView* secondGlowView;

#define DEFAULT_GLOW_DURATION 1.2
#define DEFAULT_GLOW_RADIUS_1 8.0
#define DEFAULT_GLOW_RADIUS_2 12.0
#define DEFAULT_GLOW_INTENSITY 1.0

// Fade up, then down.
- (void) glowOnce;

// Useful for indicating "this object should be over there"
- (void) glowOnceAtLocation:(CGPoint)point inView:(UIView*)view;

//FRAME OF GLOW VIEW WILL NOT CHANGE WHEN FRAME OF UIVIEW CHANGES
- (void) startGlowing;
- (void) startGlowingWithColor:(UIColor*)color withIntensity:(CGFloat)intensity andDuration:(float)duration;

- (void) stopGlowing;

@end
