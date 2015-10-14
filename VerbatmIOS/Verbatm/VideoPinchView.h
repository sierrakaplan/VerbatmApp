//
//  VideoPinchView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "PinchView.h"

@interface VideoPinchView : PinchView

@property (strong, nonatomic) AVURLAsset* video;

@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSNumber* textYPosition; // float value

-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andVideo: (AVURLAsset*)video;


@end
