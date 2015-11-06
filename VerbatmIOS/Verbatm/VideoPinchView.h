//
//  VideoPinchView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "PinchView.h"
#import "SingleMediaAndTextPinchView.h"

@interface VideoPinchView : SingleMediaAndTextPinchView

@property (strong, nonatomic) AVURLAsset* video;
@property (strong, nonatomic) NSString* phAssetLocalIdentifier;

-(instancetype)initWithRadius:(float)radius withCenter:(CGPoint)center andVideo: (AVURLAsset*)video andPHAssetLocalIdentifier: (NSString*) localIdentifier;

// sets up the pinch view with a video
-(void) initWithVideo: (AVURLAsset*) video;

@end
