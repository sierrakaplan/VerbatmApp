//
//  v_videoview.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "v_videoview.h"

@interface v_videoview()
@property (strong, nonatomic) UIImageView* videoProgressImageView;
@property (strong, nonatomic) NSTimer* timer;
@property (strong, nonatomic) UIButton* play_pauseBtn;
@property (strong, nonatomic) AVMutableComposition* mix;
@property (nonatomic) BOOL showProgressBar;
#define RGB 255,225,255, 0.7
#define PROGR_VIEW_HEIGHT 60
#define PLAY_ICON @"play-button-overlay"
#define PAUSE_ICON @"pause"
#define ICON_SIZE 40
#define LINE_IMAGE @"line"
@end
@implementation v_videoview

-(id)initWithFrame:(CGRect)frame andAssets:(NSArray*)assetList
{
    if((self = [super initWithFrame:frame])){
        [self fuseAssets:assetList];
        [self setUpPlayer:self.mix];
    }
    return self;
}


-(void)setUpPlayer:(AVMutableComposition*)mix
{
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithAsset:mix];
    AVPlayer* player = [AVPlayer playerWithPlayerItem: playerItem];
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[player currentItem]];
    
    // Create an AVPlayerLayer using the player
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = self.bounds;
    playerLayer.videoGravity =  AVLayerVideoGravityResizeAspectFill;
    // Add it to your view's sublayers
    [self.layer addSublayer:playerLayer];
    // You can play/pause using the AVPlayer object
    [player play];
    player.muted = NO;
    player.volume = 1.0;
}

//tells me when the video ends so that I can rewind
-(void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

-(void)fuseAssets:(NSArray*)assetList
{
    self.mix = [AVMutableComposition composition];
    AVMutableCompositionTrack* videoTrack = [self.mix addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack* audioTrack = [self.mix addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime nextClipStartTime = kCMTimeZero;
    NSError* error;
    for(ALAsset* asset in assetList){
        AVURLAsset* assetClip = [AVURLAsset URLAssetWithURL: asset.defaultRepresentation.url options:nil];
        AVAssetTrack* this_video_track = [[assetClip tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        [videoTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, assetClip.duration) ofTrack:this_video_track atTime:nextClipStartTime error: &error];
        AVAssetTrack* this_audio_track = [[assetClip tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];
        if(this_audio_track != nil){
            [audioTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, assetClip.duration) ofTrack:this_audio_track atTime:nextClipStartTime error:&error];
        }
        NSLog(@"%@ error", error);
        nextClipStartTime = CMTimeAdd(nextClipStartTime, assetClip.duration);
    }
}

#pragma mark - showing the progess bar-

-(void)showVideoProgressBar
{
    self.showProgressBar = YES;
    [self setUpPlayAndPauseButtons];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(createVideoProgressLine) userInfo:nil repeats:YES];
}

#pragma mark - manipulating playing of videos -

-(void)setUpPlayAndPauseButtons
{
    self.videoProgressImageView = [[UIImageView alloc] init];
    [self addSubview: self.videoProgressImageView];
    self.videoProgressImageView.frame = CGRectMake(0, self.frame.size.height - PROGR_VIEW_HEIGHT, self.frame.size.width, PROGR_VIEW_HEIGHT);
    [self.videoProgressImageView setImage: [UIImage imageNamed: LINE_IMAGE]];
    self.play_pauseBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [self.play_pauseBtn setImage:[UIImage imageNamed:PAUSE_ICON] forState:UIControlStateNormal];
    [self.play_pauseBtn setFrame:CGRectMake(ICON_SIZE/2,(PROGR_VIEW_HEIGHT-ICON_SIZE)/2,ICON_SIZE, ICON_SIZE)];
    [self.play_pauseBtn addTarget:self action:@selector(pauseVideo) forControlEvents:UIControlEventTouchUpInside];
    self.videoProgressImageView.userInteractionEnabled = YES;
    [self.videoProgressImageView addSubview: self.play_pauseBtn];
}

-(void)pauseVideo
{
    AVPlayerLayer* playerLayer = [self.layer.sublayers firstObject];
    AVPlayer* player = playerLayer.player;
    [player pause];
    if(self.showProgressBar)[self.timer invalidate];
    [self.play_pauseBtn setImage:[UIImage imageNamed:PLAY_ICON] forState:UIControlStateNormal];
    [self.play_pauseBtn addTarget:self action:@selector(continueVideo) forControlEvents:UIControlEventTouchUpInside];
}

-(void)continueVideo
{
    AVPlayerLayer* playerLayer = [self.layer.sublayers firstObject];
    AVPlayer* player = playerLayer.player;
    [player play];
    if(self.showProgressBar)[NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(createVideoProgressLine) userInfo:nil repeats:YES];
    [self.play_pauseBtn setImage:[UIImage imageNamed:PAUSE_ICON] forState:UIControlStateNormal];
    [self.play_pauseBtn addTarget:self action:@selector(pauseVideo) forControlEvents:UIControlEventTouchUpInside];
}

-(void)createVideoProgressLine
{
    AVPlayer* player = ((AVPlayerLayer*)[self.layer.sublayers firstObject]).player;
    CMTime duration = player.currentItem.duration;
    CMTime currentTime = player.currentItem.currentTime;
    float fraction_completed = CMTimeGetSeconds(currentTime)/CMTimeGetSeconds(duration);
    CGPoint center = CGPointMake(ICON_SIZE/2 + fraction_completed*(self.videoProgressImageView.frame.size.width - ICON_SIZE) ,PROGR_VIEW_HEIGHT/2);
    self.play_pauseBtn.center = center;
}
@end
