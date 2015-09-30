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
//this boolean is NO by default and should only
//be triggered by a videopinchview
//this allows the video player to adjust the way the frame is displayed.
//should be called before any URL's are passed in. 
@property (nonatomic) BOOL forPinchView;


//pass in an array always - even if it's one url
-(void)playVideoFromURLArray: (NSArray*) urlArray;


-(void)playVideoFromAsset: (AVAsset*) asset;

// array of avassets
-(void) playVideoFromArrayOfAssets: (NSArray*)videoList;

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

-(void)removeMuteButtonFromView;

@end
