
//
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//
#import "AVAsset+Utilities.h"

#import "CollectionPinchView.h"

#import "EditMediaContentView.h"

#import "Icons.h"

#import "PostInProgress.h"

#import "OpenCollectionView.h"

#import "SizesAndPositions.h"

#import "VideoPVE.h"
#import "VideoPinchView.h"

#import "UtilityFunctions.h"

@interface VideoPVE()

@property (strong, nonatomic, readwrite) VideoPlayerView* videoPlayer;
@property (strong, nonatomic) UIImageView* videoProgressImageView;
@property (strong, nonatomic) UIButton* playButton;
@property (nonatomic) CGPoint firstTranslation;



@end


@implementation VideoPVE

-(instancetype) initWithFrame:(CGRect)frame isPhotoVideoSubview:(BOOL)halfScreen {
	self = [super initWithFrame:frame];
	if (self) {
		self.photoVideoSubview = halfScreen;
		self.videoPlayer.repeatsVideo = YES;
	}
	return self;
}

-(void)setThumbnailImage:(UIImage *) image andVideo: (NSURL *)videoURL {
	self.hasLoadedMedia = YES;
	[self.customActivityIndicator stopCustomActivityIndicator];
	[self.customActivityIndicator removeFromSuperview];
	[self fuseVideoArray:@[videoURL]];
	[self setThumbnailImage: image];
	if (self.currentlyOnScreen) {
		[self onScreen];
	}
}


-(void) fuseVideoArray: (NSArray*) videoList {
	if (videoList.count == 1) {
		AVAsset *asset = videoList[0];
		if ([videoList[0] isKindOfClass:[NSURL class]]) {
			asset = [AVAsset assetWithURL:videoList[0]];
		}
		self.videoAsset = asset;
		[self prepareVideo];
		return;
	}
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
		self.videoAsset = [UtilityFunctions fuseAssets: videoList];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self prepareVideo];
		});
	});
}

-(void)setThumbnailImage:(UIImage *) image {
    self.thumbnailView = [[UIImageView alloc] initWithImage:image];
    self.thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    self.thumbnailView.frame = self.bounds;
    [self addSubview: self.thumbnailView];
    [self sendSubviewToBack:self.thumbnailView];
}

-(void)prepareVideo {
	if (self.videoAsset == nil) {
		return;
	}
	
    [self.videoPlayer prepareVideoFromAsset: self.videoAsset];
	self.hasBeenSetUp = YES;
}



#pragma mark - On and Off Screen (play and pause) -

-(void)offScreen {
	[self.customActivityIndicator stopCustomActivityIndicator];
	self.currentlyOnScreen = NO;
		[self.videoPlayer stopVideo];
	self.hasBeenSetUp = NO;
}

-(void)onScreen {
	self.currentlyOnScreen = YES;
	if (!self.hasLoadedMedia && !self.photoVideoSubview) {
		[self.customActivityIndicator startCustomActivityIndicator];
		return;
	}

    if(self.hasBeenSetUp){
        [self.videoPlayer playVideo];
    }else{
        [self prepareVideo];
        [self.videoPlayer playVideo];
    }
}

-(void) almostOnScreen{
}

-(void) muteVideo:(BOOL)mute {
	[self.videoPlayer muteVideo:mute];
}

-(void)prepareForScreenShot{
    if(self.videoAsset){
        [self setThumbnailImage: [self.videoAsset getThumbnailFromAsset]];
        [self bringSubviewToFront:self.thumbnailView];
        [self offScreen];
    }
}

-(void)dealloc {
}

#pragma mark - Lazy Instantiation -

-(VideoPlayerView*) videoPlayer {
	if (!_videoPlayer) {
		_videoPlayer = [[VideoPlayerView alloc] initWithFrame:self.bounds];
		[self addSubview:_videoPlayer];
	}
	return _videoPlayer;
}


@end