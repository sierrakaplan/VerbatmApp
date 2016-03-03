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
//filter value ranges from 0 - 100
- (UIImage *)blurredImageWithFilterLevel: (float) filterValue;

- (UIImageView*) getBackgroundImageViewWithFrame: (CGRect) frame;

- (UIImageView*) getBlurImageViewWithFilterLevel: (float) filterValue andFrame:(CGRect) frame;

- (UIImage*) imageOverlayedWithColor:(UIColor*)color;

- (UIImage *)imageWithAlpha:(CGFloat) alpha;

- (UIImage*) scaleImageToSize:(CGSize)size;

+ (UIImage*) makeImageWithColorAndSize:(UIColor*) color andSize:(CGSize) size;

- (CGSize) getSizeForImageWithBounds:(CGRect)bounds;

- (UIImage *) getImageWithOrientationUp;

+ (NSArray*) getPhotoFilters;

@end
