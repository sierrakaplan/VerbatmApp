//
//  v_videoview.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "VideoAVE.h"

@interface VideoAVE()
@property (strong, nonatomic) UIImageView* videoProgressImageView;  //Kept because of the snake....will be implemented soon
@property (strong, nonatomic) UIButton* play_pauseBtn;
@property (strong, nonatomic) AVMutableComposition* mix;
@property(nonatomic, strong)MPMoviePlayerController *moviePlayer;
@property (nonatomic,strong) AVPlayerViewController * mixPlayer;
@property (nonatomic,strong) AVPlayerLayer * playerLayer;
@property (nonatomic) CGPoint firstTranslation;
#define RGB 255,225,255, 0.7
#define PROGR_VIEW_HEIGHT 60
#define PLAY_ICON @"play"
#define PAUSE_ICON @"pause"
#define ICON_SIZE 40
#define LINE_IMAGE @"line"
#define MAX_VD_RATE 2
#define PLY_PSE_FRAME self.frame.origin.x, self.frame.origin.y + self.frame.size.height - 50, 50,50
@end
@implementation VideoAVE

//no seeking. Fast forward and rewind.
//play and pause button that doesn't move on the side.
-(id)initWithFrame:(CGRect)frame andAssets:(NSArray*)videoList
{
    if((self = [super initWithFrame:frame]))
    {
        if(videoList.count)
        {
            [self fuseAssets:videoList];
            [self setUpPlayer:self.mix];
        }
        self.playerLayer = NULL;
        for (CALayer * obj in self.layer.sublayers)
        {
            if([obj isKindOfClass:[AVPlayerLayer class]])
            {
                self.playerLayer = (AVPlayerLayer *)obj;
            }
        }
    }
    return self;
}



-(void)playVideos:(NSArray*)videoList
{
    [self fuseAssets:videoList];
    [self setUpPlayer:self.mix];
}


/*This sets up the video player using the fused video assets. The video player is made a sublayer of the videoview*/
-(void)setUpPlayer:(AVMutableComposition*)mix
{
    self.mixPlayer = [[AVPlayerViewController alloc] init];
    AVPlayerItem *newplayerItem = [AVPlayerItem playerItemWithAsset:mix];
    //make an immutable copy of the mutableComposition
    AVPlayer *newplayer = [AVPlayer playerWithPlayerItem:newplayerItem];
    
    newplayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[newplayer currentItem]];
    self.mixPlayer.showsPlaybackControls = NO;
    self.mixPlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.mixPlayer setPlayer:newplayer];
    [self.mixPlayer.view setFrame:self.bounds];
    [self addSubview:self.mixPlayer.view];
    [self.mixPlayer.player play];
}





//tells me when the video ends so that I can rewind
-(void)playerItemDidReachEnd:(NSNotification *)notification
{
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}



