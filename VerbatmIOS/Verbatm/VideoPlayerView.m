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

#pragma mark Subviews
@property (nonatomic, strong) UIButton * muteButton;
@property (strong, nonatomic) UIImageView* videoLoadingImageView;

#pragma mark Video Playback properties
@property (nonatomic) BOOL playVideoAfterLoading;
@property (nonatomic, readwrite) BOOL videoLoading;
@property (nonatomic, readwrite) BOOL isMuted;
@property (nonatomic, readwrite) BOOL isVideoPlaying; //tells you if the video is in a playing state
@property (strong, atomic) NSTimer * ourTimer;//keeps calling continue

@property (strong, nonatomic) id playbackLikelyToKeepUpKVOToken;

@property (nonatomic) LoadingIndicator * customActivityIndicator;


#define VIDEO_LOADING_ICON_SIZE 50

@end

@implementation VideoPlayerView

-(instancetype)initWithFrame:(CGRect)frame {
    if((self  = [super initWithFrame:frame])) {
        self.repeatsVideo = NO;
        self.videoLoading = NO;
        self.clearsContextBeforeDrawing = YES;
        self.playAtEndOfAsynchronousSetup = NO;
        self.isMuted = false;
        [self setBackgroundColor:[UIColor clearColor]];
        
    }
    return self;
}



//make sure the sublayer resizes with the view screen
- (void)layoutSubviews {
    if (self.playerLayer) {
        self.playerLayer.frame = self.bounds;
        self.muteButton.frame = CGRectMake(MUTE_BUTTON_OFFSET,
                                           self.bounds.size.height - (MUTE_BUTTON_OFFSET + MUTE_BUTTON_SIZE),
                                           MUTE_BUTTON_SIZE,
                                           MUTE_BUTTON_SIZE);
        
    }

}

-(void)prepareVideoFromURLArray_asynchronouse: (NSArray*) urlArray {
    if (!self.videoLoading) {
        self.videoLoading = YES;
    }
    
    if(urlArray.count == 0) return;
    if (urlArray.count > 1) {
        [self prepareVideoFromArrayOfAssets_asynchronous:urlArray];
        return;
    } else {
        [self prepareVideoFromURL_synchronous:urlArray[0]];
    }
}

-(void)prepareVideoFromAsset_synchronous: (AVAsset*) asset{
    if (!self.videoLoading) {
        self.videoLoading = YES;
    }
    
    if (asset) {
        [self setPlayerItemFromPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
        [self initiateVideo];
    }
}

#pragma mark - Format subviews -

-(void)formatMuteButton {
	self.muteButton.frame = CGRectMake(MUTE_BUTTON_OFFSET, MUTE_BUTTON_OFFSET, MUTE_BUTTON_SIZE, MUTE_BUTTON_SIZE);
	[self.muteButton setImage:[UIImage imageNamed:UNMUTED_ICON] forState:UIControlStateNormal];
	[self.muteButton addTarget:self action:@selector(muteButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)prepareVideoFromURL_synchronous: (NSURL*) url{
    if (!self.videoLoading) {
        self.videoLoading = YES;
    }

    if (url) {
        self.urlArray = @[url];
        AVPlayerItem * pItem;
        if([[VideoDownloadManager sharedInstance] containsEntryForUrl:url]){
        
             pItem = [[VideoDownloadManager sharedInstance] getVideoForUrl:url.absoluteString];
        }else{
            pItem = [AVPlayerItem playerItemWithURL: url];
        }
        
        [self setPlayerItemFromPlayerItem:pItem];
        [self initiateVideo];
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
                self.videoLoading = NO;
            }
        } else if (self.playerItem.status == AVPlayerStatusFailed) {
            NSLog(@"video couldn't play: %@", self.player.error);
            if (self.videoLoading) {
                self.videoLoading = NO;
            }
        }
    }
    
        if ([self.player rate] > 0.f) //If it started playing
        {
           [self.customActivityIndicator stopCustomActivityIndicator];
        }else if([self.player rate] == 0.f){
            [self.customActivityIndicator startCustomActivityIndicator];
        }
}

-(void) prepareVideoFromArrayOfAssets_asynchronous: (NSArray*)videoList {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        if(videoList.count > 1){
            if(!_mix){
                [self fuseAssets:videoList];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self prepareVideoFromAsset_synchronous:self.mix];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self prepareVideoFromAsset_synchronous:videoList[0]];
            });
        }
    });    
}


//this is used rarely when we need to load and play a view and it
//doesn't give our code a chance to be prepared
-(void)prepareVideoFromArrayOfAssets_synchronous: (NSArray*)videoList {
    if(videoList.count > 1){
        if(!self.mix){
            [self fuseAssets:videoList];
        }
        [self prepareVideoFromAsset_synchronous:self.mix];
    }else{
        [self prepareVideoFromAsset_synchronous:videoList[0]];
    }
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
	[self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:0 context:nil];

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
    if (self.isPlaying) {
        return;
    }
    if(self.player){
        [self removePlayerRateObserver];
    }
    
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
    }else{
        [self presentNewLayers];
    }
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
			NSLog(@"Video ready to play");
			if (self.videoLoading) {
				self.videoLoading = NO;
				self.videoLoadingImageView.hidden = YES;
			}
		} else if (self.playerItem.status == AVPlayerItemStatusFailed) {
			NSLog(@"video couldn't play: %@", self.playerItem.error);
			if (self.videoLoading) {
				self.videoLoading = NO;
				self.videoLoadingImageView.hidden = YES;
			}
		}
	}
	if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
		if (self.playerItem.playbackLikelyToKeepUp) {
			NSLog(@"play back will keep up");
			self.videoLoadingImageView.hidden = YES;
			[self playVideo];
		} else {
			NSLog(@"play back won't keep up");
			self.videoLoadingImageView.hidden = NO;
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
	NSLog(@"Repeating video");
	AVPlayerItem *playerItem = [notification object];
	if (self.repeatsVideo) {
		[playerItem seekToTime:kCMTimeZero];
	}
}

// Telling video to play when stalled should not be necessary but seems to be
-(void)playerItemDidStall:(NSNotification*)notification {
	NSLog(@"Video stalled");
	//	if(self.isVideoPlaying) [self playVideo];
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

-(void)unmuteVideo {
    if(self.player) {
        self.isMuted = NO;
        [self.player setMuted:NO];
    }
}

-(void)muteVideo {
    if(self.player) {
        self.isMuted = YES;
        [self.player setMuted:YES];
    }
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
            [self removePlayerItemObserver];
            self.layer.sublayers = nil;
            [self.playerLayer removeFromSuperlayer];
            self.layer.sublayers = nil;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                
                self.muteButton = nil;
                self.playerItem = nil;
                self.player = nil;
                self.playerLayer = nil;
                self.isVideoPlaying = NO;
                [self.ourTimer invalidate];
                self.ourTimer = nil;
                
            }
        });
    }
}

-(void) removePlayerItemObserver {
    @try {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        //[self removePlayerRateObserver];
    } @catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
}

-(void)removePlayerRateObserver{
    @try{
         [self.player removeObserver:self forKeyPath:@"rate"];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
   
}

#pragma mark - Lazy Instantation -

-(LoadingIndicator *)customActivityIndicator{
    if(!_customActivityIndicator){
        _customActivityIndicator = [[LoadingIndicator alloc] initWithCenter:self.center];
        [self addSubview:_customActivityIndicator];
    }
    return _customActivityIndicator;
}

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