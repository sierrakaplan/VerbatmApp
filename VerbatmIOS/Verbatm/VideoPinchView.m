//
//  VideoPinchView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "AVAsset+Utilities.h"
#import "VideoPinchView.h"
#import "Icons.h"
#import "POVLoadManager.h"
#import "Styles.h"

#import <PromiseKit/PromiseKit.h>

@interface VideoPinchView()

#pragma mark Encoding Keys

#define VIDEO_KEY @"video"

@property (strong, nonatomic) UIImage* videoImage;
@property (strong, nonatomic) UIImageView* videoView;

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
	[self.videoView setFrame: self.background.frame];
	[self.background addSubview:self.videoView];
	[self addPlayIcon];
	self.containsVideo = YES;
	self.video = video;
	self.videoImage = [self.video getThumbnailFromAsset];
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
	[self.videoView setImage: self.videoImage];
}

#pragma mark - Overriding get videos

//overriding
-(NSArray*) getVideosWithText {
	if (self.textView) {
		return @[@[self.video, self.textView.text]];
	}
	return @[@[self.video, @""]];
}

#pragma mark - Encoding -

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	NSString* videoURLString = [self.video URL].absoluteString;
	[coder encodeObject: videoURLString forKey:VIDEO_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		NSString* videoURLString = [decoder decodeObjectForKey:VIDEO_KEY];
		AVURLAsset* video = [AVURLAsset assetWithURL:[NSURL URLWithString:videoURLString]];
		[self initWithVideo:video];
	}
	return self;
}

#pragma mark - Lazy Instantiation -

-(UIImageView*) videoView {
	if (!_videoView) {
		_videoView = [[UIImageView alloc] init];
		_videoView.contentMode = UIViewContentModeScaleAspectFill;
		_videoView.clipsToBounds = YES;
	}
	return _videoView;
}

@end
