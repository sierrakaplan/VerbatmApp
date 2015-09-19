//
//  CollectionPinchView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "CollectionPinchView.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "Icons.h"
#import "ImagePinchView.h"
#import "VideoPinchView.h"

@interface CollectionPinchView()

@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) UITextView *textView;

@property (weak, nonatomic) UIImage* image;
@property (strong, nonatomic) UIImageView *imageView;

//Can be AVAsset or NSURL
@property (weak, nonatomic) id video;
@property (strong, nonatomic) UIImageView *playVideoImageView;
@property (strong, nonatomic) UIImage* playVideoIconHalf;
@property (strong, nonatomic) UIImage* playVideoIconQuarter;
@property (strong, nonatomic) UIImage* playVideoIconFull;

#pragma mark Encoding Keys

#define PINCHVIEWS_KEY @"child_pinchviews"

@end

@implementation CollectionPinchView

-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andPinchViews:(NSArray*)pinchViews {
	self = [super initWithRadius:radius withCenter:center];
	if (self) {
		[self initWithPinchViews:pinchViews];
	}
	return self;
}

-(void) initWithPinchViews:(NSArray*)pinchViews {
	self.videoView = [[VideoPlayerWrapperView alloc] initWithFrame:self.background.frame];
	[self.videoView repeatVideoOnEnd:YES];
	[self.background addSubview:self.videoView];
	[self addPlayIcon];
	[self addCollectionViewBorder];
	[self.background addSubview:self.textView];
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
		case 3:
			[self renderThreeMedia];
			break;
		default:
			return;
	}
	[self displayMedia];
}



//This renders a single view on the pinch object
-(void)renderSingleMedia {
	if(self.containsText){
		self.textView.frame = self.background.frame;
	}else if(self.containsVideo){
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
	if(self.containsText) {
		self.textView.frame = frame2;
		if (self.containsImage){
			self.imageView.frame = frame1;
			self.videoView.frame = CGRectMake(0,0,0,0);
		} else {
			self.videoView.frame = frame1;
			self.playVideoImageView.image = self.playVideoIconHalf;
		}
	} else {
		self.videoView.frame = frame1;
		self.playVideoImageView.image = self.playVideoIconHalf;
		self.imageView.frame = frame2;
	}
}


//This renders three views on the pinch view object.
-(void)renderThreeMedia {
	//computation to determine the relative positions of each of the views
	self.textView.frame = CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y, self.background.frame.size.width, self.background.frame.size.height/2.f);
	self.videoView.frame = CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y + self.textView.frame.size.height, self.background.frame.size.width/2.f, self.background.frame.size.height - self.textView.frame.size.height);
	self.imageView.frame = CGRectMake(self.background.frame.origin.x + self.videoView.frame.size.width, self.videoView.frame.origin.y , self.background.frame.size.width - self.videoView.frame.size.width, self.videoView.frame.size.width);

	self.playVideoImageView.image = self.playVideoIconQuarter;
}


//This function displays the media on the view.
-(void)displayMedia {
	self.playVideoImageView.frame = [self getCenterFrameForVideoView];
	self.videoView.videoPlayerView.frame = self.videoView.bounds;
	if (self.containsText) {
		self.textView.text = self.text;
		[self.background bringSubviewToFront:self.textView];
	}
	if (self.containsImage) {
		[self.imageView setImage:self.image];
		[self.background bringSubviewToFront:self.imageView];
	}
	if (self.containsVideo) {
		if (![self.videoView isPlaying]) {
			[self.videoView playVideoFromAsset: self.video];
			[self.videoView pauseVideo];
			[self.videoView muteVideo];
		}
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
	self.text = @"";
	self.image = nil;
	self.video = nil;
	self.containsText = NO;
	self.containsImage = NO;
	self.containsVideo = NO;
	for (PinchView* pinchView in self.pinchedObjects) {
		[self changeTypesOfMediaFromPinchView:pinchView];
	}
}

-(void) changeTypesOfMediaFromPinchView:(PinchView*) pinchView {
	if (pinchView.containsText) {
		self.containsText = YES;
		if ([self.text length]) {
			self.text = [NSString stringWithFormat:@"%@\r\r%@", self.text, [pinchView getText]];
		} else {
			self.text = [self.text stringByAppendingString:[pinchView getText]];
		}
	} else if(pinchView.containsImage) {
		self.containsImage = YES;
		if(!self.image) {
			self.image = [(ImagePinchView*)pinchView getImage];
		}
	} else if(pinchView.containsVideo) {
		self.containsVideo = YES;
		if(!self.video) {
			self.video = [(VideoPinchView*)pinchView video];
		}
	}
}

-(CollectionPinchView*) pinchAndAdd:(PinchView*)pinchView {
	if ([pinchView isKindOfClass:[VideoPinchView class]]) {
		[[(VideoPinchView*)pinchView videoView] stopVideo];
	}
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

-(NSString*) getText {
	return self.text;
}

-(NSArray*) getPhotos {
	NSMutableArray* photos = [[NSMutableArray alloc] init];
	for (PinchView* pinchView in self.pinchedObjects) {
		if(pinchView.containsImage) {
			[photos addObject:[(ImagePinchView*)pinchView getImage]];
		}
	}
	return photos;
}

-(NSArray*) getVideos {
	NSMutableArray* videos = [[NSMutableArray alloc] init];
	for (PinchView* pinchView in self.pinchedObjects) {
		if(pinchView.containsVideo) {
			[videos addObject:[(VideoPinchView*)pinchView video]];
		}
	}
	return videos;
}

-(NSArray*) getVideosInDataFormat {
	NSMutableArray* videos = [[NSMutableArray alloc] init];
	for (PinchView* pinchView in self.pinchedObjects) {
		if(pinchView.containsVideo) {
			AVURLAsset* video = [(VideoPinchView*)pinchView video];
			//TODO: do this in background
			NSData* videoData = [NSData dataWithContentsOfURL: video.URL];
			[videos addObject: videoData];
		}
	}
	return videos;
}


#pragma mark - When pinch view goes on and off screen

-(void)offScreen {
	[self.videoView stopVideo];
}

-(void)onScreen {
	[self displayMedia];
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
		[self initWithPinchViews:pinchViews];
	}
	return self;
}

#pragma mark - Lazy Instantiation -

-(NSMutableArray*) pinchedObjects {
	if(!_pinchedObjects) _pinchedObjects = [[NSMutableArray alloc] init];
	return _pinchedObjects;
}

-(NSString *) text {
	if(!_text) _text = @"";
	return _text;
}

-(UITextView*)textView {
	if(!_textView) _textView = [[UITextView alloc] init];
	return _textView;
}

-(UIImageView*)imageView {
	if(!_imageView) _imageView = [[UIImageView alloc] init];
	_imageView.contentMode = UIViewContentModeScaleAspectFill;
	_imageView.layer.masksToBounds = YES;
	return _imageView;
}

@end
