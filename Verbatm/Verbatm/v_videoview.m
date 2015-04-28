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
-(id)initWithFrame:(CGRect)frame andAssets:(NSArray*)videoList
{
    if((self = [super initWithFrame:frame]))
    {
        [self fuseAssets:videoList];
        [self setUpPlayer:self.mix];
    }
    return self;
}


/*This sets up the video player using the fused video assets. The video player is made a sublayer of the videoview*/
-(void)setUpPlayer:(AVMutableComposition*)mix
{    
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithAsset:mix];
    if(playerItem.status == AVPlayerItemStatusFailed) NSLog(@"Playback has failed");
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
    player.muted = YES;
    [player play];
}

/*tells me when the video ends so that I can rewind*/
-(void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
    [self continueVideo];
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
        AVAssetTrack* this_audio_track = [[assetClip tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];
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

/*this function changes the rate at which the video is played. Based on the direction of first translation of the pan gesture. A right translation ie delta_x > 0 means fast forward and vice versa for the left*/
-(void)changeRate
{
    if(self.firstTranslation.x > 0){
        [self fastForwardVideo];
    }else{
        [self rewindVideo];
    }
}

/*Mute the video*/
-(void)mutePlayer
{
    AVPlayerLayer* playerLayer = [self.layer.sublayers firstObject];
    playerLayer.player.muted = YES;
}

/*Enable's the sound on the video*/
-(void)enableSound
{
    AVPlayerLayer* playerLayer = [self.layer.sublayers firstObject];
    playerLayer.player.muted = NO;
    playerLayer.player.volume = 0.5;
}
@end
