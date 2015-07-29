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
@property (strong, nonatomic) AVMutableComposition* mix;

@end

@implementation VideoPlayerView

-(instancetype)init {
	if((self  = [super init])) {
		self.repeatsVideo = NO;
	}
	return self;
}


//make sure the sublayer resizes with the view screen
- (void)layoutSubviews {
	if (self.playerLayer) {
		self.playerLayer.frame = self.bounds;
	}
}


-(void)playVideoFromURL: (NSURL*) url {
	if(self.isPlaying) {
		[self stopVideo];
	}
	if (url) {
		self.player = [AVPlayer playerWithURL:url];
		[self playVideo];
	}
}

-(void)playVideoFromAsset: (AVAsset*) asset{
	if (self.isPlaying) {
		[self stopVideo];
	}
	if (asset) {
		// Create an AVPlayerItem using the asset
		self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
		self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
		[self playVideo];
	}
}

-(void) playVideoFromArray: (NSArray*)videoList {
	[self fuseAssets:videoList];
	[self playVideoFromAsset:self.mix];
}

/*This code fuses the video assets into a single video that plays the videos one after the other*/
-(void)fuseAssets:(NSArray*)videoList {

	self.mix = [AVMutableComposition composition]; //create a composition to hold the joined assets
	AVMutableCompositionTrack* videoTrack = [self.mix addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
	AVMutableCompositionTrack* audioTrack = [self.mix addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
	CMTime nextClipStartTime = kCMTimeZero;
	NSError* error;

	for(AVURLAsset* videoAsset in videoList) {
		AVAssetTrack* this_video_track = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
		[videoTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:this_video_track atTime:nextClipStartTime error: &error]; //insert the video
		videoTrack.preferredTransform = this_video_track.preferredTransform;
		AVAssetTrack* this_audio_track = [[videoAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];

		videoTrack.preferredTransform = this_video_track.preferredTransform;

		if(this_audio_track != nil) {
			[audioTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:this_audio_track atTime:nextClipStartTime error:&error];
		}
		nextClipStartTime = CMTimeAdd(nextClipStartTime, videoAsset.duration);
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
-(void)pauseVideo {
	if (self.player) {
		[self.player pause];
	}
}

//plays the video of the pinch view if there is one
-(void)continueVideo {
	if (self.player) {
		[self.player play];
	}
}

-(void)unmuteVideo {
	if(self.player) {
		[self.player setMuted:NO];
	}
}

-(void)muteVideo {
	if(self.player) {
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

-(BOOL) isPlaying {
	if(self.player) {
		return YES;
	} else {
		return NO;
	}
}

//cleans up video
-(void) stopVideo {
	self.layer.sublayers = nil;
	self.playerItem = nil;
	self.player = nil;
	self.playerLayer = nil;
	self.mix = nil;
}


@end