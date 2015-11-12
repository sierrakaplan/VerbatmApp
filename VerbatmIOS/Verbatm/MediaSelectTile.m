//
//  verbatmCustomMediaSelectTile.m
//  Verbatm
//
//  Created by Iain Usiri on 9/14/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "MediaSelectTile.h"
#import "DashLineView.h"
#import "Notifications.h"
#import "Icons.h"
#import "Styles.h"
#import "Durations.h"
#import "SizesAndPositions.h"
#import "ContentDevVC.h"

@interface MediaSelectTile ()

// buttons
@property (nonatomic, strong) UIButton* galleryButton;
@property (nonatomic, strong) UIButton* cameraButton;

@property (nonatomic, strong) CAShapeLayer * border;

@end

@implementation MediaSelectTile

#pragma mark - initialize view
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self createFramesForButtonsWithFrame: frame];
		[self createImagesForButtons];
		[self addSubview: self.galleryButton];
		[self addSubview: self.cameraButton];
		[self setBackgroundColor:[UIColor clearColor]];
	}
	return self;
}

-(void) createFramesForButtonsWithFrame: (CGRect) frame {
	float buttonOffset = frame.size.height/10.f;
	float size = frame.size.height-buttonOffset*2;
	float xDifference = frame.size.width/4.f - size/2.f;

	self.galleryButton.frame = CGRectMake(buttonOffset + xDifference, buttonOffset, size, size);
	self.galleryButton.layer.cornerRadius = self.galleryButton.frame.size.width/2;
	self.galleryButton.layer.shadowRadius = buttonOffset;

	self.cameraButton.frame = CGRectMake(frame.size.width/2.f + xDifference, buttonOffset, size, size);
	self.cameraButton.layer.cornerRadius = self.cameraButton.frame.size.width/2;
	self.cameraButton.layer.shadowRadius = buttonOffset;
}

-(void) createImagesForButtons {
	UIImage *galleryImage = [UIImage imageNamed:GALLERY_BUTTON_ICON];
	[self.galleryButton setImage:galleryImage forState: UIControlStateNormal];
	self.galleryButton.imageView.contentMode = UIViewContentModeScaleAspectFit;

	UIImage *cameraImage = [UIImage imageNamed:CAMERA_BUTTON_ICON];
	[self.cameraButton setImage:cameraImage forState: UIControlStateNormal];
	self.cameraButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

-(void) formatButtons {
	UIColor* buttonBackgroundColor = [UIColor clearColor];

	[self.galleryButton.layer setBackgroundColor:buttonBackgroundColor.CGColor];
	[self.cameraButton.layer setBackgroundColor:buttonBackgroundColor.CGColor];

	[UIView animateWithDuration:REVEAL_NEW_MEDIA_TILE_ANIMATION_DURATION animations:^{
		self.galleryButton.layer.shadowColor = buttonBackgroundColor.CGColor;
		self.galleryButton.layer.shadowOpacity = 1;
		[self.galleryButton.layer setBackgroundColor:buttonBackgroundColor.CGColor];

		self.cameraButton.layer.shadowColor = buttonBackgroundColor.CGColor;
		self.cameraButton.layer.shadowOpacity = 1;
		[self.cameraButton.layer setBackgroundColor:buttonBackgroundColor.CGColor];
	} completion:^(BOOL finished) {
	}];
}

-(void) buttonHighlight: (UIButton*) button {
	[button setBackgroundColor:[UIColor whiteColor]];
}

#pragma mark - Buttons Pressed -

- (void) galleryButtonPressed {
	[self.delegate galleryButtonPressedOnTile:self];
}

- (void) cameraButtonPressed {
	[self.delegate cameraButtonPressedOnTile:self];
}

#pragma mark - Content Dev Element Delegate methods (selected, deleting) -

-(void)markAsSelected: (BOOL) selected {
	if (selected) {
		self.layer.borderColor = [UIColor SELECTED_ITEM_COLOR].CGColor;
		self.layer.borderWidth = 2.0f;
	} else {
		self.layer.borderWidth = 0.f;
	}
}

-(void)markAsDeleting: (BOOL) deleting {
	if (deleting) {
		self.layer.borderColor = [UIColor DELETING_ITEM_COLOR].CGColor;
		self.layer.borderWidth = 2.0f;
	} else {
		self.layer.borderWidth = 0.f;
	}
}

#pragma mark - Lazy Instantiation -

- (UIButton *) galleryButton {
	if(!_galleryButton) {
		_galleryButton = [[UIButton alloc]init];
		[_galleryButton addTarget:self action:@selector(galleryButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}

	return _galleryButton;
}

- (UIButton *) cameraButton {
	if(!_cameraButton) {
		_cameraButton = [[UIButton alloc]init];
		[_cameraButton addTarget:self action:@selector(cameraButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}

	return _cameraButton;
}

@end
