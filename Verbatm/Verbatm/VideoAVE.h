//
//  v_videoview.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VideoPlayerView.h"

@interface VideoAVE : VideoPlayerView
-(void)showPlayBackIcons;
//note that the video list can be alasset or nsdata
-(id)initWithFrame:(CGRect)frame andVideoAssetArray:(NSArray*)videoList;
-(void)onScreen;
-(void)offScreen;
//for when you want to change the video set
-(void)playVideos:(NSArray*)videoList;
@end
