//
//  VideoPlayerWrapperView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//
// Contains a video player view and matches all its methods but allows other subviews to be added to it

#import <UIKit/UIKit.h>
#import "VideoPlayerView.h"

@interface VideoPlayerWrapperView : UIImageView

@property (strong, nonatomic) VideoPlayerView* videoPlayerView;

-(void)playVideoFromURL: (NSURL*) url;
-(void)playVideoFromAsset: (AVAsset*) asset;
-(void) playVideoFromArray: (NSArray*)videoList;

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
