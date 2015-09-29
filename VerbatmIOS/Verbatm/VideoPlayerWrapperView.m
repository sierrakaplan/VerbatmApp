//
//  VideoPlayerWrapperView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "VideoPlayerWrapperView.h"
#import <MediaPlayer/MediaPlayer.h>


@implementation VideoPlayerWrapperView

-(instancetype)initWithFrame:(CGRect)frame {
	if((self  = [super initWithFrame:frame])) {
        [self formatImagePresentation];
    }
	return self;
}

-(void)formatImagePresentation{
      self.contentMode = UIViewContentModeScaleAspectFit;
      self.clipsToBounds = YES;
}

-(void)playVideoFromURL: (NSURL*) url {
    self.image = [self getThumbnailFromAsset:[AVAsset assetWithURL:url]];
}

-(void)playVideoFromAsset: (AVAsset*) asset {
    self.image = [self getThumbnailFromAsset:asset];
}

//takes an asset and gets the first frame of the video
-(UIImage *)getThumbnailFromAsset:(AVAsset *)asset{
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        imageGenerator.appliesPreferredTrackTransform = YES;
        CMTime time = [asset duration];
        time.value = 0;
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        return thumbnail;
}


-(void) playVideoFromArray: (NSArray*)videoList {
	[self.videoPlayerView playVideoFromArrayOfAssets:videoList];
}

-(void)repeatVideoOnEnd:(BOOL)repeat {
	[self.videoPlayerView repeatVideoOnEnd:repeat];
}

-(void)pauseVideo {
	[self.videoPlayerView pauseVideo];
}

-(void)continueVideo {
	[self.videoPlayerView continueVideo];
}

-(void)unmuteVideo {
	[self.videoPlayerView unmuteVideo];
}

-(void)muteVideo {
	[self.videoPlayerView muteVideo];
}

-(void)fastForwardVideoWithRate: (NSInteger) rate {
	[self.videoPlayerView fastForwardVideoWithRate:rate];
}

-(void)rewindVideoWithRate: (NSInteger) rate {
	[self.videoPlayerView rewindVideoWithRate:rate];
}

-(void) stopVideo {
	[self.videoPlayerView stopVideo];
}

-(BOOL) isPlaying {
	return [self.videoPlayerView isPlaying];
}

@end
