//
//  mediaPreview.m
//  Verbatm
//
//  Created by Iain Usiri on 8/22/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "MediaPreview.h"
#import "VideoPlayerView.h"
#import "UIView+Effects.h"

@interface MediaPreview()
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) VideoPlayerView * videoPlayer;
#define  TIME_TO_FADEOUT 5 //how long it takes for this view to fade out in seconds
@end

@implementation MediaPreview


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self addShadowToView];
        self.alpha = 0;
    }
    return self;
}

//takes asset and decides how to present it
-(void)setAsset:(ALAsset *) asset{
    self.alpha = 1;//we do this because our view fades out
    //check if this is a video asset
    if([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
        [self.videoPlayer playVideoFromURL:asset.defaultRepresentation.url];
        [self.videoPlayer repeatVideoOnEnd:NO];
        [self.videoPlayer muteVideo];
        [self.videoPlayer removeMuteButtonFromView];
        [self addSubview:self.videoPlayer];
    //must be a photo asset
    }else{
        [self setOurImage:asset];
    }
      [self startFadeOut];
}


-(VideoPlayerView *)videoPlayer{
    if(!_videoPlayer){
        _videoPlayer =[[VideoPlayerView alloc] initWithFrame:self.bounds];
    }
    return _videoPlayer;
}

//takes an alasset and creates an image to view
-(void)setOurImage:(ALAsset *) asset  {
	@autoreleasepool {
		ALAssetRepresentation *representation = [asset defaultRepresentation];
		CGImageRef imageRef = [representation fullResolutionImage];
		self.imageView.image = [UIImage imageWithCGImage:imageRef
												   scale:representation.scale
											 orientation:(UIImageOrientation)representation.orientation];
		CGImageRelease(imageRef);
	}
}

-(UIImageView *)imageView{
    if(!_imageView){
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = self.bounds;
        [self addSubview:_imageView];
    }
    return _imageView;
}


-(void)startFadeOut{
    [UIView animateWithDuration:TIME_TO_FADEOUT animations:^{
        self.alpha = 0;
    }];
}

@end
