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

#define PINCHVIEWS_KEY @"child_pinchviews"

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
	[self.pinchedObjects addObjectsFromArray:pinchViews];
	[self updateMedia];
	[self renderMedia];
}

#pragma mark - Adding play button

-(void) addPlayIcon {
	self.playVideoIconFull = [UIImage imageNamed: PLAY_VIDEO_ICON];
	self.playVideoIconHalf = [UIImage imageNamed: PLAY_VIDEO_ICON_HALF_CIRCLE];
	self.playVideoIconQuarter = [UIImage imageNamed: PLAY_VIDEO_ICON_QUARTER_CIRCLE];
	self.playVideoImageView = [[UIImageView alloc] initWithImage: self.playVideoIconFull];
	self.playVideoImageView.alpha = PLAY_VIDEO_ICON_OPACITY;
	self.playVideoImageView.frame = self.videoView.bounds;
	[self.videoView addSubview:self.playVideoImageView];
}

#pragma mark - Collection View Border - 

-(void) addCollectionViewBorder {
	self.layer.borderWidth = COLLECTION_PINCHVIEW_BORDER_WIDTH;
	self.layer.borderColor = [UIColor PINCHVIEW_BORDER_COLOR].CGColor;
	self.layer.shadowColor = [UIColor PINCHVIEW_BORDER_COLOR].CGColor;
	self.layer.shadowRadius = COLLECTION_PINCHVIEW_SHADOW_RADIUS;
	self.layer.shadowOpacity = 1;
}

-(void)markAsDeleting: (BOOL) deleting {
	if (deleting) {
		self.layer.borderColor = [UIColor DELETING_ITEM_COLOR].CGColor;
		self.layer.shadowOpacity = 0;
	} else {
		self.layer.borderColor = [UIColor PINCHVIEW_BORDER_COLOR].CGColor;
		self.layer.shadowOpacity = 1;
	}
}

-(void)markAsSelected: (BOOL) selected {
	if (selected) {
		self.layer.borderColor = [UIColor SELECTED_ITEM_COLOR].CGColor;
		self.layer.shadowOpacity = 0;
	} else {
		self.layer.borderColor = [UIColor PINCHVIEW_BORDER_COLOR].CGColor;
		self.layer.shadowOpacity = 1;
	}
}

#pragma mark - Render Media -

//This should be overriden in subclasses
-(void)renderMedia {
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

#pragma mark - Add and return pinch views -

-(NSInteger) getNumPinchViews {
	return [self.pinchedObjects count];
}

-(void) updateMedia {
	self.image = nil;
	self.videoImage = nil;
	self.containsImage = NO;
	self.containsVideo = NO;
	for (PinchView* pinchView in self.pinchedObjects) {
		[self changeTypesOfMediaFromPinchView:pinchView];
	}
}

-(void) changeTypesOfMediaFromPinchView:(PinchView*) pinchView {
	if(pinchView.containsImage) {
		self.containsImage = YES;
		//if(!self.image) {
			self.image = [(ImagePinchView*)pinchView getImage];
		//}
	} else if(pinchView.containsVideo) {
		self.containsVideo = YES;
		if(!self.videoImage) {
			self.videoImage = [[(VideoPinchView*)pinchView video] getThumbnailFromAsset];
		}
	}
}

-(CollectionPinchView*) pinchAndAdd:(PinchView*)pinchView {
	[self.pinchedObjects addObject:pinchView];
	[self changeTypesOfMediaFromPinchView:pinchView];
	[self renderMedia];
	return self;
}

-(CollectionPinchView*) unPinchAndRemove:(PinchView*)pinchView {
	if ([self.pinchedObjects containsObject:pinchView]) {
		[self.pinchedObjects removeObject:pinchView];
		[self updateMedia];
	}
	[self renderMedia];
	return self;
}

//overriding
-(NSArray*) getPhotosWithText {
	NSMutableArray* photosWithText = [[NSMutableArray alloc] init];
	for (PinchView* pinchView in self.pinchedObjects) {
		if(pinchView.containsImage) {
			[photosWithText addObject:[(ImagePinchView*)pinchView getPhotosWithText][0]];
		}
	}
	return photosWithText;
}

-(NSArray*) getVideosWithText {
	NSMutableArray* videosWithText = [[NSMutableArray alloc] init];
	for (PinchView* pinchView in self.pinchedObjects) {
		if(pinchView.containsVideo) {
			[videosWithText addObject:[(VideoPinchView*)pinchView getVideosWithText][0]];
		}
	}
	return videosWithText;
}

-(NSInteger) getTotalPiecesOfMedia {
	return self.pinchedObjects.count;
}

#pragma mark - Encoding -

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	NSData* pinchViewsData = [NSKeyedArchiver archivedDataWithRootObject:self.pinchedObjects];
	[coder encodeObject:pinchViewsData forKey:PINCHVIEWS_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		NSData* pinchViewsData = [decoder decodeObjectForKey:PINCHVIEWS_KEY];
		NSArray* pinchViews = [NSKeyedUnarchiver unarchiveObjectWithData:pinchViewsData];
		// If one of the pinch views contains video should wait until the avurlasset is fetched before rendering media
		for (PinchView* pinchView in pinchViews) {
			if (pinchView.containsVideo) {
				// load video avurlasset from phasset
				PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[[(VideoPinchView*)pinchView phAssetLocalIdentifier]] options:nil];
				PHAsset* videoAsset = fetchResult.firstObject;
				PHVideoRequestOptions* options = [PHVideoRequestOptions new];
				options.networkAccessAllowed =  YES; //videos won't only be loaded over wifi
				options.deliveryMode = PHVideoRequestOptionsDeliveryModeMediumQualityFormat;
				options.version = PHVideoRequestOptionsVersionCurrent;
				[[PHImageManager defaultManager] requestAVAssetForVideo:videoAsset
																options:options
														  resultHandler:^(AVAsset *videoAsset, AVAudioMix *audioMix, NSDictionary *info) {
															  dispatch_async(dispatch_get_main_queue(), ^{
																  [(VideoPinchView*)pinchView initWithVideo: (AVURLAsset*)videoAsset];
																  [self initWithPinchViews:pinchViews];
															  });
														  }];
				return self;
			}
		}
		[self initWithPinchViews:pinchViews];
	}
	return self;
}

#pragma mark - Lazy Instantiation -

-(NSMutableArray*) pinchedObjects {
	if(!_pinchedObjects) _pinchedObjects = [[NSMutableArray alloc] init];
	return _pinchedObjects;
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
