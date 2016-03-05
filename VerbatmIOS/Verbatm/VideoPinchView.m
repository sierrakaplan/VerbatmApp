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
#import "Styles.h"

@interface VideoPinchView()

@property (strong, nonatomic) UIImage* videoImage;
@property (strong, nonatomic) UIImageView* playImageView;
@property (strong, nonatomic) UIImageView* videoView;

#pragma mark Encoding Keys

#define PHASSET_IDENTIFIER_KEY @"video_phasset_local_id"

@end

@implementation VideoPinchView

-(instancetype)initWithRadius:(float)radius withCenter:(CGPoint)center andVideo: (AVURLAsset*)video andPHAssetLocalIdentifier: (NSString*) localIdentifier {
	self = [super initWithRadius:radius withCenter:center];
	if (self) {
		self.phAssetLocalIdentifier = localIdentifier;
		[self initWithVideo:video];
	}
	return self;
}

-(void) initWithVideo: (AVURLAsset*)video {
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
	self.playImageView = [[UIImageView alloc] initWithImage:playIconImage];
	self.playImageView.alpha = PLAY_VIDEO_ICON_OPACITY;
	[self.videoView addSubview:self.playImageView];
}

-(CGRect) getCenterFrameForVideoView {
	return CGRectMake(self.videoView.bounds.origin.x + self.videoView.bounds.size.width/4,
					  self.videoView.bounds.origin.y + self.videoView.bounds.size.height/4,
					  self.videoView.bounds.size.width/2, self.videoView.bounds.size.height/2);
}

#pragma mark - Render Media -

//This should be overriden in subclasses
-(void)renderMedia {
	[self.videoView setFrame: self.background.frame];
	self.playImageView.frame = [self getCenterFrameForVideoView];
	[self.videoView setImage: self.videoImage];
}

#pragma mark - Overriding get videos

//overriding
-(NSArray*) getVideosWithText {
	return @[@[self.video, self.text, self.textYPosition]];
}

-(NSInteger) getTotalPiecesOfMedia {
	return 1;
}

#pragma mark - Encoding -

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject: self.phAssetLocalIdentifier forKey:PHASSET_IDENTIFIER_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		self.phAssetLocalIdentifier = [decoder decodeObjectForKey:PHASSET_IDENTIFIER_KEY];
	}
	return self;
}

-(AnyPromise*) loadAVURLAssetFromPHAsset {
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
		// load video avurlasset from phasset
		PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[self.phAssetLocalIdentifier] options:nil];
		PHAsset* videoAsset = fetchResult.firstObject;
		PHVideoRequestOptions* options = [PHVideoRequestOptions new];
		options.networkAccessAllowed =  YES; //videos won't only be loaded over wifi
		options.deliveryMode = PHVideoRequestOptionsDeliveryModeMediumQualityFormat;
		options.version = PHVideoRequestOptionsVersionCurrent;
		[[PHImageManager defaultManager] requestAVAssetForVideo:videoAsset
														options:options
												  resultHandler:^(AVAsset *videoAsset, AVAudioMix *audioMix, NSDictionary *info) {
													  dispatch_async(dispatch_get_main_queue(), ^{
														  [self initWithVideo: (AVURLAsset*)videoAsset];
														  resolve(videoAsset);
													  });
												  }];
	}];
	return promise;
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
