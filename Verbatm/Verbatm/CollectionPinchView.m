//
//  CollectionPinchView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "CollectionPinchView.h"
#import "SizesAndPositions.h"
#import "TextPinchView.h"
#import "ImagePinchView.h"
#import "VideoPinchView.h"

@interface CollectionPinchView()

@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) UIImage* image;
//Can be AVAsset or NSURL
@property (weak, nonatomic) id video;

@end

@implementation CollectionPinchView

-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andPinchViews:(NSArray*)pinchViews {
	self = [super initWithRadius:radius withCenter:center];
	if (self) {
		[self.background addSubview:self.textView];
		[self.background addSubview:self.imageView];
		[self.background addSubview:self.videoView];
		[self.pinchedObjects addObjectsFromArray:pinchViews];
		[self changeTypesOfMedia];
		[self renderMedia];
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

-(VideoPlayerView*)videoView {
	if(!_videoView) _videoView = [[VideoPlayerView alloc] init];
	[_videoView repeatVideoOnEnd:YES];
	return _videoView;
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
		[self.background bringSubviewToFront:self.videoView];
	}else{
		self.imageView.frame = self.background.frame;
		[self.background bringSubviewToFront:self.imageView];
	}
}

//this renders two media in a vertical split view kind of way on the pinch object.
-(void)renderTwoMedia {
	CGRect frame1 = CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y, self.background.frame.size.width/2.f , self.background.frame.size.height);
	CGRect frame2 = CGRectMake(self.background.frame.origin.x + self.background.frame.size.width/2.f, self.background.frame.origin.y, self.background.frame.size.width/2.f, self.background.frame.size.height);
	if(self.containsText){
		self.textView.frame = frame1;
		if(self.containsImage){
			self.imageView.frame = frame2;
		}else{
			self.videoView.frame = frame2;
		}
	}else{
		self.videoView.frame = frame1;
		self.imageView.frame = frame2;
		[self.background bringSubviewToFront:self.videoView];
		[self.background bringSubviewToFront:self.imageView];
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
	if (self.containsText) {
		self.textView.text = self.text;
		[TextPinchView formatTextView:self.textView];
	}
	if (self.containsImage) {
		[self.imageView setImage:self.image];
	}
	if (self.containsVideo) {
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
		[self.videoView muteVideo];
	}
}

#pragma mark - Add and return pinch views -

-(NSInteger) getNumPinchViews {
	return [self.pinchedObjects count];
}

-(void) changeTypesOfMedia {
	for (PinchView* pinchView in self.pinchedObjects) {
		[self changeTypesOfMediaFromPinchView:pinchView];
	}
}

-(void) changeTypesOfMediaFromPinchView:(PinchView*) pinchView {
	if (pinchView.containsText) {
		self.containsText = YES;
		self.text = [self.text stringByAppendingString:[pinchView getText]];
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

-(void) pinchAndAdd:(PinchView*)pinchView {
	[self.pinchedObjects addObject:pinchView];
	[self changeTypesOfMediaFromPinchView:pinchView];
	[self renderMedia];
}

-(void) unPinchAndRemove:(PinchView*)pinchView {
	if ([self.pinchedObjects containsObject:pinchView]) {
		[self.pinchedObjects removeObject:pinchView];
		self.video = Nil;
		self.image = Nil;
		self.text = @"";
		[self changeTypesOfMedia];
	}
	[self renderMedia];
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


@end
