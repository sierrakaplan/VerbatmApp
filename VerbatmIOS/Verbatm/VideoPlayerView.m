//
//  VideoPlayer.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/10/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "VideoPlayerView.h"
#import "VideoDownloadManager.h"
#import "LoadingIndicator.h"
#import "Icons.h"
#import "SizesAndPositions.h"

@interface VideoPlayerView()

#pragma mark AVPlayer properties
@property (atomic, strong) AVPlayer* player;
@property (atomic, strong) AVPlayerItem* playerItem;
@property (atomic,strong) AVPlayerLayer* playerLayer;
@property (strong, readwrite) AVMutableComposition* fusedVideoAsset;

#pragma mark Video Playback properties
@property (nonatomic, readwrite) BOOL videoLoading;
@property (nonatomic, readwrite) BOOL isMuted;
@property (nonatomic, readwrite) BOOL isVideoPlaying; //tells you if the video is in a playing state
@property (strong, atomic) NSTimer *ourTimer;//keeps calling continue

@property (nonatomic) BOOL shouldPlayOnLoad;

@property (strong, nonatomic) id playbackLikelyToKeepUpKVOToken;

@property (nonatomic) LoadingIndicator *customActivityIndicator;


#define VIDEO_LOADING_ICON_SIZE 50

@end

@implementation VideoPlayerView

-(instancetype)initWithFrame:(CGRect)frame {
	if((self  = [super initWithFrame:frame])) {
		self.fusedVideoAsset = nil;
		self.repeatsVideo = NO;
		self.videoLoading = NO;
		self.shouldPlayOnLoad = NO;
		self.clearsContextBeforeDrawing = YES;
		self.isMuted = false;
		[self setBackgroundColor:[UIColor clearColor]];

	}
	return self;
}

#pragma mark - Format subviews -

//make sure the sublayer resizes with the view screen
- (void)layoutSubviews {
	if (self.playerLayer) {
		self.playerLayer.frame = self.bounds;
	}
}

#pragma mark - Prepare Video Asset -

-(void)prepareVideoFromAsset: (AVAsset*) asset{
	if (!asset) return;

	if (!self.videoLoading) {
		self.videoLoading = YES;
	}

//	NSArray *keys = @[@"playable",@"tracks",@"duration"];
//
//	[asset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {
//		[self prepareVideoFromPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
//	}];

	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);

	dispatch_async(queue, ^{
		AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];

		dispatch_sync(dispatch_get_main_queue(), ^{
			[self prepareVideoFromPlayerItem:item];
		});
	});
}

-(void)prepareVideoFromURL: (NSURL*) url{
	if (!url) return;

	if (!self.videoLoading) {
		self.videoLoading = YES;
	}

	AVPlayerItem *playerItem;
	if([[VideoDownloadManager sharedInstance] containsEntryForUrl:url]){
		playerItem = [[VideoDownloadManager sharedInstance] getVideoForUrl: url.absoluteString];
	}else {
		//todo: test this
		[self prepareVideoFromAsset:[AVAsset assetWithURL: url]];
		return;
//		playerItem = [AVPlayerItem playerItemWithURL: url];
	}

	[self prepareVideoFromPlayerItem: playerItem];
}

