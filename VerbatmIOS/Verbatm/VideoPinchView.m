//
//  VideoPinchView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "VideoPinchView.h"
#import "Icons.h"
#import "Styles.h"

@interface VideoPinchView()

#pragma mark Encoding Keys

#define VIDEO_KEY @"video"

@end

@implementation VideoPinchView

-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andVideo: (AVURLAsset*)video {
	self = [super initWithRadius:radius withCenter:center];
	if (self) {
		[self initWithVideo:video];
	}
	return self;
}

-(void) initWithVideo: (AVURLAsset*)video {
	self.videoView = [[VideoPlayerWrapperView alloc] initWithFrame:self.background.frame];
	[self.videoView repeatVideoOnEnd:YES];
	[self.background addSubview:self.videoView];
	[self addPlayIcon];
	self.containsVideo = YES;
	self.video = video;
	[self renderMedia];
}

#pragma mark - Adding play button

-(void) addPlayIcon {
	UIImage* playIconImage = [UIImage imageNamed: PLAY_VIDEO_ICON];
	UIImageView* playImageView = [[UIImageView alloc] initWithImage:playIconImage];
	playImageView.alpha = PLAY_VIDEO_ICON_OPACITY;
	playImageView.frame = [self getCenterFrameForVideoView];
	[self.videoView addSubview:playImageView];
}

-(CGRect) getCenterFrameForVideoView {
	return CGRectMake(self.videoView.bounds.origin.x + self.videoView.bounds.size.width/4,
					  self.videoView.bounds.origin.y + self.videoView.bounds.size.height/4,
					  self.videoView.bounds.size.width/2, self.videoView.bounds.size.height/2);
}

#pragma mark - Render Media -

//This should be overriden in subclasses
-(void)renderMedia {
	[self displayMedia];
}

//This function displays the media on the view.
-(void)displayMedia {
	if (![self.videoView isPlaying]) {
		[self.videoView playVideoFromAsset: self.video];
		[self.videoView pauseVideo];
		[self.videoView muteVideo];
	}
}

#pragma mark - When pinch view goes on and off screen

-(void)offScreen {
	[self.videoView stopVideo];
}

-(void)onScreen {
	[self displayMedia];
}

#pragma mark - Overriding get videos

//overriding
-(NSArray*) getVideos {
	return @[self.video];
}

-(NSArray*) getVideosInDataFormat {
    NSURL * url = self.video.URL;
    NSError * error;
    NSData * ourData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
    NSLog(@"%@",error.description);
    return  (ourData) ? @[ourData] : nil;
}

#pragma mark - Encoding -

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	NSURL* videoURL = [self.video URL];;
	[coder encodeObject:videoURL forKey:VIDEO_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		NSURL* videoURL = [decoder decodeObjectForKey:VIDEO_KEY];
		AVURLAsset* video = [AVURLAsset assetWithURL:videoURL];
		[self initWithVideo:video];
	}
	return self;
}

@end
