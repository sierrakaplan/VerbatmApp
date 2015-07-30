//
//  BlurView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/15/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "UIEffects.h"
#import "SizesAndPositions.h"

@interface UIEffects () {

}

@end

@implementation UIEffects


+ (UIVisualEffectView*) createBlurViewOnView: (UIView*)view withStyle:(UIBlurEffectStyle) blurStyle {
	view.backgroundColor = [UIColor clearColor];
	UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:blurStyle];
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

+ (UIImage *)blurredImageWithImage:(UIImage *)sourceImage andFilterLevel: (float) filterValue{

	//  Create our blurred image
	CIContext *context = [CIContext contextWithOptions:nil];
	CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];

	//  Setting up Gaussian Blur
	CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
	[filter setValue:inputImage forKey:kCIInputImageKey];
	[filter setValue:[NSNumber numberWithFloat:filterValue] forKey:@"inputRadius"];
	CIImage *result = [filter valueForKey:kCIOutputImageKey];

	/*  CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches
	 *  up exactly to the bounds of our original image */
	CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];

	UIImage *retVal = [UIImage imageWithCGImage:cgImage];
	return retVal;
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

+(UIImage*) getGlowImageFromView:(UIView*)view andColor:(UIColor*)color {
	// The glow image is taken from the current view's appearance.
	// As a side effect, if the view's content, size or shape changes,
	// the glow won't update.
	UIImage* image;

	UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale); {
		[view.layer renderInContext:UIGraphicsGetCurrentContext()];

		UIBezierPath* path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)];

		[color setFill];

		[path fillWithBlendMode:kCGBlendModeSourceAtop alpha:1.0];

		image = UIGraphicsGetImageFromCurrentImageContext();
	} UIGraphicsEndImageContext();
	return image;
}

+(void) addDashedBorderToView:(UIView *)view withFrame:(CGRect) frame {

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

	for (int i=0; i<view.layer.sublayers.count; i++) {
		if([view.layer.sublayers[i] isKindOfClass:[CAShapeLayer class]])
		{
			[view.layer.sublayers[i] removeFromSuperlayer];
		}
	}
	[view.layer addSublayer:_shapeLayer];
	view.layer.cornerRadius = cornerRadius;

}

+(void) addDashedBorderToView: (UIView *) view {
	[self addDashedBorderToView:view withFrame:view.bounds];
}

+ (CGFloat)measureContentHeightOfUITextView:(UITextView *)textView {
	CGSize textViewSize = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, FLT_MAX)];
	return textViewSize.height;
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

+ (UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)size {

	if (image.size.height == size.height && image.size.width == size.width) {
		return image;
	}

	UIGraphicsBeginImageContext(size);

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0, size.height);
	CGContextScaleCTM(context, 1.0, -1.0);

	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);

	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();

	return scaledImage;
}

+(CGSize) getSizeForImage:(UIImage*)image andBounds:(CGRect)bounds {
	CGSize currentSize = image.size;
	CGSize newSize;

	if ((currentSize.height/bounds.size.height) > (currentSize.width/bounds.size.width)) {
		newSize = CGSizeMake(bounds.size.height*(currentSize.width/currentSize.height), bounds.size.height);
	} else {
		newSize = CGSizeMake(bounds.size.width, bounds.size.width * (currentSize.height/currentSize.width));
	}

	return newSize;
}

+ (UIImage *)fixOrientation:(UIImage*) image {

	// No-op if the orientation is already correct
	if (image.imageOrientation == UIImageOrientationUp) return image;

	// We need to calculate the proper transformation to make the image upright.
	// We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
	CGAffineTransform transform = CGAffineTransformIdentity;

	switch (image.imageOrientation) {
		case UIImageOrientationDown:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;

		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
			transform = CGAffineTransformTranslate(transform, image.size.width, 0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;

		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, 0, image.size.height);
			transform = CGAffineTransformRotate(transform, -M_PI_2);
			break;
		case UIImageOrientationUp:
		case UIImageOrientationUpMirrored:
			break;
	}

	switch (image.imageOrientation) {
		case UIImageOrientationUpMirrored:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformTranslate(transform, image.size.width, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;

		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, image.size.height, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;
		case UIImageOrientationUp:
		case UIImageOrientationDown:
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
			break;
	}

	// Now we draw the underlying CGImage into a new context, applying the transform
	// calculated above.
	CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
											 CGImageGetBitsPerComponent(image.CGImage), 0,
											 CGImageGetColorSpace(image.CGImage),
											 CGImageGetBitmapInfo(image.CGImage));
	CGContextConcatCTM(ctx, transform);
	switch (image.imageOrientation) {
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			// Grr...
			CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
			break;

		default:
			CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
			break;
	}

	// And now we just create a new UIImage from the drawing context
	CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
	UIImage *img = [UIImage imageWithCGImage:cgimg];
	CGContextRelease(ctx);
	CGImageRelease(cgimg);
	return img;
}

+ (void) disableSpellCheckOnTextField: (UITextField*)textField {
	[textField resignFirstResponder];
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	[textField becomeFirstResponder];
}

+ (NSArray*) getPhotoFilters {
	NSArray* filters = @[@"CIPhotoEffectChrome",
						 @"CIPhotoEffectMono",
//						 @"CIPhotoEffectNoir",
						 @"CIPhotoEffectProcess",
//						 @"CIPhotoEffectFade",
						 @"CIPhotoEffectInstant",
						 @"CIPhotoEffectTransfer",
						 @"CISepiaTone",
//						 @"CIVignette",
						 @"CIColorPosterize"
//						 @"CIMotionBlur"
						];
	return filters;
}

@end
