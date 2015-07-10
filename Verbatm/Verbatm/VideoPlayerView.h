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

@property (nonatomic,strong) AVPlayerLayer* playerLayer;

-(void)playVideoFromURL: (NSURL*) url;

-(void)playVideoFromAsset: (AVAsset*) asset;

//following methods will only execute if playVideo was called first

-(void) repeatVideoOnEnd;

-(void)pauseVideo;

-(void)continueVideo;

-(void)unmuteVideo;

-(void)muteVideo;

@end
