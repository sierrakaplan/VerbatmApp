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

+(void) addDashedBorderToView: (UIView *) view
{
	//border definitions
	float cornerRadius = 0;
	float borderWidth = 1;
	int dashPattern1 = 10;
	int dashPattern2 = 10;
	UIColor *lineColor = [UIColor whiteColor];

	//drawing boundary
	CGRect frame = view.bounds;

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

	for (int i=0; i<view.layer.sublayers.count; i++) {
		if([view.layer.sublayers[i] isKindOfClass:[CAShapeLayer class]])
		{
			[view.layer.sublayers[i] removeFromSuperlayer];
		}
	}
	[view.layer addSublayer:_shapeLayer];
	view.layer.cornerRadius = cornerRadius;
}

+ (CGFloat)measureHeightOfUITextView:(UITextView *)textView
{
	if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
	{
		// This is the code for iOS 7. contentSize no longer returns the correct value, so
		// we have to calculate it.
		//
		// This is partly borrowed from HPGrowingTextView, but I've replaced the
		// magic fudge factors with the calculated values (having worked out where
		// they came from)

		CGRect frame = textView.bounds;

		// Take account of the padding added around the text.

		UIEdgeInsets textContainerInsets = textView.textContainerInset;
		UIEdgeInsets contentInsets = textView.contentInset;

		CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
		CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;

		frame.size.width -= leftRightPadding;
		frame.size.height -= topBottomPadding;

		NSString *textToMeasure = textView.text;
		if ([textToMeasure hasSuffix:@"\n"])
		{
			textToMeasure = [NSString stringWithFormat:@"%@-", textView.text];
		}

		// NSString class method: boundingRectWithSize:options:attributes:context is
		// available only on ios7.0 sdk.

		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
		[paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];

		UIFont* font = textView.font;
		NSDictionary *attributes = @{ NSFontAttributeName: font, NSParagraphStyleAttributeName : paragraphStyle };

		CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
												  options:NSStringDrawingUsesLineFragmentOrigin
											   attributes:attributes
												  context:nil];

		CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
		return measuredHeight;
	}
	else
	{
		return textView.contentSize.height;
	}
}

+ (UIImage *)image:(UIImage*) image byApplyingAlpha:(CGFloat) alpha {
	UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);

	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);

	CGContextScaleCTM(ctx, 1, -1);
	CGContextTranslateCTM(ctx, 0, -area.size.height);

	CGContextSetBlendMode(ctx, kCGBlendModeMultiply);

	CGContextSetAlpha(ctx, alpha);

	CGContextDrawImage(ctx, area, image.CGImage);

	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();

	return newImage;
}

@end