-(void) prepareVideoFromPlayerItem:(AVPlayerItem*)playerItem {
	if (!self.videoLoading) {
		self.videoLoading = YES;
	}
	if (self.playerItem) {
		[self removePlayerItemObservers];
	}
	self.playerItem = playerItem;
	[self initiateVideo];
	[self.playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
	[self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:0 context:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(playerItemDidReachEnd:)
												 name:AVPlayerItemDidPlayToEndTimeNotification
											   object:self.playerItem];

//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(playerItemDidStall:)
//												 name:AVPlayerItemPlaybackStalledNotification
//											   object:self.playerItem];
}

//this function should be called on the main thread
-(void) initiateVideo {
	if (self.isVideoPlaying) {
		return;
	}
	if (self.playerItem == NULL) {

	}
	//todo background thread
	self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
	self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
	// Create an AVPlayerLayer using the player
	if(self.playerLayer)[self.playerLayer removeFromSuperlayer];
	self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
	self.playerLayer.frame = self.bounds;
	self.playerLayer.videoGravity =  AVLayerVideoGravityResizeAspectFill;
	[self.playerLayer removeAllAnimations];

	self.player.muted = self.isMuted;

	if(![NSThread isMainThread]){
		dispatch_async(dispatch_get_main_queue(), ^{
			[self presentNewLayers];
		});
	} else {
		[self presentNewLayers];
	}
	if (self.shouldPlayOnLoad) [self playVideo];
}

-(void)presentNewLayers{
	// Add it to your view's sublayers
	if(self.playerLayer)[self.layer addSublayer:self.playerLayer];
	if(self.customActivityIndicator)[self.customActivityIndicator startCustomActivityIndicator];
}

#pragma mark - Observe player item status -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context {
	if (object == self.playerItem && [keyPath isEqualToString:@"status"]) {
		if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
			if (self.videoLoading) {
				[self.customActivityIndicator stopCustomActivityIndicator];
				self.videoLoading = NO;
			}
			if (self.shouldPlayOnLoad) [self playVideo];
		} else if (self.playerItem.status == AVPlayerItemStatusFailed) {
			NSLog(@"video couldn't play: %@", self.playerItem.error);
			if (self.videoLoading) {
				[self.customActivityIndicator stopCustomActivityIndicator];
				self.videoLoading = NO;
			}
		}
	}
	if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
		if (self.playerItem.playbackLikelyToKeepUp) {
			if (self.videoLoading) {
				[self.customActivityIndicator stopCustomActivityIndicator];
				self.videoLoading = NO;
			}
			if (self.shouldPlayOnLoad) [self playVideo];
			self.shouldPlayOnLoad = NO;
		} else {
			[self.customActivityIndicator startCustomActivityIndicator];
			self.videoLoading = YES;
			self.shouldPlayOnLoad = YES;
			NSLog(@"play back won't keep up");
		}
	}
}

#pragma mark - Play video -

-(void)playVideo {
	if (self.player) {
		[self.player play];
		self.isVideoPlaying = YES;
	} else {
		self.shouldPlayOnLoad = YES;
	}
}

// Notifies that video has ended so video can replay
-(void)playerItemDidReachEnd:(NSNotification *)notification {
	AVPlayerItem *playerItem = [notification object];
	if (self.repeatsVideo) {
		[playerItem seekToTime:kCMTimeZero];
	}
}

// Pauses player
-(void)pauseVideo {
	[self removePlayerItemObservers];
	if (self.player) {
		[self.player pause];
	}
	self.isVideoPlaying = NO;
}

#pragma mark - Mute / Unmute -

-(void) muteVideo: (BOOL)mute {
	if(self.player) {
		[self.player setMuted:mute];
	}
	self.isMuted = mute;
}

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
		[self.customActivityIndicator stopCustomActivityIndicator];

		for (UIView* view in self.subviews) {
			[view removeFromSuperview];
		}
		@autoreleasepool {
			[self removePlayerItemObservers];
			for (CALayer *sublayer in self.layer.sublayers) {
				[sublayer removeFromSuperlayer];
			}
			[self.playerLayer removeFromSuperlayer];
			self.playerItem = nil;
			self.player = nil;
			self.playerLayer = nil;
			self.isVideoPlaying = NO;
			[self.ourTimer invalidate];
			self.ourTimer = nil;
			self.shouldPlayOnLoad = NO;
		}
	}
}

-(void) removePlayerItemObservers {
	@try {
		[self.playerItem removeObserver:self forKeyPath:@"status"];
		[self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
	} @catch(id anException){
		//do nothing, obviously they weren't attached because an exception was thrown
	}
}

#pragma mark - Lazy Instantation -

-(LoadingIndicator *) customActivityIndicator{
	if(!_customActivityIndicator){
		_customActivityIndicator = [[LoadingIndicator alloc] initWithCenter:self.center andImage:[UIImage imageNamed:VIDEO_LOADING_ICON]];
		[self addSubview:_customActivityIndicator];
	}
	[self bringSubviewToFront:_customActivityIndicator];
	return _customActivityIndicator;
}

@end