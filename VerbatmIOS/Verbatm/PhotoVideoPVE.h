//
//  v_multiplePhotoVideo.h
//  tester
//
//  Created by Iain Usiri on 12/20/14.
//  Copyright (c) 2014 IainAndLucio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

#import "PageViewingExperience.h"
#import "CollectionPinchView.h"

@class VideoPVE;

@interface PhotoVideoPVE : PageViewingExperience

@property (strong, nonatomic) VideoPVE *videoView;

//set before showAndRemoveCircle is called. This allows us to make the pan gestures not interact
@property (weak, nonatomic) UIScrollView * postScrollView;

// Will start animating until displayPhotos is called
-(instancetype)initWithFrame:(CGRect)frame small: (BOOL)small;

// Stops animating
-(void) displayPhotos:(NSArray*)photos andVideo:(NSURL*)videoURL andVideoThumbnail:(UIImage*)thumbnail;

// Initializer for when page view is in preview mode
-(instancetype) initWithFrame:(CGRect)frame andPinchView:(CollectionPinchView*) pinchView inPreviewMode: (BOOL) previewMode;

-(void) muteVideo: (BOOL) mute;

@end
