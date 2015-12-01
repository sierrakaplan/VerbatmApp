//
//  CollectionPinchView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "AVAsset+Utilities.h"
#import "CollectionPinchView.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "Icons.h"
#import "ImagePinchView.h"
#import "VideoPinchView.h"

@interface CollectionPinchView()

@property (weak, nonatomic) UIImage* image;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage* videoImage;
@property (strong, nonatomic) UIImageView* videoView;
@property (strong, nonatomic) UIImageView *playVideoImageView;
@property (strong, nonatomic) UIImage* playVideoIconHalf;
@property (strong, nonatomic) UIImage* playVideoIconQuarter;
@property (strong, nonatomic) UIImage* playVideoIconFull;

#pragma mark Encoding Keys

#define IMAGE_PINCHVIEWS_KEY @"image_pinchviews_key"
#define VIDEO_PINCHVIEWS_KEY @"video_pinchviews_key"

@end

@implementation CollectionPinchView

-(instancetype)initWithRadius:(float)radius withCenter:(CGPoint)center andPinchViews:(NSArray*)pinchViews {
	self = [super initWithRadius:radius withCenter:center];
	if (self) {
		[self initWithPinchViews:pinchViews];
	}
	return self;
}

-(void) initWithPinchViews:(NSArray*)pinchViews {
	[self.background addSubview:self.videoView];
	[self addPlayIcon];
	[self addCollectionViewBorder];
	[self.background addSubview:self.imageView];
	[self.background addSubview:self.videoView];
	for (SingleMediaAndTextPinchView* pinchView in pinchViews) {
		[self addPinchView:pinchView];
	}
	[self renderMedia];
}

-(void) addPinchView: (SingleMediaAndTextPinchView*) pinchView {
	if ([pinchView isKindOfClass:[ImagePinchView class]]) {
		[self.imagePinchViews addObject:pinchView];
	} else if ([pinchView isKindOfClass:[VideoPinchView class]]) {
		[self.videoPinchViews addObject:pinchView];
	}
}

#pragma mark - Adding play button to video

-(void) addPlayIcon {
	self.playVideoIconFull = [UIImage imageNamed: PLAY_VIDEO_ICON];
	self.playVideoIconHalf = [UIImage imageNamed: PLAY_VIDEO_ICON_HALF_CIRCLE];
	self.playVideoIconQuarter = [UIImage imageNamed: PLAY_VIDEO_ICON_QUARTER_CIRCLE];
	self.playVideoImageView = [[UIImageView alloc] initWithImage: self.playVideoIconFull];
	self.playVideoImageView.alpha = PLAY_VIDEO_ICON_OPACITY;
	self.playVideoImageView.frame = self.videoView.bounds;
	[self.videoView addSubview:self.playVideoImageView];
}

#pragma mark - Render Media -

-(void) updateMedia {
	if (self.imagePinchViews.count) {
		self.containsImage = YES;
		// most recently pinched image displayed
		self.image = [(ImagePinchView*)self.imagePinchViews[self.imagePinchViews.count-1] getImage];
	} else {
		self.containsImage = NO;
		self.image = nil;
	}

	if (self.videoPinchViews.count) {
		self.containsVideo = YES;
		// most recently pinched image displayed
		self.videoImage = [[(VideoPinchView*)self.videoPinchViews[self.videoPinchViews.count-1] video] getThumbnailFromAsset];
	} else {
		self.containsVideo = NO;
		self.videoImage = nil;
	}
}

-(void)renderMedia {
	[self updateMedia];
	switch([self numTypesOfMedia]) {
		case 1:
			[self renderSingleMedia];
			break;
		case 2:
			[self renderTwoMedia];
			break;
		default:
			return;
	}
	[self displayMedia];
}

//This renders a single view on the pinch object
-(void)renderSingleMedia {
	if(self.containsVideo){
		self.videoView.frame = self.background.frame;
		self.playVideoImageView.image = self.playVideoIconFull;
	}else {
		self.imageView.frame = self.background.frame;
	}
}

//this renders two media in a vertical split view kind of way on the pinch object.
-(void)renderTwoMedia {
	CGRect frame1 = CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y, self.background.frame.size.width/2.f , self.background.frame.size.height);
	CGRect frame2 = CGRectMake(self.background.frame.origin.x + self.background.frame.size.width/2.f, self.background.frame.origin.y, self.background.frame.size.width/2.f, self.background.frame.size.height);

	self.videoView.frame = frame1;
	self.playVideoImageView.image = self.playVideoIconHalf;
	self.imageView.frame = frame2;
}

//This function displays the media on the view.
-(void)displayMedia {
	self.playVideoImageView.frame = [self getCenterFrameForVideoView];
	if (self.containsImage) {
		[self.imageView setImage:self.image];
		[self.background bringSubviewToFront:self.imageView];
	}
	if (self.containsVideo) {
		[self.videoView setImage: self.videoImage];
		[self.background bringSubviewToFront:self.videoView];
	}
}

-(CGRect) getCenterFrameForVideoView {
	return CGRectMake(self.videoView.bounds.origin.x + self.videoView.bounds.size.width/4,
					  self.videoView.bounds.origin.y + self.videoView.bounds.size.height/4,
					  self.videoView.bounds.size.width/2, self.videoView.bounds.size.height/2);
}

#pragma mark - Collection View Border -

