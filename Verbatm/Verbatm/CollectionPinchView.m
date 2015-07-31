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
#import "TextPinchView.h"
#import "ImagePinchView.h"
#import "VideoPinchView.h"

@interface CollectionPinchView()

@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImageView *playVideoImageView;
@property (weak, nonatomic) UIImage* image;
//Can be AVAsset or NSURL
@property (weak, nonatomic) id video;

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
	UIImage* playIconImage = [UIImage imageNamed: PLAY_VIDEO_ICON];
	self.playVideoImageView = [[UIImageView alloc] initWithImage:playIconImage];
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
		self.layer.shadowColor = [UIColor DELETING_ITEM_COLOR].CGColor;
	} else {
		self.layer.borderColor = [UIColor PINCHVIEW_BORDER_COLOR].CGColor;
		self.layer.shadowColor = [UIColor PINCHVIEW_BORDER_COLOR].CGColor;
	}
}

-(void)markAsSelected: (BOOL) selected {
	if (selected) {
		self.layer.borderColor = [UIColor SELECTED_ITEM_COLOR].CGColor;
		self.layer.shadowColor = [UIColor SELECTED_ITEM_COLOR].CGColor;
	} else {
		self.layer.borderColor = [UIColor PINCHVIEW_BORDER_COLOR].CGColor;
		self.layer.shadowColor = [UIColor PINCHVIEW_BORDER_COLOR].CGColor;
	}
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
	_imageView.contentMode = UIViewContentModeCenter;
	_imageView.layer.masksToBounds = YES;
	return _imageView;
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
		}
	} else {
		self.videoView.frame = frame1;
		self.imageView.frame = frame2;
	}
}


//This renders three views on the pinch view object.
-(void)renderThreeMedia {
	//computation to determine the relative positions of each of the views
	self.textView.frame = CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y, self.background.frame.size.width, self.background.frame.size.height/2.f);
	self.imageView.frame = CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y + self.textView.frame.size.height, self.background.frame.size.width/2.f, self.background.frame.size.height - self.textView.frame.size.height);
	self.videoView.frame = CGRectMake(self.background.frame.origin.x + self.imageView.frame.size.width, self.imageView.frame.origin.y , self.background.frame.size.width - self.imageView.frame.size.width, self.imageView.frame.size.width);
}


//This function displays the media on the view.
-(void)displayMedia {
	self.playVideoImageView.frame = self.videoView.bounds;
	self.videoView.videoPlayerView.frame = self.videoView.bounds;
	if (self.containsText) {
		self.textView.text = self.text;
		[TextPinchView formatTextView:self.textView];
		[self.background bringSubviewToFront:self.textView];
	}
	if (self.containsImage) {
		[self.imageView setImage:self.image];
		[self.background bringSubviewToFront:self.imageView];
	}
	if (self.containsVideo) {
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
		[self.background bringSubviewToFront:self.videoView];
	}
}

#pragma mark - Add and return pinch views -

-(NSInteger) getNumPinchViews {
	return [self.pinchedObjects count];
}

-(void) updateMedia {
	self.text = @"";
	self.image = Nil;
	self.video = Nil;
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
			self.videoFormat = [(VideoPinchView*)pinchView videoFormat];
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

@end
