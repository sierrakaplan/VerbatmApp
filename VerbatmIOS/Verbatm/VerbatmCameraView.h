//
//  VerbatmCameraView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/14/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Photos;

IB_DESIGNABLE

@protocol VerbatmCameraViewDelegate <NSObject>

-(void) imageCaptured: (UIImage*) image;
-(void) videoAssetCaptured: (PHAsset*) asset;

@end

@interface VerbatmCameraView : UIView <UIGestureRecognizerDelegate>

@property (strong, nonatomic) id<VerbatmCameraViewDelegate> delegate;

@property (nonatomic) float effectiveScale;
@property (nonatomic) float beginGestureScale;

@end
