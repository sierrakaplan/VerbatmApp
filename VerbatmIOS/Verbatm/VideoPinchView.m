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

#import <PromiseKit/PromiseKit.h>

@interface VideoPinchView()

@property (strong, nonatomic) NSData* videoData;

#pragma mark Encoding Keys

#define VIDEO_KEY @"video"
#define VIDEO_DATA_KEY @"video_data"

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
	self.videoView = [[VideoPlayerWrapperView alloc] initWithFrame: self.background.frame];
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


/* returns an array with nsdata or a promise*/
-(NSArray *) getVideosInDataFormat {
	if (self.videoData) {
		return @[self.videoData];
	}
    NSURL * url = self.video.URL;
    NSError * error;
    NSData * ourData = nil;
    ourData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
    
    @try{
        if (!ourData) {
            //NSLog(@"error getting data from video url: %@", error.description);
            AnyPromise * promise = [self convertAssetUsingExportSession:self.video];
           return @[promise];
        } else {
            return @[ourData];
        }
    }@catch (NSException *exception) {
        NSLog(@"error getting data from video url: %@", exception.description);
    }
}


-(AnyPromise*) convertAssetUsingExportSession: (AVURLAsset *) asset {
    AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
        __block NSData *assetData = nil;
        
        NSString *movieOutput = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"newoutput.mov"];
        NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:movieOutput];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:movieOutput]){
            NSError *error;
            if ([fileManager removeItemAtPath:movieOutput error:&error] == NO){
                NSLog(@"output path is wrong");
            }
        }
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
        exportSession.outputURL = outputURL;
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            assetData = [NSData dataWithContentsOfURL:outputURL];
             resolve(assetData);
        }];
    }];
    
    return promise;
}

#pragma mark - Encoding -

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
//	NSData* videoData = [NSData dataWithContentsOfURL:[self.video URL]];
//	[coder encodeObject: videoData forKey: VIDEO_DATA_KEY];
	NSString* videoURLString = [self.video URL].absoluteString;
	[coder encodeObject: videoURLString forKey:VIDEO_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		NSString* videoURLString = [decoder decodeObjectForKey:VIDEO_KEY];
//		self.videoData = [decoder decodeObjectForKey:VIDEO_DATA_KEY];
		AVURLAsset* video = [AVURLAsset assetWithURL:[NSURL URLWithString:videoURLString]];
		[self initWithVideo:video];
	}
	return self;
}

@end
