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
@property (nonatomic, strong) UIButton * muteButton;
@property (atomic, strong) AVPlayer* player;
@property (atomic, strong) AVPlayerItem* playerItem;
@property (atomic,strong) AVPlayerLayer* playerLayer;
//will hold the actual video layer so that we can add a mute button without layer issues
@property (nonatomic) BOOL repeatsVideo;
@property (nonatomic) BOOL isMuted;
@property (strong, atomic) AVMutableComposition* mix;
@property (nonatomic) BOOL videoLoading;
@property (strong, nonatomic) UIImageView* videoLoadingImageView;
@property (nonatomic) BOOL isVideoPlaying; //tells you if the video is in a playing state
@property (strong, atomic) NSTimer * ourTimer;//keeps calling continue


#define MUTE_BUTTON_SIZE 30
#define MUTE_BUTTON_OFFSET 10

#define VIDEO_LOADING_ICON_SIZE 50

@end

@implementation VideoPlayerView

-(instancetype)initWithFrame:(CGRect)frame {
	if((self  = [super initWithFrame:frame])) {
		self.repeatsVideo = NO;
		self.videoLoading = NO;
        self.clearsContextBeforeDrawing = YES;
        self.playAtEndOfAsynchronousSetup = NO;
		[self setBackgroundColor:[UIColor blackColor]];
	}
	return self;
}

//make sure the sublayer resizes with the view screen
- (void)layoutSubviews {
	if (self.playerLayer) {
		self.playerLayer.frame = self.bounds;
        self.muteButton.frame = CGRectMake(MUTE_BUTTON_OFFSET, self.frame.size.height -  (MUTE_BUTTON_OFFSET + MUTE_BUTTON_SIZE), MUTE_BUTTON_SIZE, MUTE_BUTTON_SIZE);
	}
}

#pragma mark - Format subviews -

