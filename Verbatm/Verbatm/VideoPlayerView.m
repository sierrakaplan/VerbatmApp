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

@end

@implementation VideoPlayerView

-(instancetype)init {
	if((self  = [super init])) {

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
	// Create an AVPlayerLayer using the player
	self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
	self.playerLayer.frame = self.bounds;
	self.playerLayer.videoGravity =  AVLayerVideoGravityResizeAspectFill;
	// Add it to your view's sublayers
	[self.layer addSublayer:self.playerLayer];
	[self.player play];

}

-(void) repeatVideoOnEnd {
	if (self.player) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(playerItemDidReachEnd:)
													 name:AVPlayerItemDidPlayToEndTimeNotification
												   object:[self.player currentItem]];
	}
}

//tells me when the video ends so that I can rewind
-(void)playerItemDidReachEnd:(NSNotification *)notification
{
	AVPlayerItem *p = [notification object];
	[p seekToTime:kCMTimeZero];
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