//
//  VideoPlayerWrapperView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "VideoPlayerWrapperView.h"

@implementation VideoPlayerWrapperView

-(instancetype)initWithFrame:(CGRect)frame {
	if((self  = [super initWithFrame:frame])) {
		self.videoPlayerView = [[VideoPlayerView alloc] initWithFrame:self.bounds];
		[self addSubview:self.videoPlayerView];
		self.autoresizesSubviews = YES;
	}
	return self;
}

-(void)playVideoFromURL: (NSURL*) url {
	[self.videoPlayerView playVideoFromURL:url];
}

-(void)playVideoFromAsset: (AVAsset*) asset {
	[self.videoPlayerView playVideoFromAsset:asset];
}

-(void) playVideoFromArray: (NSArray*)videoList {
	[self.videoPlayerView playVideoFromArray:videoList];
}

-(void) playVideoFromURLList: (NSArray*) urlList {
	[self.videoPlayerView playVideoFromURLList:urlList];
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
