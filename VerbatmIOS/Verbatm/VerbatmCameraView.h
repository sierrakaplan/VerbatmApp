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

-(void) imageAssetCaptured: (PHAsset *) asset;
-(void) videoAssetCaptured: (PHAsset*) asset;
-(void) minimizeCameraViewButtonTapped;

@end

@interface VerbatmCameraView : UIView <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id<VerbatmCameraViewDelegate> delegate;

@property (nonatomic) float effectiveScale;
@property (nonatomic) float beginGestureScale;

-(void) createAndInstantiateGestures;

@end
