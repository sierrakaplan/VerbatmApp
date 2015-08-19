//
//  VideoPlayer.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/10/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "VideoPlayerView.h"

@interface VideoPlayerView()
@property (nonatomic, strong) UIButton * muteButton;
@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) AVPlayerItem* playerItem;
@property (nonatomic,strong) AVPlayerLayer* playerLayer;
//will hold the actual video layer so that we can add a mute button without layer issues
@property (nonatomic) BOOL repeatsVideo;
@property (nonatomic) BOOL isMuted;
@property (strong, nonatomic) AVMutableComposition* mix;


#define MUTE_BUTTON_X 10
#define MUTE_BUTTON_Y 10
#define MUTE_BUTTON_WH 40
#define MUTE_BUTTON_IMAGE @"mute_2"

#define UNMUTE_BUTTON_IMAGE @"unmuted_2"

@end

@implementation VideoPlayerView

-(instancetype)init {
	if((self  = [super init])) {
		self.repeatsVideo = NO;
        self.isMuted = NO;
	}
	return self;
}




//lazy instantiation of mute button
-(UIButton *)muteButton{
    if(!_muteButton){
        _muteButton = [[UIButton alloc] init];
    }
    return _muteButton;
}


-(void)muteButtonTouched:(id)sender{
    
    if(self.isMuted){
        [self unmuteVideo];
        self.isMuted = false;
        //set mute image on so the know to mute
        [self.muteButton setImage:[UIImage imageNamed:MUTE_BUTTON_IMAGE] forState:UIControlStateNormal];
    }else{
        [self muteVideo];
        self.isMuted = true;
        //set the unmute image on so they know how to unmute
        [self.muteButton  setImage:[UIImage imageNamed:UNMUTE_BUTTON_IMAGE] forState:UIControlStateNormal];
    }
}

//make sure the sublayer resizes with the view screen
- (void)layoutSubviews {
	if (self.playerLayer) {
		self.playerLayer.frame = self.bounds;
	}
}


-(void)playVideoFromURL: (NSURL*) url {
	if (url) {
		[self setPlayerItemFromPlayerItem:[AVPlayerItem playerItemWithURL:url]];
		[self playVideo];
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
			//DISABLE THE UIACTIVITY INDICATOR HERE
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
	
    
    //right when we create the video we also add the mute button
    [self setButtonFormats];
    [self addSubview:self.muteButton];
    // Add it to your view's sublayers
	[self.layer insertSublayer:self.playerLayer below:self.muteButton.layer];
	[self.player play];
}

-(void)setButtonFormats {
    self.muteButton.frame = CGRectMake(MUTE_BUTTON_X, MUTE_BUTTON_Y, MUTE_BUTTON_WH, MUTE_BUTTON_WH);
    [self.muteButton setImage:[UIImage imageNamed:@"mute_2"] forState:UIControlStateNormal];
    [self.muteButton addTarget:self action:@selector(muteButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
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

//cleans up video and all other helper objects
//this is called right before the view is removed from the screen
-(void) stopVideo {
	[self removePlayerItemObserver];
    [self.muteButton removeFromSuperview];
    [self.playerLayer removeFromSuperlayer];
    self.layer.sublayers = nil;
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