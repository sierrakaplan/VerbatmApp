//
//  UIImage+ImageEffectsAndTransforms.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 10/6/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageEffectsAndTransforms)

- (UIImage*) halfPictureLeftHalf:(BOOL) leftHalf;

- (UIImage *)blurredImageWithFilterLevel: (float) filterValue;

- (UIImageView*) getBlurImageViewWithFilterLevel: (float) filterValue andFrame:(CGRect) frame;

- (UIImage*) imageOverlayedWithColor:(UIColor*)color;

- (UIImage *)imageWithAlpha:(CGFloat) alpha;

- (UIImage*) scaleImageToSize:(CGSize)size;

- (CGSize) getSizeForImageWithBounds:(CGRect)bounds;

- (UIImage *) getImageWithOrientationUp;

+ (NSArray*) getPhotoFilters;

@end
