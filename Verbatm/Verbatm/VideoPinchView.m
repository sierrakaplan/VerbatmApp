//
//  VideoPinchView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "VideoPinchView.h"

@interface VideoPinchView()

@end

@implementation VideoPinchView

-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andVideo:(id)video {
	self = [super initWithRadius:radius withCenter:center];
	if (self) {
		[self.background addSubview:self.videoView];
		self.containsVideo = YES;
		if ([video isKindOfClass:[AVAsset class]]) {
			self.videoFormat = VideoFormatAsset;
		} else if ([video isKindOfClass:[NSURL class]]) {
			self.videoFormat = VideoFormatURL;
		} else {
			NSLog(@"Video passed in is not asset or url format");
			return self;
		}
		self.video = video;
		[self renderMedia];
	}
	return self;
}

//overriding
-(NSArray*) getVideos {
	return @[self.video];
}

#pragma mark - Lazy Instantiation

-(VideoPlayerView*)videoView {
	if(!_videoView) _videoView = [[VideoPlayerView alloc] init];
	[_videoView repeatVideoOnEnd:YES];
	return _videoView;
}

#pragma mark - Render Media -

//This should be overriden in subclasses
-(void)renderMedia {
	self.videoView.frame = self.background.frame;
	[self displayMedia];
}

//This function displays the media on the view.
-(void)displayMedia {
	switch (self.videoFormat) {
		case VideoFormatAsset:
			[self.videoView playVideoFromAsset: self.video];
			break;
		case VideoFormatURL:
			[self.videoView playVideoFromURL: self.video];
			break;
		default:
			break;
	}
	[self.videoView muteVideo];
}

#pragma mark - When pinch view goes on and off screen

-(void)offScreen {
	if(self.videoView.playerLayer) {
		[self.videoView pauseVideo];
	}
}

-(void)onScreen {
	if(self.videoView.playerLayer) {
		[self.videoView continueVideo];
	}
}
@end
