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

@end
