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
#import <UIKit/UIKit.h>

#import "ArticleViewingExperience.h"
#import "PinchView.h"
#import "TextOverMediaView.h"
#import "VideoPlayerView.h"

@interface VideoAVE : ArticleViewingExperience

@property (strong, nonatomic, readonly) VideoPlayerView* videoPlayer;

//note that the video list can be avurlasset or nsurl
-(instancetype) initWithFrame:(CGRect)frame andVideoArray:(NSArray*) videoAndTextList;

// Initializer for preview mode
-(instancetype) initWithFrame:(CGRect)frame andPinchView: (PinchView*) pinchView inPreviewMode: (BOOL) inPreviewMode;


@end
