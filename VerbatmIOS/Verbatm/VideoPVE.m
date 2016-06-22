
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

@interface VideoPVE()<OpenCollectionViewDelegate>

@property (strong, nonatomic, readwrite) VideoPlayerView* videoPlayer;
@property (strong, nonatomic) UIImageView* videoProgressImageView;
@property (strong, nonatomic) UIButton* playButton;
@property (nonatomic) CGPoint firstTranslation;
@property (nonatomic) BOOL hasBeenSetUp;

#pragma mark - In Preview Mode -
@property (strong, nonatomic) PinchView* pinchView;
@property (nonatomic) EditMediaContentView * editContentView;
@property (nonatomic) OpenCollectionView * rearrangeView;
@property (nonatomic) UIButton * rearrangeButton;

@property (nonatomic) UIImageView * thumbnailView;
@property (nonatomic) AVAsset *videoAsset;

@property (nonatomic) BOOL photoVideoSubview;

@end


@implementation VideoPVE

-(instancetype) initWithFrame:(CGRect)frame isPhotoVideoSubview:(BOOL)halfScreen {
	self = [super initWithFrame:frame];
	if (self) {
		self.photoVideoSubview = halfScreen;
		self.inPreviewMode = NO;
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

-(instancetype) initWithFrame:(CGRect)frame andPinchView: (PinchView*) pinchView
				inPreviewMode: (BOOL) inPreviewMode isPhotoVideoSubview:(BOOL)halfScreen {
	self = [super initWithFrame:frame];
	if (self) {
		self.hasLoadedMedia = YES;
		self.photoVideoSubview = halfScreen;
		self.inPreviewMode = inPreviewMode;
		self.videoPlayer.repeatsVideo = YES;

		AVAsset *videoAsset = nil;
		NSMutableArray * videoAssets = [[NSMutableArray alloc] init];
		if([pinchView isKindOfClass:[CollectionPinchView class]]){
			videoAsset = ((CollectionPinchView *)pinchView).videoAsset;
			for(VideoPinchView* videoPinchView in ((CollectionPinchView *)pinchView).videoPinchViews) {
				[videoAssets addObject: videoPinchView.video];
			}
		} else if (((VideoPinchView *)pinchView).video) {
			[videoAssets addObject:((VideoPinchView *)pinchView).video];
		} else {
			NSLog(@"Something went wrong, video nil");
		}

		if (self.inPreviewMode) {
			self.editContentView = [[EditMediaContentView alloc] initWithFrame:self.bounds];
			self.editContentView.pinchView = pinchView;
			[self.editContentView displayVideo];
			[self addSubview: self.editContentView];
			if(videoAssets.count > 1) [self createRearrangeButton];
		}
		if (videoAsset != nil) {
			[self fuseVideoArray:@[videoAsset]];
		} else {
			[self fuseVideoArray:videoAssets];
		}

	}
	return self;
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
	if (self.inPreviewMode) {
		[self.editContentView prepareVideoFromAsset:self.videoAsset];
	} else {
		[self.videoPlayer prepareVideoFromAsset: self.videoAsset];
	}
	self.hasBeenSetUp = YES;
}

#pragma mark - Rearrange button -

-(void)createRearrangeButton {
	[self.rearrangeButton setImage:[UIImage imageNamed:MEDIA_REARRANGE_ICON] forState:UIControlStateNormal];
	self.rearrangeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self.rearrangeButton addTarget:self action:@selector(rearrangeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.rearrangeButton];
	[self bringSubviewToFront:self.rearrangeButton];
}

-(void)rearrangeButtonPressed {
	if(!self.rearrangeView){
		[self offScreen];
		self.rearrangeView = [[OpenCollectionView alloc] initWithFrame:self.bounds
													 andPinchViewArray: ((CollectionPinchView*)self.editContentView.pinchView).videoPinchViews];
		self.rearrangeView.delegate = self;
		[self insertSubview:self.rearrangeView belowSubview:self.rearrangeButton];
	} else {
		[self.rearrangeView exitView];
	}
}

-(void) collectionClosedWithFinalArray:(NSMutableArray *)pinchViews {
	NSMutableArray * assetArray = [[NSMutableArray alloc] init];
	for(VideoPinchView * videoPinchView in pinchViews) {
		[assetArray addObject:videoPinchView.video];
	}
	self.videoAsset = nil;
	if (self.editContentView) {
		self.editContentView.videoAsset = nil;
	}
	[self fuseVideoArray:assetArray];
	if(self.editContentView.videoView.isVideoPlaying){
		[self.editContentView offScreen];
	}
	if([self.editContentView.pinchView isKindOfClass:[CollectionPinchView class]]){
		((CollectionPinchView*)self.editContentView.pinchView).videoPinchViews = pinchViews;
		[self.editContentView.pinchView renderMedia];
	}
	if(self.rearrangeView){
		[self.rearrangeView removeFromSuperview];
		self.rearrangeView = nil;
	}
	self.hasBeenSetUp = NO;
	[self onScreen];
}

//called by opencollection view but not to be used here
-(void)pinchViewSelected:(PinchView *) pv{
    
}

#pragma mark - On and Off Screen (play and pause) -

-(void)offScreen {
	[self.customActivityIndicator stopCustomActivityIndicator];
	self.currentlyOnScreen = NO;
	if(self.editContentView) {
		[self.editContentView offScreen];
		if([self.editContentView.pinchView isKindOfClass:[CollectionPinchView class]]){
			((CollectionPinchView*)self.editContentView.pinchView).videoAsset = self.videoAsset;
		}
	} else{
		[self.videoPlayer stopVideo];
	}
	if(self.rearrangeView) [self.rearrangeView exitView];
	self.hasBeenSetUp = NO;
}

-(void)onScreen {
	self.currentlyOnScreen = YES;
	if (!self.hasLoadedMedia && !self.photoVideoSubview) {
		[self.customActivityIndicator startCustomActivityIndicator];
		return;
	}
	if (self.editContentView){
		[self.editContentView onScreen];
	} else {
		if(self.hasBeenSetUp){
			[self.videoPlayer playVideo];
		}else{
			[self prepareVideo];
			[self.videoPlayer playVideo];
		}
	}
}

-(void) almostOnScreen{
	if(self.editContentView){
		[self.editContentView almostOnScreen];
	} else {
		if(!self.hasBeenSetUp){
			[self.videoPlayer stopVideo];
			[self prepareVideo];
		}
	}
}

-(void) muteVideo:(BOOL)mute {
	[self.videoPlayer muteVideo:mute];
}

-(void)prepareForScreenShot{
    if(self.videoAsset){
        [self setThumbnailImage: [self.videoAsset getThumbnailFromAsset]];
        [self bringSubviewToFront:self.thumbnailView];
    }
}

#pragma mark - Lazy Instantiation -

-(VideoPlayerView*) videoPlayer {
	if (!_videoPlayer) {
		_videoPlayer = [[VideoPlayerView alloc] initWithFrame:self.bounds];
		[self addSubview:_videoPlayer];
	}
	return _videoPlayer;
}

-(UIButton *)rearrangeButton {
	if(!_rearrangeButton){
		_rearrangeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width -  EXIT_CV_BUTTON_WALL_OFFSET -
																	  EXIT_CV_BUTTON_WIDTH,
																	  self.frame.size.height - (EXIT_CV_BUTTON_HEIGHT) -
																	  (EXIT_CV_BUTTON_WALL_OFFSET),
																	  EXIT_CV_BUTTON_WIDTH,
																	  EXIT_CV_BUTTON_HEIGHT)];
	}
	return _rearrangeButton;
}

@end