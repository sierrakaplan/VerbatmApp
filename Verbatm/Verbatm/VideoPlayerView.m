//
//  VideoPlayer.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/10/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "VideoPlayerView.h"

@interface VideoPlayerView()

@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) AVPlayerItem* playerItem;
@property (nonatomic) BOOL repeatsVideo;

@end

@implementation VideoPlayerView

-(instancetype)init {
	if((self  = [super init])) {
		self.repeatsVideo = NO;
	}
	return self;
}


//make sure the sublayer resizes with the view screen
- (void)layoutSubviews
{
  self.playerLayer.frame = self.bounds;
}


-(void)playVideoFromURL: (NSURL*) url {
	if (url) {
		self.player = [AVPlayer playerWithURL:url];
		[self playVideo];
	}
}

-(void)playVideoFromAsset: (AVAsset*) asset{
	if (asset) {
		// Create an AVPlayerItem using the asset
		self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
		self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
		[self playVideo];
	}
}

-(void) playVideo {
	// Create the AVPlayer using the playeritem

	self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(playerItemDidReachEnd:)
												 name:AVPlayerItemDidPlayToEndTimeNotification
											   object:[self.player currentItem]];

	// Create an AVPlayerLayer using the player
	self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
	self.playerLayer.frame = self.bounds;
	self.playerLayer.videoGravity =  AVLayerVideoGravityResizeAspectFill;
	[self.playerLayer removeAllAnimations];
	// Add it to your view's sublayers
	[self.layer addSublayer:self.playerLayer];
	[self.player play];

}

-(void) repeatVideoOnEnd:(BOOL)repeat {
	self.repeatsVideo = repeat;
}

//tells me when the video ends so that I can rewind
-(void)playerItemDidReachEnd:(NSNotification *)notification
{
	AVPlayerItem *playerItem = [notification object];
	if (self.repeatsVideo) {
		[playerItem seekToTime:kCMTimeZero];
	}
}

//pauses the video for the pinchview if there is one
-(void)pauseVideo
{
	if (self.player)
    {
		[self.player pause];
	}
}

//plays the video of the pinch view if there is one
-(void)continueVideo
{
	if (self.player)
    {
		[self.player play];
	}
}

-(void)unmuteVideo
{
	if(self.player)
    {
		[self.player setMuted:NO];
	}
}

-(void)muteVideo
{
	if(self.player)
    {
		[self.player setMuted:YES];
	}
}

-(void)fastForwardVideoWithRate: (NSInteger) rate
{
	if(self.player) {
		AVPlayerItem* playerItem = self.player.currentItem;
		if([playerItem canPlayFastForward]) self.playerLayer.player.rate = rate;
	}
}

-(void)rewindVideoWithRate: (NSInteger) rate
{
	if(self.player) {
		AVPlayerItem* playerItem = self.player.currentItem;
		if([playerItem canPlayFastReverse] && self.playerLayer.player.rate) self.playerLayer.player.rate = -rate;
	}
}


@end