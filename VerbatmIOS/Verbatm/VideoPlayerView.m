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

#pragma mark AVPlayer properties
@property (atomic, strong) AVPlayer* player;
@property (atomic, strong) AVPlayerItem* playerItem;
@property (atomic,strong) AVPlayerLayer* playerLayer;

#pragma mark Subviews
@property (nonatomic, strong) UIButton * muteButton;
@property (strong, nonatomic) UIImageView* videoLoadingImageView;

#pragma mark Video Playback properties
@property (nonatomic) BOOL playVideoAfterLoading;
@property (nonatomic, readwrite) BOOL videoLoading;
@property (nonatomic, readwrite) BOOL isMuted;
@property (nonatomic, readwrite) BOOL isVideoPlaying; //tells you if the video is in a playing state
@property (strong, atomic) NSTimer * ourTimer;//keeps calling continue


#define MUTE_BUTTON_SIZE 40
#define MUTE_BUTTON_OFFSET 10

#define VIDEO_LOADING_ICON_SIZE 50

@end

@implementation VideoPlayerView

-(instancetype)initWithFrame:(CGRect)frame {
	if((self  = [super initWithFrame:frame])) {
		self.repeatsVideo = NO;
		self.videoLoading = NO;
		self.playVideoAfterLoading = NO;
		self.clearsContextBeforeDrawing = YES;
		[self setBackgroundColor:[UIColor blackColor]];
	}
	return self;
}

//make sure the sublayer resizes with the view screen
- (void)layoutSubviews {
	if (self.playerLayer) {
		self.playerLayer.frame = self.bounds;
		self.muteButton.frame = CGRectMake(MUTE_BUTTON_OFFSET, MUTE_BUTTON_OFFSET, MUTE_BUTTON_SIZE, MUTE_BUTTON_SIZE);
	}
}

#pragma mark - Format subviews -

-(void)formatMuteButton {
	self.muteButton.frame = CGRectMake(MUTE_BUTTON_OFFSET, MUTE_BUTTON_OFFSET, MUTE_BUTTON_SIZE, MUTE_BUTTON_SIZE);
	[self.muteButton setImage:[UIImage imageNamed:UNMUTED_ICON] forState:UIControlStateNormal];
	[self.muteButton addTarget:self action:@selector(muteButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Prepare array of videos -

-(void)prepareVideoFromArray: (NSArray*) videoList {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!self.videoLoading) {
				self.videoLoading = YES;
				[self addSubview:self.videoLoadingImageView];
			}
		});
		AVMutableComposition* fusedVideoAsset = [self fuseAssets:videoList];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self prepareVideoFromAsset: fusedVideoAsset];
		});
	});
}

-(void)prepareVideoFromAsset: (AVAsset*) asset{
	[self prepareVideoFromPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
}

-(void)prepareVideoFromURL: (NSURL*) url{
	[self prepareVideoFromPlayerItem:[AVPlayerItem playerItemWithURL: url]];
}

-(void) prepareVideoFromPlayerItem:(AVPlayerItem*)playerItem {
	if (!self.videoLoading) {
		self.videoLoading = YES;
		[self addSubview:self.videoLoadingImageView];
	}
	if (self.playerItem) {
		[self removePlayerItemObserver];
	}
	self.playerItem = playerItem;
	[self.playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(playerItemDidReachEnd:)
												 name:AVPlayerItemDidPlayToEndTimeNotification
											   object:self.playerItem];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(playerItemDidStall:)
												 name:AVPlayerItemPlaybackStalledNotification
											   object:self.playerItem];
	[self initiateVideo];
}

//this function should be called on the main thread
-(void) initiateVideo {
	if (self.isVideoPlaying) {
		return;
	}

	self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
	self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
	// Create an AVPlayerLayer using the player
	if(self.playerLayer)[self.playerLayer removeFromSuperlayer];
	self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
	self.playerLayer.frame = self.bounds;
	self.playerLayer.videoGravity =  AVLayerVideoGravityResizeAspectFill;
	[self.playerLayer removeAllAnimations];

	//right when we create the video we also add the mute button
	[self formatMuteButton];
	[self addSubview:self.muteButton];
	[self.layer insertSublayer:self.playerLayer below:self.muteButton.layer];

	if (self.playVideoAfterLoading) {
		[self playVideo];
		self.playVideoAfterLoading = NO;
	}
}

#pragma mark - Observe player item status -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context {
	if (object == self.playerItem && [keyPath isEqualToString:@"status"]) {
		if (self.playerItem.status == AVPlayerStatusReadyToPlay) {
			NSLog(@"Video ready to play");
			if (self.videoLoading) {
				self.videoLoading = NO;
				[self.videoLoadingImageView removeFromSuperview];
			}
		} else if (self.playerItem.status == AVPlayerStatusFailed) {
			NSLog(@"video couldn't play: %@", self.player.error);
			if (self.videoLoading) {
				self.videoLoading = NO;
				[self.videoLoadingImageView removeFromSuperview];
			}
		}
	}
}

#pragma mark - Fuse video assets into one -

