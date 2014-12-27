//
//  v_videoview.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "v_videoview.h"

@interface v_videoview()
@property (strong, nonatomic) UIImageView* videoProgressImageView;  //Kept because of the snake....will be implemented soon
@property (strong, nonatomic) UIButton* play_pauseBtn;
@property (strong, nonatomic) AVMutableComposition* mix;
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
@implementation v_videoview

//no seeking. Fast forward and rewind.
//play and pause button that doesn't move on the side.
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
    player.volume = 1.0;
    [player play];
}

//tells me when the video ends so that I can rewind
-(void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
    [self continueVideo];
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
        nextClipStartTime = CMTimeAdd(nextClipStartTime, assetClip.duration);
    }
}

#pragma mark - showing the progess bar-

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
    AVPlayerLayer* playerLayer = [self.layer.sublayers firstObject];
    AVPlayer* player = playerLayer.player;
    [player pause];
    [self showPlayIcon];
}

-(void)continueVideo
{
    AVPlayerLayer* playerLayer = [self.layer.sublayers firstObject];
    AVPlayer* player = playerLayer.player;
    player.rate = 1;
    [player play];
    [self.play_pauseBtn setImage:[UIImage imageNamed:PAUSE_ICON] forState:UIControlStateNormal];
    [self.play_pauseBtn addTarget:self action:@selector(pauseVideo) forControlEvents:UIControlEventTouchUpInside];
}

-(void)fastForwardVideo
{
    AVPlayerLayer* playerLayer = [self.layer.sublayers firstObject];
    AVPlayerItem* playerItem = playerLayer.player.currentItem;
    [self showPlayIcon];
    if([playerItem canPlayFastForward]) playerLayer.player.rate = MAX_VD_RATE;
}

-(void)rewindVideo
{
    AVPlayerLayer* playerLayer = [self.layer.sublayers firstObject];
    AVPlayerItem* playerItem = playerLayer.player.currentItem;
    [self showPlayIcon];
    if([playerItem canPlayFastReverse] && playerLayer.player.rate) playerLayer.player.rate = -MAX_VD_RATE;
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

-(void)changeRate
{
    if(self.firstTranslation.x > 0){
        [self fastForwardVideo];
    }else{
        [self rewindVideo];
    }
}
@end
