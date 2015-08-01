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

-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andVideo:(id)video {
	self = [super initWithRadius:radius withCenter:center];
	if (self) {
		[self initWithVideo:video];
	}
	return self;
}

-(void) initWithVideo:(id)video {
	self.videoView = [[VideoPlayerWrapperView alloc] initWithFrame:self.background.frame];
	[self.videoView repeatVideoOnEnd:YES];
	[self.background addSubview:self.videoView];
	[self addPlayIcon];
	self.containsVideo = YES;
	if ([video isKindOfClass:[AVAsset class]]) {
		self.videoFormat = VideoFormatAsset;
	} else if ([video isKindOfClass:[NSURL class]]) {
		self.videoFormat = VideoFormatURL;
	} else {
		NSLog(@"Video passed in is not asset or url format");
		return;
	}
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
		switch (self.videoFormat) {
			case VideoFormatAsset:
				[self.videoView playVideoFromAsset: self.video];
				break;
			case VideoFormatURL:
				[self.videoView playVideoFromURL: self.video];
				break;
			default:
				break;
		}
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

#pragma mark - Encoding -

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	NSURL* videoURL = self.video;
	if(self.videoFormat == VideoFormatAsset) {
		videoURL = [(AVURLAsset*)self.video URL];
	}
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
