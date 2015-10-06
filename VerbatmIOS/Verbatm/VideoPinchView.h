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

//this is set by the edit content view.
//it's also formatted etc by the edit content view
@property (nonatomic, strong) UITextView * textView;

@property (strong, nonatomic) VideoPlayerWrapperView *videoView;

@property (strong, nonatomic) AVURLAsset* video;

-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andVideo: (AVURLAsset*)video;


@end