-(void) addCollectionViewBorder {
	self.layer.borderWidth = COLLECTION_PINCHVIEW_BORDER_WIDTH;
	self.layer.borderColor = [UIColor PINCHVIEW_BORDER_COLOR].CGColor;
	self.layer.shadowColor = [UIColor PINCHVIEW_BORDER_COLOR].CGColor;
	self.layer.shadowRadius = COLLECTION_PINCHVIEW_SHADOW_RADIUS;
	self.layer.shadowOffset = CGSizeMake(0, 0);
	self.layer.shadowOpacity = 1;
}

-(void)markAsDeleting: (BOOL) deleting {
	[super markAsDeleting:deleting];
	if (deleting) {
		self.layer.shadowOpacity = 0;
	} else {
		[self addCollectionViewBorder];
	}
}

-(void)markAsSelected: (BOOL) selected {
	[super markAsSelected:selected];
	if (!selected) {
		[self addCollectionViewBorder];
	}
}

#pragma mark - Add and return pinch views -

-(NSInteger) getNumPinchViews {
	return [self.imagePinchViews count] + [self.videoPinchViews count];
}

-(CollectionPinchView*) pinchAndAdd:(SingleMediaAndTextPinchView*)pinchView {
	[self addPinchView: pinchView];
	[self renderMedia];
	return self;
}

-(CollectionPinchView*) unPinchAndRemove:(PinchView*)pinchView {
	if ([self.imagePinchViews containsObject:pinchView]) {
		[self.imagePinchViews removeObject:pinchView];
	} else if ([self.videoPinchViews containsObject:pinchView]) {
		[self.videoPinchViews removeObject:pinchView];
	}
	[self renderMedia];
	return self;
}

//overriding
-(NSArray*) getPhotosWithText {
	NSMutableArray* photosWithText = [[NSMutableArray alloc] init];
	for (ImagePinchView* pinchView in self.imagePinchViews) {
		[photosWithText addObject:[(ImagePinchView*)pinchView getPhotosWithText][0]];
	}
	return photosWithText;
}

-(NSArray*) getVideosWithText {
	NSMutableArray* videosWithText = [[NSMutableArray alloc] init];
	for (VideoPinchView* pinchView in self.videoPinchViews) {
		[videosWithText addObject:[(VideoPinchView*)pinchView getVideosWithText][0]];
	}
	return videosWithText;
}

#pragma mark - Encoding -

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	NSData* imagePinchViewsData = [NSKeyedArchiver archivedDataWithRootObject:self.imagePinchViews];
	NSData* videoPinchViewsData = [NSKeyedArchiver archivedDataWithRootObject:self.videoPinchViews];
	[coder encodeObject:imagePinchViewsData forKey:IMAGE_PINCHVIEWS_KEY];
	[coder encodeObject:videoPinchViewsData forKey:VIDEO_PINCHVIEWS_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		NSData* imagePinchViewsData = [decoder decodeObjectForKey:IMAGE_PINCHVIEWS_KEY];
		NSData* videoPinchViewsData = [decoder decodeObjectForKey:VIDEO_PINCHVIEWS_KEY];
		NSArray* imagePinchViews = [NSKeyedUnarchiver unarchiveObjectWithData: imagePinchViewsData];
		NSArray* videoPinchViews = [NSKeyedUnarchiver unarchiveObjectWithData: videoPinchViewsData];
		NSMutableArray* pinchViews = [NSMutableArray arrayWithArray:imagePinchViews];
		[pinchViews addObjectsFromArray:videoPinchViews];
		// If there are videoPinchViews should wait until one avurlasset is fetched before rendering media
		for (VideoPinchView* videoPinchView in videoPinchViews) {
			// load video avurlasset from phasset
			PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[[videoPinchView phAssetLocalIdentifier]] options:nil];
			PHAsset* videoAsset = fetchResult.firstObject;
			PHVideoRequestOptions* options = [PHVideoRequestOptions new];
			options.networkAccessAllowed =  YES; //videos won't only be loaded over wifi
			options.deliveryMode = PHVideoRequestOptionsDeliveryModeMediumQualityFormat;
			options.version = PHVideoRequestOptionsVersionCurrent;
			[[PHImageManager defaultManager] requestAVAssetForVideo:videoAsset
															options:options
													  resultHandler:^(AVAsset *videoAsset, AVAudioMix *audioMix, NSDictionary *info) {
														  dispatch_async(dispatch_get_main_queue(), ^{
															  [videoPinchView initWithVideo: (AVURLAsset*)videoAsset];
															  [self initWithPinchViews:pinchViews];
														  });
													  }];
			return self;

		}
		[self initWithPinchViews:pinchViews];
	}
	return self;
}

#pragma mark - Lazy Instantiation -

-(NSMutableArray*) imagePinchViews {
	if(!_imagePinchViews) _imagePinchViews = [[NSMutableArray alloc] init];
	return _imagePinchViews;
}

-(NSMutableArray*) videoPinchViews {
	if(!_videoPinchViews) _videoPinchViews = [[NSMutableArray alloc] init];
	return _videoPinchViews;
}

-(UIImageView*)imageView {
	if(!_imageView) {
		_imageView = [[UIImageView alloc] init];
		_imageView.contentMode = UIViewContentModeScaleAspectFill;
		_imageView.layer.masksToBounds = YES;
	}
	return _imageView;
}

-(UIImageView*) videoView {
	if (!_videoView) {
		_videoView = [[UIImageView alloc] init];
		_videoView.contentMode = UIViewContentModeScaleAspectFill;
		_videoView.clipsToBounds = YES;
	}
	return _videoView;
}

@end
