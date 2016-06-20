//
//  UIView+Glow.m
//
//  Created by Jon Manning on 29/05/12.
//  Copyright (c) 2012 Secret Lab. All rights reserved.
//

#import "UIView+Glow.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

// Used to identify the associating glowing view
static char* GLOWVIEW_KEY = "GLOWVIEW";
static char* SECOND_GLOWVIEW_KEY = "SECOND_GLOWVIEW";

@implementation UIView (Glow)

// Get the glowing view attached to this one.
- (UIView*) glowView {
    return objc_getAssociatedObject(self, GLOWVIEW_KEY);
}

- (UIView*) secondGlowView {
	return objc_getAssociatedObject(self, SECOND_GLOWVIEW_KEY);
}

// Attach a view to this one, which we'll use as the glowing view.
- (void) setGlowView:(UIView*)glowView {
    objc_setAssociatedObject(self, GLOWVIEW_KEY, glowView, OBJC_ASSOCIATION_RETAIN);
}

- (void) setSecondGlowView:(UIView*)glowView {
	objc_setAssociatedObject(self, SECOND_GLOWVIEW_KEY, glowView, OBJC_ASSOCIATION_RETAIN);
}

- (void)startGlowingWithColor:(UIColor*)color withIntensity:(CGFloat)intensity andDuration:(float)duration {
	[self startGlowingWithColor:color fromIntensity:0.1 toIntensity:intensity withDuration:duration repeat:YES];
}

- (void) startGlowingWithColor:(UIColor*)color fromIntensity:(CGFloat)fromIntensity toIntensity:(CGFloat)toIntensity withDuration:(float)duration repeat:(BOOL)repeat {
    
    // If we're already glowing, don't bother
    if ([self glowView] && [self secondGlowView])
        [self stopGlowing];
    
	UIImage* image = [self getGlowImageWithColor:color];
    
	UIImageView *glowView = [self createGlowViewFromImage:image withColor:color andRadius:DEFAULT_GLOW_RADIUS_1 fromIntensity:fromIntensity toIntensity:toIntensity withDuration:duration repeat:YES];

	UIImageView *secondGlowView = [self createGlowViewFromImage:image withColor:color andRadius:DEFAULT_GLOW_RADIUS_2 fromIntensity:fromIntensity toIntensity:toIntensity withDuration:duration repeat:YES];

    // Finally, keep a reference to this around so it can be removed later
    [self setGlowView:glowView];
	[self setSecondGlowView:secondGlowView];
}

- (UIImage*) getGlowImageWithColor:(UIColor*)color {
	// The glow image is taken from the current view's appearance.
	// As a side effect, if the view's content, size or shape changes,
	// the glow won't update.
	UIImage* image;

	@autoreleasepool {
		UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
		[self.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIBezierPath* path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
		[color setFill];
		[path fillWithBlendMode:kCGBlendModeSourceAtop alpha:1.0];
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	return image;
}

-(UIImageView*) createGlowViewFromImage:(UIImage*)image withColor:(UIColor*)color andRadius:(float)radius fromIntensity:(CGFloat)fromIntensity toIntensity:(CGFloat)toIntensity withDuration:(float)duration repeat:(BOOL)repeat {
	// Make the glowing view itself, and position it at the same
	// point as ourself. Overlay it over ourself.
	UIImageView* glowView = [[UIImageView alloc] initWithImage:image];
	glowView.center = self.center;
	[self.superview insertSubview:glowView belowSubview:self];

	// We don't want to show the image, but rather a shadow created by
	// Core Animation. By setting the shadow to white and the shadow radius to
	// something large, we get a pleasing glow.
	glowView.alpha = 0;
	glowView.layer.shadowColor = color.CGColor;
	glowView.layer.shadowOffset = CGSizeZero;
	glowView.layer.shadowRadius = radius;
	glowView.layer.shadowOpacity = 1.0;

	// Create an animation that slowly fades the glow view in and out forever.
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	animation.fromValue = @(fromIntensity);
	animation.toValue = @(toIntensity);
	animation.repeatCount = repeat ? HUGE_VAL : 0;
	animation.duration = duration;
	animation.autoreverses = YES;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

	[glowView.layer addAnimation:animation forKey:@"pulse"];
	return glowView;
}

- (void) glowOnceAtLocation:(CGPoint)point inView:(UIView*)view {
	[self startGlowingWithColor:[UIColor whiteColor] fromIntensity:0 toIntensity:DEFAULT_GLOW_INTENSITY withDuration:DEFAULT_GLOW_DURATION repeat:NO];
    
    [self glowView].center = point;
    [view addSubview:[self glowView]];
    
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self stopGlowing];
    });
}

- (void)glowOnce {
    [self startGlowing];
    
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self stopGlowing];
    });
    
}

// Create a pulsing, glowing view based on this one.
- (void) startGlowing {
    [self startGlowingWithColor:[UIColor whiteColor] withIntensity:DEFAULT_GLOW_INTENSITY andDuration: DEFAULT_GLOW_DURATION];
}

// Stop glowing by removing the glowing view from the superview 
// and removing the association between it and this object.
- (void) stopGlowing {
    [[self glowView] removeFromSuperview];
    [self setGlowView:nil];
	[[self secondGlowView] removeFromSuperview];
	[self setSecondGlowView:nil];
}

@end
