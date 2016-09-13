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

#import "OpenCollectionView.h"

#import "PageViewingExperience.h"
#import "PinchView.h"
#import "TextOverMediaView.h"

#import <UIKit/UIKit.h>
#import "VideoPlayerView.h"

@interface VideoPVE : PageViewingExperience

@property (strong, nonatomic, readonly) VideoPlayerView* videoPlayer;

//Video list is array of arrays, each subarray containing either an NSURL or AVAsset, text, and textYPos
-(instancetype) initWithFrame:(CGRect)frame isPhotoVideoSubview:(BOOL)halfScreen;

-(void)setThumbnailImage:(UIImage *) image andVideo: (NSURL *)videoURL;

-(void) fuseVideoArray: (NSArray*) videoList;
-(void) muteVideo: (BOOL) mute;

@property (nonatomic) BOOL hasBeenSetUp;


@property (nonatomic) UIImageView * thumbnailView;
@property (nonatomic) AVAsset *videoAsset;
@property (nonatomic) BOOL photoVideoSubview;
@end