-(void)formatMuteButton {
	self.muteButton.frame = CGRectMake(MUTE_BUTTON_OFFSET, MUTE_BUTTON_OFFSET, MUTE_BUTTON_SIZE, MUTE_BUTTON_SIZE);
	[self.muteButton setImage:[UIImage imageNamed:UNMUTED_ICON] forState:UIControlStateNormal];
	[self.muteButton addTarget:self action:@selector(muteButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Prepare array of videos -

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
	}else if (videoList.count == 1){
		[self prepareVideoFromAsset_synchronous:videoList[0]];
	}
}

-(void)prepareVideoFromArrayOfURL_synchronous: (NSArray*)videoList {
	if(videoList.count > 1){
		if(!self.mix){
			[self fuseAssets:videoList];
		}
		[self prepareVideoFromAsset_synchronous:self.mix];
	}else{
		[self prepareVideoFromURL_synchronous:videoList[0]];
	}
}

-(void)prepareVideoFromURLArray_asynchronouse: (NSArray*) urlArray {
	if (!self.videoLoading) {
		self.videoLoading = YES;
		[self addSubview:self.videoLoadingImageView];
	}

    if(urlArray.count == 0) return;
    if (urlArray.count > 1) {
        [self prepareVideoFromArrayOfAssets_asynchronous:urlArray];
        return;
    } else {
        [self prepareVideoFromURL_synchronous:urlArray[0]];
    }
}

#pragma mark - Prepare video (asset or url) -

-(void)prepareVideoFromAsset_synchronous: (AVAsset*) asset{
	if (!self.videoLoading) {
		self.videoLoading = YES;
		[self addSubview:self.videoLoadingImageView];
	}

	if (asset) {
		[self setPlayerItemFromPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
        [self initiateVideo];
	}
}

-(void)prepareVideoFromURL_synchronous: (NSURL*) url{
	if (!self.videoLoading) {
		self.videoLoading = YES;
		[self addSubview:self.videoLoadingImageView];
	}

    if (url) {
        [self setPlayerItemFromPlayerItem:[AVPlayerItem playerItemWithURL: url]];
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

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(playerItemDidStall:)
												 name:AVPlayerItemPlaybackStalledNotification
											   object:self.playerItem];

}

#pragma mark - Observe player item status -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context {
	if (object == self.playerItem && [keyPath isEqualToString:@"status"]) {
		if (self.playerItem.status == AVPlayerStatusReadyToPlay) {
//			NSLog(@"Video ready to play");
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

/*This code fuses the video assets into a single video that plays the videos one after the other.
 It accepts both avassets and urls which it converts into assets
 */
-(void)fuseAssets:(NSArray*)videoList {
	//if the mix exists don't runt this expensive function
	if(self.mix)return;

	self.mix = [AVMutableComposition composition]; //create a composition to hold the joined assets
	AVMutableCompositionTrack* videoTrack = [self.mix addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
	AVMutableCompositionTrack* audioTrack = [self.mix addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
	CMTime nextClipStartTime = kCMTimeZero;
	NSError* error;
	for(id asset in videoList) {
		AVURLAsset * videoAsset;
		if([asset isKindOfClass:[NSURL class]]){
			videoAsset = [AVURLAsset assetWithURL:asset];

		} else {
			videoAsset = asset;
		}
		NSArray * videoTrackArray = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
		if(!videoTrackArray.count) continue;

		AVAssetTrack* currentVideoTrack = [videoTrackArray objectAtIndex:0];
		[videoTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:currentVideoTrack atTime:nextClipStartTime error: &error];
		videoTrack.preferredTransform = currentVideoTrack.preferredTransform;
		

		NSArray * audioTrackArray = [videoAsset tracksWithMediaType:AVMediaTypeAudio];
		if(!audioTrackArray.count) continue;
		AVAssetTrack* currentAudioTrack = [audioTrackArray objectAtIndex:0];
		audioTrack.preferredTransform = currentAudioTrack.preferredTransform;
		[audioTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:currentAudioTrack atTime:nextClipStartTime error:&error];
        
        nextClipStartTime = CMTimeAdd(nextClipStartTime, videoAsset.duration);
	}
	if (error) {
		NSLog(@"Error fusing video assets: %@", error.description);
	}
}

#pragma mark - Play video -

-(void)playVideo{
    if(self.player){
        [self.player play];
        self.isVideoPlaying = YES;
    }
}

//this function should be called on the main thread
-(void) initiateVideo {
	if (self.isPlaying) {
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
    // Add it to your view's sublayers
    [self.layer insertSublayer:self.playerLayer below:self.muteButton.layer];
     if(self.playAtEndOfAsynchronousSetup){
         [self playVideo];
         self.playAtEndOfAsynchronousSetup = NO;
     }
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

-(void)playerItemDidStall:(NSNotification*)notification {
	NSLog(@"Video stalled");
	if(self.isVideoPlaying)[self continueVideo];
}

//pauses the video for the pinchview if there is one
-(void)pauseVideo {
	[self removePlayerItemObserver];
	if (self.player) {
		[self.player pause];
	}
    self.isVideoPlaying = NO;
}

//plays the video of the pinch view if there is one
-(void)continueVideo {
	if (self.player) {
		[self.player play];
	}
    self.isVideoPlaying = YES;
}

-(BOOL) isPlaying {
	if(self.player.rate > 0) {
		return YES;
	} else {
		return NO;
	}
}

#pragma mark - Mute -

-(void)removeMuteButtonFromView{
	[self.muteButton removeFromSuperview];
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
		[self.muteButton setImage:[UIImage imageNamed:UNMUTED_ICON] forState:UIControlStateNormal];
	}else{
		[self muteVideo];
		self.isMuted = true;
		//set the unmute image on so they know how to unmute
		[self.muteButton  setImage:[UIImage imageNamed:MUTED_ICON] forState:UIControlStateNormal];
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

@end