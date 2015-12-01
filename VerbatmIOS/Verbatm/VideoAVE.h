//
//  v_videoview.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVKit/AVKit.h>

#import <MediaPlayer/MediaPlayer.h>

#import "PinchView.h"

#import "TextOverMediaView.h"

#import <UIKit/UIKit.h>

#import "VideoPlayerView.h"

@interface VideoAVE : VideoPlayerView

//note that the video list can be avurlasset or nsurl
-(id)initWithFrame:(CGRect)frame pinchView:(PinchView *)pinchView orVideoArray:(NSArray*) videoAndTextList;

-(void)onScreen;
-(void)offScreen;
-(void)almostOnScreen;
@end
