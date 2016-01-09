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

//Video list is array of arrays, each subarray containing either an NSURL or AVAsset, text, and textYPos
-(instancetype) initWithFrame:(CGRect)frame andVideoWithTextArray:(NSArray*) videoAndTextList;

// Initializer for preview mode
-(instancetype) initWithFrame:(CGRect)frame andPinchView: (PinchView*) pinchView inPreviewMode: (BOOL) inPreviewMode;


@end
