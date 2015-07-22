//
//  BlurView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/15/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIEffects : NSObject 
+ (UIVisualEffectView*) createBlurViewOnView: (UIView*)view;
+ (void) addShadowToView: (UIView *) view;
+ (UIImage*) imageOverlayed:(UIImage*)image withColor:(UIColor*)color;
// Contains code for iOS 7+. contentSize no longer returns the correct value, so
// we have to calculate it.
+ (CGFloat)measureHeightOfUITextView:(UITextView *)textView;
@end
