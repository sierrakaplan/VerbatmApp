//
//  VerbatmCameraView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/14/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface VerbatmCameraView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic) float effectiveScale;
@property (nonatomic) float beginGestureScale;

@end
