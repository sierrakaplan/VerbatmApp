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

#import "UtilityFunctions.h"

@interface CollectionPinchView()

@property (strong, nonatomic, readwrite) NSMutableArray* pinchedObjects;

@property (weak, nonatomic) UIImage* image;
@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic) UITextView *textView;
@property (strong, nonatomic) UIImage* videoImage;
@property (strong, nonatomic) UIImageView* videoView;
@property (strong, nonatomic) UIImageView *playVideoImageView;

#pragma mark Encoding Keys

#define PINCHVIEWS_KEY @"child_pinchviews"

@end

@implementation CollectionPinchView

-(instancetype)initWithRadius:(CGFloat)radius withCenter:(CGPoint)center andPinchViews:(NSArray*)pinchViews {
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
	[self.background addSubview:self.textView];
	[self.pinchedObjects addObjectsFromArray:pinchViews];
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
	[self renderMedia];
}

#pragma mark - Adding play button to video

-(void) addPlayIcon {
	UIImage *playVideoIcon = [UIImage imageNamed: PLAY_VIDEO_ICON];
	self.playVideoImageView = [[UIImageView alloc] initWithImage: playVideoIcon];
	self.playVideoImageView.alpha = PLAY_VIDEO_ICON_OPACITY;
	self.playVideoImageView.frame = self.videoView.bounds;
	self.playVideoImageView.contentMode = UIViewContentModeScaleAspectFit;
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
			break;
	}
	[self displayMedia];
}

//This renders a single view on the pinch object
-(void)renderSingleMedia {
	if(self.containsVideo){
		self.videoView.frame = self.background.frame;
	} else {
		self.imageView.frame = self.background.frame;
	}
}

//this renders two media in a vertical split view kind of way on the pinch object.
-(void)renderTwoMedia {
	CGRect frame1 = CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y, self.background.frame.size.width,
							   self.background.frame.size.height/2.f);
	CGRect frame2 = CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y + self.background.frame.size.height/2.f,
							   self.background.frame.size.width, self.background.frame.size.height/2.f);

	self.videoView.frame = frame1;
	self.imageView.frame = frame2;
}

//This function displays the media on the view.
-(void)displayMedia {
	self.playVideoImageView.frame = [self getCenterFrameForVideoView];
	if (self.containsImage) {
		[self.imageView setImage:self.image];
		[self.background bringSubviewToFront:self.imageView];

		ImagePinchView* lastPinchView = (ImagePinchView*)self.imagePinchViews[self.imagePinchViews.count-1];
		if (lastPinchView.text && lastPinchView.text.length) {
			CGFloat scale = self.imageView.frame.size.height / FULL_SCREEN_SIZE.height;
			[self.textView setText: lastPinchView.text];
			CGFloat yPos = lastPinchView.textYPosition.floatValue * scale + self.imageView.frame.origin.y;
			[self.textView setFrame:CGRectMake(0.f, yPos, self.frame.size.width, self.imageView.frame.size.height)];
			[self.textView setTextColor: lastPinchView.textColor];
			[self.textView setTextAlignment:lastPinchView.textAlignment.integerValue];
			if (self.containsVideo) scale = scale * 2;
			[self.textView setFont:[UIFont fontWithName:lastPinchView.fontName size:lastPinchView.textSize.floatValue * scale]];
			[self.background bringSubviewToFront:self.textView];
		}
	}
	if (self.containsVideo) {
		[self.videoView setImage: self.videoImage];
		[self.background bringSubviewToFront:self.videoView];
	}

	[self addEditIcon];
}

-(CGRect) getCenterFrameForVideoView {
	CGRect frame = CGRectMake(self.videoView.bounds.origin.x + self.videoView.bounds.size.width/4.f,
					  self.videoView.bounds.origin.y + self.videoView.bounds.size.height/4.f,
					  self.videoView.bounds.size.width/2.f, self.videoView.bounds.size.height/2.f);
	if (self.numTypesOfMedia > 1) {
		frame = CGRectOffset(frame, 0.f, 20.f);
	}
	return frame;
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
	return [self.pinchedObjects count];
}

-(CollectionPinchView*) pinchAndAdd:(SingleMediaAndTextPinchView*)pinchView {
	self.videoAsset = nil;
	[self.pinchedObjects addObject:pinchView];
	[self addPinchView: pinchView];
	[self renderMedia];
	return self;
}

-(CollectionPinchView*) unPinchAndRemove:(SingleMediaAndTextPinchView*)pinchView {
	self.videoAsset = nil;
	if ([self.pinchedObjects containsObject:pinchView]) {
		[self.pinchedObjects removeObject:pinchView];
	}
	if ([self.imagePinchViews containsObject:pinchView]) {
		[self.imagePinchViews removeObject:pinchView];
	} else if ([self.videoPinchViews containsObject:pinchView]) {
		[self.videoPinchViews removeObject:pinchView];
	}
	[self renderMedia];
	return self;
}

-(void)publishingPinchView{
    for (ImagePinchView* pinchView in self.imagePinchViews) {
        [pinchView publishingPinchView];
    }
}

//overriding
-(NSArray*) getPhotosWithText {
	NSMutableArray* photosWithText = [[NSMutableArray alloc] init];
	for (ImagePinchView* pinchView in self.imagePinchViews) {
		[photosWithText addObject:[(ImagePinchView*)pinchView getPhotosWithText][0]];
	}
	return photosWithText;
}

-(AVAsset*) getVideo {
	NSMutableArray* videoList = [[NSMutableArray alloc] init];
	for (VideoPinchView* pinchView in self.videoPinchViews) {
		[videoList addObject:(VideoPinchView*)pinchView.video];
	}
	if (!self.videoAsset) {
		self.videoAsset = [UtilityFunctions fuseAssets:videoList];
	}
	return self.videoAsset;
}

#pragma mark - Encoding -

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	NSData* pinchViewsData = [NSKeyedArchiver archivedDataWithRootObject:self.pinchedObjects];
	if(pinchViewsData)[coder encodeObject:pinchViewsData forKey:PINCHVIEWS_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		NSData* pinchViewsData = [decoder decodeObjectForKey:PINCHVIEWS_KEY];
		NSArray* pinchViews = [NSKeyedUnarchiver unarchiveObjectWithData:pinchViewsData];
		[self initWithPinchViews:pinchViews];
	}
	return self;
}

#pragma mark - Lazy Instantiation -

-(NSMutableArray*) pinchedObjects {
	if (!_pinchedObjects) _pinchedObjects = [[NSMutableArray alloc] init];
	return _pinchedObjects;
}

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

-(UITextView*) textView {
	if (!_textView) {
		_textView = [[UITextView alloc] init];
		_textView.editable = NO;
		_textView.backgroundColor = [UIColor clearColor];
		_textView.userInteractionEnabled = NO;
	}
	return _textView;
}

@end
