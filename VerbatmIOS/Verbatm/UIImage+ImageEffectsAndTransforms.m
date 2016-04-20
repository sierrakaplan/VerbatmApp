//
//  UIImage+ImageEffectsAndTransforms.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 10/6/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "UIImage+ImageEffectsAndTransforms.h"

@implementation UIImage (ImageEffectsAndTransforms)

- (UIImage*) halfPictureLeftHalf:(BOOL) leftHalf {
	@autoreleasepool {
		float xOrigin = leftHalf ? 0 : self.size.width/2.f;
		CGRect cropRect = CGRectMake(xOrigin, 0, self.size.width/2.f, self.size.height);
		CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
		UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation: self.imageOrientation];
		CGImageRelease(imageRef);
		return result;
	}
}

- (UIImage *)blurredImageWithFilterLevel: (float) filterValue {
	@autoreleasepool {
		//  Create our blurred image
		CIContext *context = [CIContext contextWithOptions:nil];
		CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];

		//  Setting up Gaussian Blur
		CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
		[filter setValue:inputImage forKey:kCIInputImageKey];
		[filter setValue:[NSNumber numberWithFloat:filterValue] forKey:@"inputRadius"];
		CIImage *filteredImage = [filter valueForKey:kCIOutputImageKey];

		/*  CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches
		 *  up exactly to the bounds of our original image */
		CGImageRef cgImage = [context createCGImage:filteredImage fromRect:[inputImage extent]];
		UIImage *result = [UIImage imageWithCGImage:cgImage];
		CGImageRelease(cgImage);
		return result;
	}
}

-(UIImageView*) getBackgroundImageViewWithFrame: (CGRect) frame {
	UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:self];
	backgroundImageView.frame = frame;
	backgroundImageView.clipsToBounds = YES;
	backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;

	return backgroundImageView;
}

- (UIImageView*) getBlurImageViewWithFilterLevel: (float) filterValue andFrame:(CGRect) frame {
	UIImage* blurImage = [self blurredImageWithFilterLevel: filterValue];
	UIImageView* blurredImageView = [[UIImageView alloc] initWithImage:blurImage];
	blurredImageView.frame = frame;
	blurredImageView.clipsToBounds = YES;
	blurredImageView.contentMode = UIViewContentModeScaleAspectFill;

	return blurredImageView;
}

- (UIImage*) imageOverlayedWithColor:(UIColor*)color {
	@autoreleasepool {
		//create context
		UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
		CGContextRef context = UIGraphicsGetCurrentContext();
		//drawingcode
		CGRect rect = CGRectMake(0.0, 0.0, self.size.width, self.size.height);
		[self drawInRect:rect];
		CGContextSetBlendMode(context, kCGBlendModeMultiply);
		CGContextSetFillColorWithColor(context, color.CGColor);
		CGContextFillRect(context, rect);
		[self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
		UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return newImage;
	}
}

- (UIImage *)imageWithAlpha:(CGFloat) alpha {

	@autoreleasepool {
		UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
		CGContextScaleCTM(ctx, 1, -1);
		CGContextTranslateCTM(ctx, 0, -area.size.height);
		CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
		CGContextSetAlpha(ctx, alpha);
		CGContextDrawImage(ctx, area, self.CGImage);
		UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return newImage;
	}
}

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize {
	UIImage *sourceImage = self;
	UIImage *newImage = nil;
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);

	if (!CGSizeEqualToSize(imageSize, targetSize)) {
		CGFloat widthFactor = targetWidth / width;
		CGFloat heightFactor = targetHeight / height;

		scaleFactor = widthFactor > heightFactor ? widthFactor : heightFactor;

		scaledWidth  = width * scaleFactor;
		scaledHeight = height * scaleFactor;

		// center the image
		if (widthFactor > heightFactor) {
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
		}
		else {
			if (widthFactor < heightFactor) {
				thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
			}
		}
	}

	UIGraphicsBeginImageContext(targetSize); // this will crop

	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;

	[sourceImage drawInRect:thumbnailRect];
	newImage = UIGraphicsGetImageFromCurrentImageContext();

	if(newImage == nil) {
		NSLog(@"could not scale image");
	}

	//pop the context to get back to the default
	UIGraphicsEndImageContext();

	return newImage;
}