/*This code fuses the video assets into a single video that plays the videos one after the other*/
-(void)fuseAssets:(NSArray*)videoDataList
{
    
    self.mix = [AVMutableComposition composition]; //create a composition to hold the joined assets
    AVMutableCompositionTrack* videoTrack = [self.mix addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack* audioTrack = [self.mix addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime nextClipStartTime = kCMTimeZero;
    NSError* error;
    for(id data in videoDataList)//we're not sure if we've nbeen given a nsdata or alaasset
    {
        AVURLAsset* assetClip;
        if([data isKindOfClass:[NSData class]])
        {
        
            NSURL* url;
            NSString* filePath = [NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@%u.mov", @"vid", arc4random_uniform(100)]];
            [[NSFileManager defaultManager] createFileAtPath: filePath contents: data attributes:nil];
            url = [NSURL fileURLWithPath: filePath];
            assetClip = [AVURLAsset URLAssetWithURL: url options:nil];
        }else
        {
           assetClip = [AVURLAsset URLAssetWithURL: ((ALAsset *)data).defaultRepresentation.url options:nil];
        }
        //up to here - data-
        
        AVAssetTrack* this_video_track = [[assetClip tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        [videoTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, assetClip.duration) ofTrack:this_video_track atTime:nextClipStartTime error: &error]; //insert the video
        videoTrack.preferredTransform = this_video_track.preferredTransform;
        AVAssetTrack* this_audio_track = [[assetClip tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];
        
        videoTrack.preferredTransform = this_video_track.preferredTransform;

        if(this_audio_track != nil)
        {
            [audioTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, assetClip.duration) ofTrack:this_audio_track atTime:nextClipStartTime error:&error];
        }
        nextClipStartTime = CMTimeAdd(nextClipStartTime, assetClip.duration);
    }
}

#pragma mark - showing the progess bar -
/*This function shows the play and pause icons*/
-(void)showPlayBackIcons
{
    [self setUpPlayAndPauseButtons];
}

#pragma mark - manipulating playing of videos -
-(void)setUpPlayAndPauseButtons
{
    self.play_pauseBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [self.play_pauseBtn setImage:[UIImage imageNamed:PAUSE_ICON] forState:UIControlStateNormal];
    [self.play_pauseBtn setFrame:CGRectMake(PLY_PSE_FRAME)];
    [self.play_pauseBtn addTarget:self action:@selector(pauseVideo) forControlEvents:UIControlEventTouchUpInside];
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(modifyPlayback:)];
    [self addGestureRecognizer:panGesture];
    [self addSubview: self.play_pauseBtn];
}

-(void)pauseVideo
{
    
    return;//No longer in use
    if(self.playerLayer) {
        AVPlayer* player = self.playerLayer.player;
        [player pause];
        [self showPlayIcon];
    }
}

-(void)continueVideo
{
    
    return;//no longer in use
    if(self.playerLayer) {
        AVPlayer* player = self.playerLayer.player;
        player.rate = 1;
        [player play];
        [self.play_pauseBtn setImage:[UIImage imageNamed:PAUSE_ICON] forState:UIControlStateNormal];
        [self.play_pauseBtn addTarget:self action:@selector(pauseVideo) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)fastForwardVideo
{
    if(self.playerLayer) {
        AVPlayerItem* playerItem = self.playerLayer.player.currentItem;
        if([playerItem canPlayFastForward]) self.playerLayer.player.rate = MAX_VD_RATE;
        [self showPlayIcon];
    }
}

-(void)rewindVideo
{
    if(self.playerLayer) {
        AVPlayerItem* playerItem = self.playerLayer.player.currentItem;
        [self showPlayIcon];
        if([playerItem canPlayFastReverse] && self.playerLayer.player.rate) self.playerLayer.player.rate = -MAX_VD_RATE;
    }
}

-(void)showPlayIcon
{
    [self.play_pauseBtn setImage:[UIImage imageNamed:PLAY_ICON] forState:UIControlStateNormal];
    [self.play_pauseBtn addTarget:self action:@selector(continueVideo) forControlEvents:UIControlEventTouchUpInside];
}



/*Allows the user to use a pan gesture to determine rewind or fast forward 
 *Right now just the act of panning causes this. This function does not modify the rate as more panning 
 *occurs. Changes could easily be made to take care of this if that turns out to be what the designers want
 */
-(void)modifyPlayback:(UIPanGestureRecognizer*)sender
{
    CGPoint location = [sender locationInView:self];
    CGRect viableRegion = CGRectMake(self.frame.origin.x + self.frame.size.width/4, self.frame.origin.y, self.frame.size.width/2, self.frame.size.height);
    if(!CGRectContainsPoint(viableRegion, location))return;
    CGPoint translation = [sender translationInView: self];
    if(sender.state == UIGestureRecognizerStateBegan){
        self.firstTranslation = translation;
        [self changeRate];
    }else if(sender.state == UIGestureRecognizerStateEnded){
        self.firstTranslation = CGPointZero;
        [self continueVideo];
    }else{
        if(CGPointEqualToPoint(CGPointZero, self.firstTranslation)){
            self.firstTranslation = translation;
            [self changeRate];
            return;
        }
        BOOL shouldPlayAtNormalRate = (translation.x < 0 &&  self.firstTranslation.x > 0) || (translation.x > 0 &&  self.firstTranslation.x < 0);
        if(shouldPlayAtNormalRate){
            self.firstTranslation = CGPointZero;
            [self continueVideo];
        }
    }
}

/*this function changes the rate at which the video is played. Based on the direction of first translation of the pan gesture. A right translation ie delta_x > 0 means fast forward and vice versa for the left*/
-(void)changeRate
{
    if(self.firstTranslation.x > 0){
        [self fastForwardVideo];
    }else{
        [self rewindVideo];
    }
}

-(void)offScreen
{
    
//    AVPlayerLayer* playerLayer = [self.layer.sublayers firstObject];
//    [playerLayer.player replaceCurrentItemWithPlayerItem:nil];
}

-(void)onScreen
{
    
    
    
//   AVPlayerItem* playerItem = [AVPlayerItem playerItemWithAsset:self.mix];
//    AVPlayerLayer* playerLayer = [self.layer.sublayers firstObject];
//    [playerLayer.player replaceCurrentItemWithPlayerItem:playerItem];
//    [playerLayer.player play];
 //   [self setUpPlayer:self.mix];
}

/*Mute the video*/
-(void)mutePlayer
{
    if(self.mixPlayer)[self.mixPlayer.player pause];
    return;
    if(self.moviePlayer)
    {
        [self.moviePlayer stop];
        return;
    }

    if(self.playerLayer) {
        self.playerLayer.player.muted = YES;
    }
}

/*Enable's the sound on the video*/
-(void)enableSound
{
    if(self.mixPlayer)[self.mixPlayer.player play];
    return;
    
    if(self.moviePlayer)
    {
        [self.moviePlayer play];
        return;
    }
    
    if(self.playerLayer) {
        self.playerLayer.player.muted = NO;
        self.playerLayer.player.volume = 0.5;
    }
}


-(void)stopVideo
{
    if(self.moviePlayer)[self.moviePlayer stop];
}



-(void)playVideo:(AVURLAsset*)asset
{
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:asset.URL];
    [self.moviePlayer prepareToPlay];
    self.moviePlayer.repeatMode = MPMovieRepeatModeOne;
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
    self.moviePlayer.controlStyle= MPMovieControlStyleNone;
    [self.moviePlayer.view setFrame: self.frame];  // player's frame must match parent's
    [self addSubview:self.moviePlayer.view];
    [self.moviePlayer play];

}
@end
