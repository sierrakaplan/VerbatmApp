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

//note that the video list can be avurlasset or nsurl
-(id)initWithFrame:(CGRect)frame andVideoArray:(NSArray*)videoList;

-(void)onScreen;
-(void)offScreen;
//for when you want to change the video set
-(void)playVideos:(NSArray*)videoList;
-(void)almostOnScreen;
@end
