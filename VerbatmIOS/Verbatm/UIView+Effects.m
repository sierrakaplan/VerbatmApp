//
//  UIView+Effects.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 10/6/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "UIView+Effects.h"
#import "AdjustableBlurEffect.h"

@implementation UIView (Effects)

- (UIVisualEffectView*) createLessBlurViewOnViewWithStyle:(UIBlurEffectStyle) blurStyle {
	UIBlurEffect *blurEffect = [AdjustableBlurEffect effectWithStyle:blurStyle];
	return [self createBlurViewOnViewFromEffect:blurEffect];
}

- (UIVisualEffectView*) createBlurViewOnViewWithStyle:(UIBlurEffectStyle) blurStyle {
	UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:blurStyle];
	return [self createBlurViewOnViewFromEffect:blurEffect];
}

- (UIVisualEffectView*) createBlurViewOnViewFromEffect:(UIBlurEffect*)blurEffect {
	self.backgroundColor = [UIColor clearColor];
	UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	[self insertSubview:blurEffectView atIndex:0];

	[blurEffectView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
	return blurEffectView;
}


- (void) addShadowToView {
	UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
	self.layer.masksToBounds = NO;
	self.layer.shadowColor = [UIColor blackColor].CGColor;
	self.layer.shadowOffset = CGSizeMake(3.0f, - 1.f);
	self.layer.shadowOpacity = 0.8f;
	self.layer.shadowPath = shadowPath.CGPath;
}

- (void) addDashedBorderToViewWithFrame:(CGRect) frame {

	//border definitions
	float cornerRadius = 0;
	float borderWidth = 1;
	int dashPattern1 = 10;
	int dashPattern2 = 10;
	UIColor *lineColor = [UIColor whiteColor];

	CAShapeLayer *_shapeLayer = [CAShapeLayer layer];

	//creating a path
	CGMutablePathRef path = CGPathCreateMutable();

	//drawing a border around a view
	CGPathMoveToPoint(path, NULL, 0, frame.size.height - cornerRadius);
	CGPathAddLineToPoint(path, NULL, 0, cornerRadius);
	CGPathAddArc(path, NULL, cornerRadius, cornerRadius, cornerRadius, M_PI, -M_PI_2, NO);
	CGPathAddLineToPoint(path, NULL, frame.size.width - cornerRadius, 0);
	CGPathAddArc(path, NULL, frame.size.width - cornerRadius, cornerRadius, cornerRadius, -M_PI_2, 0, NO);
	CGPathAddLineToPoint(path, NULL, frame.size.width, frame.size.height - cornerRadius);
	CGPathAddArc(path, NULL, frame.size.width - cornerRadius, frame.size.height - cornerRadius, cornerRadius, 0, M_PI_2, NO);
	CGPathAddLineToPoint(path, NULL, cornerRadius, frame.size.height);
	CGPathAddArc(path, NULL, cornerRadius, frame.size.height - cornerRadius, cornerRadius, M_PI_2, M_PI, NO);

	//path is set as the _shapeLayer object's path
	_shapeLayer.path = path;
	CGPathRelease(path);

	_shapeLayer.backgroundColor = [[UIColor clearColor] CGColor];
	_shapeLayer.frame = frame;
	_shapeLayer.masksToBounds = NO;
	[_shapeLayer setValue:[NSNumber numberWithBool:NO] forKey:@"isCircle"];
	_shapeLayer.fillColor = [[UIColor clearColor] CGColor];
	_shapeLayer.strokeColor = [lineColor CGColor];
	_shapeLayer.lineWidth = borderWidth;
	_shapeLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:dashPattern1], [NSNumber numberWithInt:dashPattern2], nil];
	_shapeLayer.lineCap = kCALineCapRound;
	//_shapeLayer is added as a sublayer of the view, the border is visible

	for (int i=0; i<self.layer.sublayers.count; i++) {
		if([self.layer.sublayers[i] isKindOfClass:[CAShapeLayer class]])
		{
			[self.layer.sublayers[i] removeFromSuperlayer];
		}
	}
	[self.layer addSublayer:_shapeLayer];
	self.layer.cornerRadius = cornerRadius;
}

-(void)addBorderToViewWithWidth:(CGFloat) borderWidth andColor:(UIColor *) color andRadius:(CGFloat) radius{
        self.layer.borderWidth = borderWidth;
        self.layer.borderColor = color.CGColor;
//        self.layer.shadowRadius = radius;
//        self.layer.shadowOffset = CGSizeMake(0, 0);
 //       self.layer.shadowOpacity = 1;
}

- (void) addDashedBorderToView {
	[self addDashedBorderToViewWithFrame:self.bounds];
}

- (UIActivityIndicatorView *) startActivityIndicatorOnViewWithCenter: (CGPoint) center
															andStyle:(UIActivityIndicatorViewStyle)style {

	UIActivityIndicatorView *  indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: style];
	indicator.alpha = 1.0;
	indicator.hidesWhenStopped = YES;
	indicator.center = center;
	[self addSubview:indicator];
	[self bringSubviewToFront:indicator];
	[indicator startAnimating];
	return indicator;
}

-(UIImage *)getViewScreenshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.f);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenShotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenShotImage;
}

- (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
	CALayer *border = [CALayer layer];
	border.backgroundColor = color.CGColor;

	border.frame = CGRectMake(0, 0, self.frame.size.width, borderWidth);
	[self.layer addSublayer:border];
}

- (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
	CALayer *border = [CALayer layer];
	border.backgroundColor = color.CGColor;

	border.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
	[self.layer addSublayer:border];
}

- (void)addLeftBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
	CALayer *border = [CALayer layer];
	border.backgroundColor = color.CGColor;

	border.frame = CGRectMake(0, 0, borderWidth, self.frame.size.height);
	[self.layer addSublayer:border];
}

- (void)addRightBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
	CALayer *border = [CALayer layer];
	border.backgroundColor = color.CGColor;

	border.frame = CGRectMake(self.frame.size.width - borderWidth, 0, borderWidth, self.frame.size.height);
	[self.layer addSublayer:border];
}

- (void) shake {
	CABasicAnimation *animation =
	[CABasicAnimation animationWithKeyPath:@"position"];
	[animation setDuration:0.05];
	[animation setRepeatCount: 4];
	[animation setAutoreverses:YES];
	[animation setFromValue:[NSValue valueWithCGPoint:
							 CGPointMake([self center].x - 10.0f, [self center].y)]];
	[animation setToValue:[NSValue valueWithCGPoint:
						   CGPointMake([self center].x + 10.0f, [self center].y)]];
	[[self layer] addAnimation:animation forKey:@"position"];
}

@end