//This code fuses the video assets into a single video that plays the videos one after the other.
//It accepts both avassets and urls which it converts into assets
-(AVMutableComposition*) fuseAssets:(NSArray*)videoList {

	AVMutableComposition* fusedVideos = [AVMutableComposition composition]; //create a composition to hold the joined assets
	AVMutableCompositionTrack* videoTrack = [fusedVideos addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
	AVMutableCompositionTrack* audioTrack = [fusedVideos addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
	CMTime nextClipStartTime = kCMTimeZero;
	NSError* error;
	for(id asset in videoList) {
		AVURLAsset * videoAsset;
		if([asset isKindOfClass:[NSURL class]]) {
			videoAsset = [AVURLAsset assetWithURL:asset];
		} else {
			videoAsset = asset;
		}
		NSArray * videoTrackArray = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
		if(!videoTrackArray.count) continue;

		AVAssetTrack* currentVideoTrack = [videoTrackArray objectAtIndex:0];
		[videoTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:currentVideoTrack atTime:nextClipStartTime error: &error];
		videoTrack.preferredTransform = currentVideoTrack.preferredTransform;
		nextClipStartTime = CMTimeAdd(nextClipStartTime, videoAsset.duration);

		NSArray * audioTrackArray = [videoAsset tracksWithMediaType:AVMediaTypeAudio];
		if(!audioTrackArray.count) continue;
		AVAssetTrack* currentAudioTrack = [audioTrackArray objectAtIndex:0];
		audioTrack.preferredTransform = currentAudioTrack.preferredTransform;
		[audioTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:currentAudioTrack atTime:nextClipStartTime error:&error];
	}
	if (error) {
		NSLog(@"Error fusing video assets: %@", error.description);
	}
	return fusedVideos;
}

#pragma mark - Play video -

-(void)playVideo{
	if(self.player){
		[self.player play];
		self.isVideoPlaying = YES;
	} else {
		NSLog(@"Called play video but video player unprepared");
		self.playVideoAfterLoading = YES;
	}
}

// Notifies that video has ended so video can replay
-(void)playerItemDidReachEnd:(NSNotification *)notification {
	AVPlayerItem *playerItem = [notification object];
	if (self.repeatsVideo) {
		[playerItem seekToTime:kCMTimeZero];
	}
}

// Telling video to play when stalled should not be necessary but seems to be
-(void)playerItemDidStall:(NSNotification*)notification {
	NSLog(@"Video stalled");
	if(self.isVideoPlaying) [self playVideo];
}

// Pauses player
-(void)pauseVideo {
	[self removePlayerItemObserver];
	if (self.player) {
		[self.player pause];
	}
	self.isVideoPlaying = NO;
}

#pragma mark - Mute / Unmute -

-(void)muteButtonTouched:(UIButton*)sender {
	[self muteVideo: !self.isMuted];
}

-(void) muteVideo: (BOOL)mute {
	if(self.player) {
		[self.player setMuted:mute];
		self.isMuted = mute;
		if (mute) {
			[self.muteButton  setImage:[UIImage imageNamed:MUTED_ICON] forState:UIControlStateNormal];
		} else {
			[self.muteButton setImage:[UIImage imageNamed:UNMUTED_ICON] forState:UIControlStateNormal];
		}
	}
}

#pragma mark - Fast forward / rewind -

-(void)fastForwardVideoWithRate: (NSInteger) rate{
	if(self.playerItem) {
		if([self.playerItem canPlayFastForward]) self.playerLayer.player.rate = rate;
	}
}

-(void)rewindVideoWithRate:(NSInteger) rate {
	if(self.playerItem) {
		if([self.playerItem canPlayFastReverse] && self.playerLayer.player.rate) self.playerLayer.player.rate = -rate;
	}
}

#pragma mark - Clean up video assets -

//cleans up video and all other helper objects
//this is called right before the view is removed from the screen
-(void) stopVideo {
	@autoreleasepool {
		if (self.videoLoading) {
			self.videoLoading = NO;
		}

		for (UIView* view in self.subviews) {
			[view removeFromSuperview];
		}

		self.layer.sublayers = nil;
		[self removePlayerItemObserver];
		[self.playerLayer removeFromSuperlayer];
		self.layer.sublayers = nil;
		self.muteButton = nil;
		self.playerItem = nil;
		self.player = nil;
		self.playerLayer = nil;
		self.isVideoPlaying = NO;
		[self.ourTimer invalidate];
		self.ourTimer = nil;
	}
}

-(void)removeMuteButtonFromView{
	[self.muteButton removeFromSuperview];
}

-(void) removePlayerItemObserver {
	@try{
		[self.playerItem removeObserver:self forKeyPath:@"status"];
	}@catch(id anException){
		//do nothing, obviously it wasn't attached because an exception was thrown
	}
}

#pragma mark - Lazy Instantation -

-(UIImageView*) videoLoadingImageView {
	if (!_videoLoadingImageView) {
		_videoLoadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:VIDEO_LOADING_ICON]];
		_videoLoadingImageView.frame = CGRectMake(0, self.frame.size.height/2.f - VIDEO_LOADING_ICON_SIZE/2.f,
												  self.frame.size.width, VIDEO_LOADING_ICON_SIZE);
		_videoLoadingImageView.contentMode = UIViewContentModeScaleAspectFit;
	}
	return _videoLoadingImageView;
}

-(UIButton *)muteButton{
	if(!_muteButton){
		_muteButton = [[UIButton alloc] init];
	}
	return _muteButton;
}

@end