- (UIImage*) scaleImageToSize:(CGSize)size {
	if (self.size.height == size.height && self.size.width == size.width) {
		return self;
	}

	@autoreleasepool {
		UIGraphicsBeginImageContext(size);
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextTranslateCTM(context, 0.0, size.height);
		CGContextScaleCTM(context, 1.0, -1.0);
		CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), self.CGImage);
		UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return scaledImage;
	}
}

+ (UIImage*) makeImageWithColorAndSize:(UIColor*) color andSize:(CGSize) size {
	UIGraphicsBeginImageContextWithOptions(size, false, 0);
	[color setFill];
	UIRectFill(CGRectMake(0, 0, size.width, size.height));
	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

- (CGSize) getSizeForImageWithBounds:(CGRect)bounds {
	CGSize currentSize = self.size;
	CGSize newSize;
	if ((currentSize.height/bounds.size.height) > (currentSize.width/bounds.size.width)) {
		newSize = CGSizeMake(bounds.size.height*(currentSize.width/currentSize.height), bounds.size.height);
	} else {
		newSize = CGSizeMake(bounds.size.width, bounds.size.width * (currentSize.height/currentSize.width));
	}
	return newSize;
}

- (UIImage *) getImageWithOrientationUp {

	// No-op if the orientation is already correct
	if (self.imageOrientation == UIImageOrientationUp) return self;

	@autoreleasepool {
		// We need to calculate the proper transformation to make the image upright.
		// We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
		CGAffineTransform transform = CGAffineTransformIdentity;

		// First fix orientation based on direction
		switch (self.imageOrientation) {
			case UIImageOrientationDown:
			case UIImageOrientationDownMirrored:
				transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
				transform = CGAffineTransformRotate(transform, M_PI);
				break;

			case UIImageOrientationLeft:
			case UIImageOrientationLeftMirrored:
				transform = CGAffineTransformTranslate(transform, self.size.width, 0);
				transform = CGAffineTransformRotate(transform, M_PI_2);
				break;

			case UIImageOrientationRight:
			case UIImageOrientationRightMirrored:
				transform = CGAffineTransformTranslate(transform, 0, self.size.height);
				transform = CGAffineTransformRotate(transform, -M_PI_2);
				break;
			case UIImageOrientationUp:
			case UIImageOrientationUpMirrored:
				break;
		}

		// Then fixed mirrored orientation
		switch (self.imageOrientation) {
			case UIImageOrientationUpMirrored:
			case UIImageOrientationDownMirrored:
				transform = CGAffineTransformTranslate(transform, self.size.width, 0);
				transform = CGAffineTransformScale(transform, -1, 1);
				break;

			case UIImageOrientationLeftMirrored:
			case UIImageOrientationRightMirrored:
				transform = CGAffineTransformTranslate(transform, self.size.height, 0);
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
		CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
												 CGImageGetBitsPerComponent(self.CGImage), 0,
												 CGImageGetColorSpace(self.CGImage),
												 CGImageGetBitmapInfo(self.CGImage));
		CGContextConcatCTM(ctx, transform);
		switch (self.imageOrientation) {
			case UIImageOrientationLeft:
			case UIImageOrientationLeftMirrored:
			case UIImageOrientationRight:
			case UIImageOrientationRightMirrored:
				// Grr...
				CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.height,
												   self.size.width), self.CGImage);
				break;

			default:
				CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width,
												   self.size.height), self.CGImage);
				break;
		}

		// And now we just create a new UIImage from the drawing context
		CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
		UIImage *img = [UIImage imageWithCGImage:cgimg];
		CGContextRelease(ctx);
		CGImageRelease(cgimg);
		
		return img;
	}
}

+ (NSArray*) getPhotoFilters {
	NSArray* filters = @[@"CIPhotoEffectChrome",
						 @"CIPhotoEffectMono",
//						 @"CIPhotoEffectNoir",
//						 @"CIPhotoEffectProcess",
//						 @"CIPhotoEffectFade",
						 @"CIPhotoEffectInstant",
						 @"CIPhotoEffectTransfer",
//						 @"CISepiaTone",
//						 @"CIVignette",
//						 @"CIColorPosterize"
//						 @"CIMotionBlur"
						 ];
	return filters;
}

@end
