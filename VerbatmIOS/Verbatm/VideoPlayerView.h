 //
//  VideoPlayer.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/10/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface VideoPlayerView: UIView <NSCoding>

@property (nonatomic) BOOL repeatsVideo;

@property (nonatomic, readonly) BOOL videoLoading;
@property (nonatomic, readonly) BOOL isMuted;
@property (nonatomic, readonly) BOOL isVideoPlaying; //tells you if the video is in a playing state

// Array must be of avasset or nsurl
// Asynchronously fuses assets then sets the player item
-(void)prepareVideoFromArray: (NSArray*) videoList;

// Sets the player item from the avasset
-(void)prepareVideoFromAsset: (AVAsset*) asset;

// Sets the player item from the url
-(void)prepareVideoFromURL: (NSURL*) url;


#pragma mark - Playback -

-(void)playVideo;

// Pauses player. To continue, call playVideo again.
-(void)pauseVideo;

// Mutes and unmutes video
-(void) muteVideo: (BOOL) mute;

-(void)fastForwardVideoWithRate: (NSInteger) rate;

-(void)rewindVideoWithRate: (NSInteger) rate;

// Frees all objects associated with video
-(void) stopVideo;

-(void)removeMuteButtonFromView;

@end
