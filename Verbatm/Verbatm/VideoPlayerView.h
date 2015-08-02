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



-(void)playVideoFromURL: (NSURL*) url;
-(void)playVideoFromAsset: (AVAsset*) asset;
-(void) playVideoFromArray: (NSArray*)videoList;
-(void) playVideoFromURLList: (NSArray*) urlList;

//following methods will only execute if playVideo was called first

-(void)repeatVideoOnEnd:(BOOL)repeat;

-(void)pauseVideo;

-(void)continueVideo;

-(void)unmuteVideo;

-(void)muteVideo;

-(void)fastForwardVideoWithRate: (NSInteger) rate;

-(void)rewindVideoWithRate: (NSInteger) rate;

-(void) stopVideo;

-(BOOL) isPlaying;


@end
