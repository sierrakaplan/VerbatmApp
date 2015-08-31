//
//  VideoPlayer.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/10/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "VideoPlayerView.h"
#import "Icons.h"

@interface VideoPlayerView()

@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) AVPlayerItem* playerItem;
@property (nonatomic,strong) AVPlayerLayer* playerLayer;
@property (nonatomic) BOOL repeatsVideo;
@property (strong, nonatomic) AVMutableComposition* mix;
@property (strong, nonatomic) UIImageView* videoLoadingView;
@property (nonatomic) BOOL videoLoading;

@end

@implementation VideoPlayerView

-(instancetype)initWithFrame:(CGRect)frame {
	if((self  = [super initWithFrame:frame])) {
		self.repeatsVideo = NO;
		UIImage* videoLoadingImage = [UIImage imageNamed:VIDEO_LOADING_ICON];
		self.videoLoadingView = [[UIImageView alloc] initWithImage: videoLoadingImage];
		self.videoLoadingView.frame = self.bounds;
		self.videoLoading = NO;
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
	if (url) {
		self.videoLoading = YES;
		[self setPlayerItemFromPlayerItem:[AVPlayerItem playerItemWithURL:url]];
		[self playVideo];
		[self addSubview:self.videoLoadingView];
	}
}

-(void)playVideoFromAsset: (AVAsset*) asset{
	if (asset) {
		[self setPlayerItemFromPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
		[self playVideo];
	}
}

-(void) setPlayerItemFromPlayerItem:(AVPlayerItem*)playerItem {
	if (self.playerItem) {
		[self removePlayerItemObserver];
	}
	self.playerItem = playerItem;
	[self.playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(playerItemDidReachEnd:)
												 name:AVPlayerItemDidPlayToEndTimeNotification
											   object:self.playerItem];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context {
	if (object == self.playerItem && [keyPath isEqualToString:@"status"]) {
		if (self.playerItem.status == AVPlayerStatusReadyToPlay) {
			if (self.videoLoading) {
				[self.videoLoadingView removeFromSuperview];
				self.videoLoading = NO;
			}
		} else if (self.playerItem.status == AVPlayerStatusFailed) {
			// something went wrong. player.error should contain some information
		}
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
	if (self.isPlaying) {
		[self stopVideo];
	}

	self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
	self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;

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
-(void)playerItemDidReachEnd:(NSNotification *)notification {

	AVPlayerItem *playerItem = [notification object];
    if (self.repeatsVideo) {
		[playerItem seekToTime:kCMTimeZero];
	}
}

//pauses the video for the pinchview if there is one
-(void)pauseVideo {
	[self removePlayerItemObserver];
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
	if(self.playerItem) {
		if([self.playerItem canPlayFastForward]) self.playerLayer.player.rate = rate;
	}
}

-(void)rewindVideoWithRate: (NSInteger) rate {
	if(self.playerItem) {
		if([self.playerItem canPlayFastReverse] && self.playerLayer.player.rate) self.playerLayer.player.rate = -rate;
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
	if (self.videoLoading) {
		[self.videoLoadingView removeFromSuperview];
		self.videoLoading = NO;
	}
	self.layer.sublayers = nil;
	[self removePlayerItemObserver];
	self.playerItem = nil;
	self.player = nil;
	self.playerLayer = nil;
	self.mix = nil;
}

-(void) removePlayerItemObserver {
	@try{
		[self.playerItem removeObserver:self forKeyPath:@"status"];
	}@catch(id anException){
		//do nothing, obviously it wasn't attached because an exception was thrown
	}
}

@end