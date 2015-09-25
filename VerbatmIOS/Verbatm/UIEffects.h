//
//  BlurView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/15/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIEffects : NSObject

+ (UIVisualEffectView*) createLessBlurViewOnView: (UIView*)view withStyle:(UIBlurEffectStyle) blurStyle;
+ (UIVisualEffectView*) createBlurViewOnView: (UIView*)view withStyle:(UIBlurEffectStyle) blurStyle;
+ (UIVisualEffectView*) createBlurViewOnView:(UIView *)view fromEffect:(UIBlurEffect*) blurEffect;

+ (UIImageView*) getBlurImageViewForImage:(UIImage*) image withFrame:(CGRect) frame;

+ (UIImage *)blurredImageWithImage:(UIImage *)sourceImage andFilterLevel: (float) filterValue;

+(UIImage*) getGlowImageFromView:(UIView*)view andColor:(UIColor*)color;

+ (void) addShadowToView: (UIView *) view;

// adds dashed border to view using view.bounds as frame
+ (void) addDashedBorderToView: (UIView *) view;

+ (void) addDashedBorderToView:(UIView *)view withFrame:(CGRect) frame;

//+ (UIImage*) imageOverlayed:(UIImage*)image withColor:(UIColor*)color;

+ (UIImage *)image:(UIImage*) image byApplyingAlpha:(CGFloat) alpha;

+ (UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)size;

+(CGSize) getSizeForImage:(UIImage*)image andBounds:(CGRect)bounds;

+ (UIImage *)fixOrientation:(UIImage*) image;

// Contains code for iOS 7+. contentSize no longer returns the correct value, so
// we have to calculate it.
+ (CGFloat)measureContentHeightOfUITextView:(UITextView *)textView;

+ (void) disableSpellCheckOnTextField: (UITextField*)textView;

//Returns list of photo filter names to use
+ (NSArray*) getPhotoFilters;

//let users know there is another page by bouncing a tiny bit and then bouncing back
//Takes a bool letting it know which direction the scrollview should bounce
//Also takes a bool letting it know if bounce should be in y or x direction
+ (void) scrollViewNotificationBounce:(UIScrollView*)scrollView forNextPage:(BOOL)nextPage inYDirection:(BOOL)yDirection;

/*
 We pass in a reference to an activity indicator property and this formats it
 and sets it on whatever view we want it on.
 The center point should be the center of the view - but it can be anywhere
 you want to place the indicator
 */
+(UIActivityIndicatorView *) startActivityIndicatorOnView: (UIView *) view
                                                andCenter: (CGPoint) center
                                                 andStyle:(UIActivityIndicatorViewStyle) style;
/*Stops the indicator*/
+(void)stopActivityIndicator:(UIActivityIndicatorView *) indicator;
@end
