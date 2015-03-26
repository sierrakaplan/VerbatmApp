
//
//  v_multiplePhotoVideo.m
//  tester
//
//  Created by Iain Usiri on 12/20/14.
//  Copyright (c) 2014 IainAndLucio. All rights reserved.
//

#import "v_multiplePhotoVideo.h"
#import "v_videoview.h"

@interface v_multiplePhotoVideo()
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIScrollView *photoList;
@property (strong, nonatomic) AVMutableComposition* mix;

#define x_ratio 3
#define y_ratio 4
#define ELEMENT_WALL_OFFSET 10
#define ANIMATION_DURATION 0.5
#define VIDEO_VIEW_HEIGHT (((self.frame.size.width*3)/4))
#define SV_DEFAULT_HEIGHT (self.frame.size.height - VIDEO_VIEW_HEIGHT)
@end
@implementation v_multiplePhotoVideo

-(id)initWithFrame:(CGRect)frame andMedia:(NSMutableArray*)media
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"multiplePhotoVideoAve" owner:self options:nil]firstObject];
    if(self)
    {
        self.frame = frame;
        [self setViewFrames];
        [self formatScrollView];
        NSMutableArray* vidAssets = [self getVideoAssets:media];
        [self renderPhotos:media andVideos:vidAssets];

        
    }
    return self;
}

//sets the frames for the video view and the photo scrollview
-(void) setViewFrames
{
    self.videoView.frame = CGRectMake(0, 0, self.frame.size.width, VIDEO_VIEW_HEIGHT);
    self.photoList.frame = CGRectMake(0, VIDEO_VIEW_HEIGHT, self.frame.size.width, SV_DEFAULT_HEIGHT);
    [self bringSubviewToFront:self.photoList];
}


/*
 *This function removes the video assets from the provided media array and gives them their own
 */
-(NSMutableArray*)getVideoAssets:(NSMutableArray*)media
{
    NSMutableArray* vids = [[NSMutableArray alloc]init];
    while(YES){
        ALAsset* asset = (ALAsset*)[media firstObject];
        if([[asset valueForProperty: ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
            [media removeObject:asset];
            [vids addObject:asset];
        }else{
            break;
        }
    }
    return vids;
}


-(void)renderPhotos:(NSMutableArray*)photos andVideos:(NSMutableArray*)videos
{
    
    
    //set up the video
    [self fuseAssets:videos];
    [self setUpPlayer:self.mix];
    
    //set up the photos
    for (ALAsset * asset in photos)
    {
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        UIImage *image = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage]
                                             scale:[assetRepresentation scale]
                                       orientation:UIImageOrientationUp];
        UIImageView * imageview = [[UIImageView alloc] init];
        imageview.frame = [self getNextFrame];
        imageview.image = image;
        imageview.clipsToBounds = YES;
        imageview.contentMode = UIViewContentModeScaleAspectFit;
        [self.photoList addSubview:imageview];
    }
    //[self setPLViewsToHeight:self.photoList.frame.size.height];//makes sure that our view are correctly aligned
    [self adjustSVContentSize];
}



-(void) addTapGestureToView:(UIView *)view
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(elementTaped:)];
    tap.numberOfTapsRequired =1;
    [view addGestureRecognizer:tap];
}


-(void) elementTaped:(UITapGestureRecognizer *) gesture
{
    UIView * view = gesture.view;
    if(view == self.photoList)
    {
        if(self.photoList.frame.size.height == self.frame.size.height)//it's full screen- take it back down
        {
            [UIView animateWithDuration:ANIMATION_DURATION animations:^
             {
                 [self setViewFrames];
             }completion:^(BOOL finished) {
                 [self setPLViewsToHeight:self.photoList.frame.size.height];
             }];
            
        }else
        {
            [UIView animateWithDuration:ANIMATION_DURATION animations:^
            {
                self.photoList.frame= self.bounds;
                [self bringSubviewToFront:self.photoList];//Make sure the SV covers the video view
                [self setPLViewsToHeight:self.photoList.frame.size.height];
            }];
        }
    }
}


-(void)setPLViewsToHeight:(CGFloat) height
{
    [UIView animateWithDuration:(height == self.frame.size.height) ? ANIMATION_DURATION : 0.3 animations:^{
        for(UIView * view in self.photoList.subviews)
        {
            
            if(height == self.frame.size.height)view.contentMode = UIViewContentModeScaleAspectFit;
            //else view.contentMode = UIViewContentModeScaleAspectFill;
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, self.frame.size.width, height);
        }
    }];
}


-(void)formatScrollView
{
    self.photoList.pagingEnabled = YES;
    self.photoList.showsHorizontalScrollIndicator = NO;
    self.photoList.showsVerticalScrollIndicator = NO;
    [self addTapGestureToView: self.photoList];
}

//gives you the frame for the next iamgeview that you'll add to the end of the list
-(CGRect) getNextFrame
{
    if(!self.photoList.subviews.count) return self.photoList.bounds;
    UIView * view = self.photoList.subviews.lastObject;
    return CGRectMake(view.frame.origin.x +view.frame.size.width, 0, self.photoList.frame.size.width, self.photoList.frame.size.height);
}

//resets the content size of the scrollview
-(void) adjustSVContentSize
{
    self.photoList.contentSize = CGSizeMake((self.frame.size.width* self.photoList.subviews.count), 0);
}



/*This code fuses the video assets into a single video that plays the videos one after the other*/
-(void)fuseAssets:(NSMutableArray*)assetList
{
    self.mix = [AVMutableComposition composition]; //create a composition to hold the joined assets
    AVMutableCompositionTrack* videoTrack = [self.mix addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack* audioTrack = [self.mix addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime nextClipStartTime = kCMTimeZero;
    NSError* error;
    
    for(ALAsset* asset in assetList)
    {
        AVURLAsset* assetClip = [AVURLAsset URLAssetWithURL: asset.defaultRepresentation.url options:nil];
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
    [self.videoView.layer addSublayer:playerLayer];
    // You can play/pause using the AVPlayer object
    player.muted = NO;
    [player play];
}

/*tells me when the video ends so that I can rewind*/
-(void)playerItemDidReachEnd:(NSNotification *)notification
{
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

/*Mute the video*/
-(void)mutePlayer
{
    AVPlayerLayer* playerLayer = [self.videoView.layer.sublayers firstObject];
    playerLayer.player.muted = YES;
}

/*Enable's the sound on the video*/
-(void)enableSound
{
    AVPlayerLayer* playerLayer = [self.videoView.layer.sublayers firstObject];
    playerLayer.player.muted = NO;
    playerLayer.player.volume = 0.5;
}

@end
