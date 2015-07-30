//
//  VideoPinchView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "PinchView.h"
#import "VideoPlayerWrapperView.h"

@interface VideoPinchView : PinchView

typedef NS_ENUM(NSInteger, VideoFormat) {
	VideoFormatAsset,
	VideoFormatURL
};

@property (nonatomic) VideoFormat videoFormat;
@property (strong, nonatomic) VideoPlayerWrapperView *videoView;
//Can be AVAsset or NSURL
@property (strong, nonatomic) id video;

-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andVideo:(id)video;


@end
