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

// contains images inside buttons
@property (nonatomic, strong) UIImageView* galleryButtonImageView;
@property (nonatomic, strong) UIImageView* cameraButtonImageView;

// displays plus behind button
@property (nonatomic, strong) UIImageView* galleryButtonPlus;
@property (nonatomic, strong) UIImageView* cameraButtonPlus;

@property (nonatomic, strong) CAShapeLayer * border;

@end

@implementation MediaSelectTile

#pragma mark - initialize view
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setBackgroundColor:[UIColor clearColor]];
		[self createFramesForButtonsWithFrame: frame];
	}
	return self;
}

-(void) createFramesForButtonsWithFrame: (CGRect) frame {
	float buttonOffset = frame.size.height/10.f;
	float size = frame.size.height-buttonOffset*2;
	float xDifference = frame.size.width/4.f - size/2.f;
	float imageOffset = size / 4.f;
	float plusIconSize = size / 4.f;
	float plusIconOffset = 0.f;

	self.galleryButton.frame = CGRectMake(buttonOffset + xDifference, buttonOffset, size, size);
	self.galleryButtonPlus.frame = CGRectMake(self.galleryButton.frame.origin.x - plusIconOffset - plusIconSize,
											  self.galleryButton.frame.origin.y - plusIconOffset,
											  plusIconSize, plusIconSize);
	self.galleryButtonImageView.frame = CGRectMake(imageOffset, imageOffset, size - imageOffset*2, size - imageOffset*2);
	self.galleryButton.layer.cornerRadius = self.galleryButton.frame.size.width/2;
	self.galleryButton.layer.shadowRadius = buttonOffset;

	self.cameraButton.frame = CGRectMake(frame.size.width/2.f + xDifference, buttonOffset, size, size);
	self.cameraButtonPlus.frame = CGRectMake(self.cameraButton.frame.origin.x + self.cameraButton.frame.size.width + plusIconOffset,
											 self.cameraButton.frame.origin.y - plusIconOffset,
											 plusIconSize, plusIconSize);
	self.cameraButtonImageView.frame = CGRectMake(imageOffset, imageOffset, size - imageOffset*2, size - imageOffset*2);
	self.cameraButton.layer.cornerRadius = self.cameraButton.frame.size.width/2;
	self.cameraButton.layer.shadowRadius = buttonOffset;
}

-(void) buttonGlow {
	UIColor* buttonBackgroundColor = [UIColor clearColor];

	[self.galleryButton.layer setBackgroundColor:buttonBackgroundColor.CGColor];
	[self.cameraButton.layer setBackgroundColor:buttonBackgroundColor.CGColor];

	[UIView animateWithDuration:REVEAL_NEW_MEDIA_TILE_ANIMATION_DURATION animations:^{
		self.galleryButton.layer.shadowColor = buttonBackgroundColor.CGColor;
		self.galleryButton.layer.shadowOpacity = 1;
		[self.galleryButton.layer setBackgroundColor:buttonBackgroundColor.CGColor];
		self.galleryButton.layer.borderWidth = 2.f;

		self.cameraButton.layer.shadowColor = buttonBackgroundColor.CGColor;
		self.cameraButton.layer.shadowOpacity = 1;
		[self.cameraButton.layer setBackgroundColor:buttonBackgroundColor.CGColor];
		self.cameraButton.layer.borderWidth = 2.f;
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

- (void) cameraViewButtonPressed {
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
		[_galleryButton addSubview: self.galleryButtonImageView];
		[_galleryButton addTarget:self action:@selector(galleryButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		_galleryButton.layer.borderColor = [UIColor whiteColor].CGColor;
		_galleryButton.clipsToBounds = YES;
		[self addSubview:_galleryButton];
	}

	return _galleryButton;
}

- (UIButton *) cameraButton {
	if(!_cameraButton) {
		_cameraButton = [[UIButton alloc]init];
		[_cameraButton addSubview: self.cameraButtonImageView];
		[_cameraButton addTarget:self action:@selector(cameraViewButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		_cameraButton.layer.borderColor = [UIColor whiteColor].CGColor;
		_cameraButton.clipsToBounds = YES;
		[self addSubview:_cameraButton];
	}

	return _cameraButton;
}

-(UIImageView*) galleryButtonImageView {
	if (!_galleryButtonImageView) {
		_galleryButtonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:GALLERY_BUTTON_ICON]];
		_galleryButtonImageView.contentMode = UIViewContentModeScaleAspectFit;
	}
	return _galleryButtonImageView;
}

-(UIImageView*) cameraButtonImageView {
	if (!_cameraButtonImageView) {
		_cameraButtonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:CAMERA_BUTTON_ICON]];
		_cameraButtonImageView.contentMode = UIViewContentModeScaleAspectFit;
	}
	return _cameraButtonImageView;
}

-(UIImageView*) galleryButtonPlus {
	if (!_galleryButtonPlus) {
		_galleryButtonPlus = [[UIImageView alloc] initWithImage:[UIImage imageNamed:PLUS_ICON]];
		[self addSubview:_galleryButtonPlus];
	}
	return _galleryButtonPlus;
}

-(UIImageView*) cameraButtonPlus {
	if (!_cameraButtonPlus) {
		_cameraButtonPlus = [[UIImageView alloc] initWithImage:[UIImage imageNamed:PLUS_ICON]];
		[self addSubview:_cameraButtonPlus];
	}
	return _cameraButtonPlus;
}

@end
