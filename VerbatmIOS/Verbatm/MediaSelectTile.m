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
@property(nonatomic ,strong) UIButton * addMediaButton;
@property (nonatomic, strong) CAShapeLayer * border;
@property (readwrite, nonatomic) BOOL optionSelected;
@end

@implementation MediaSelectTile
#pragma mark - initialize view
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {

		[self createFramesForButtonWithFrame: frame];
		[self createImagesForButton];
		[self addSubview: self.addMediaButton];
		[self setBackgroundColor:[UIColor clearColor]];
	}
	return self;
}

-(void) createFramesForButtonWithFrame: (CGRect) frame {
	float buttonOffset = frame.size.height/10.f;
	float size = frame.size.height-buttonOffset*2;

	self.addMediaButton.frame = CGRectMake(frame.size.width/2.f - size/2.f, buttonOffset, size, size);
	self.addMediaButton.layer.cornerRadius = self.addMediaButton.frame.size.width/2;
	self.addMediaButton.layer.shadowRadius = buttonOffset;
}

-(void) createImagesForButton {
	UIImage *addMediaImage = [UIImage imageNamed:PLUS_ICON];
	[self.addMediaButton setImage:addMediaImage forState: UIControlStateNormal];
}

-(void) formatButton {
	[self.addMediaButton.layer setBackgroundColor:[UIColor clearColor].CGColor];

	UIColor* buttonBackgroundColor = [UIColor clearColor];

	[UIView animateWithDuration:REVEAL_NEW_MEDIA_TILE_ANIMATION_DURATION animations:^{
		self.addMediaButton.layer.shadowColor = buttonBackgroundColor.CGColor;
		self.addMediaButton.layer.shadowOpacity = 1;
		[self.addMediaButton.layer setBackgroundColor:buttonBackgroundColor.CGColor];
	} completion:^(BOOL finished) {
	}];
}


- (void) addMedia {
	self.optionSelected = YES;
	[self.delegate addMediaButtonPressedOnTile:self];
}

-(void) buttonHighlight: (UIButton*) button {
	[button setBackgroundColor:[UIColor whiteColor]];
}

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


#pragma mark - *Lazy Instantiation
- (UIButton *) addMediaButton {
	if(!_addMediaButton) {
		_addMediaButton = [[UIButton alloc]init];
		[_addMediaButton addTarget:self action:@selector(addMedia) forControlEvents:UIControlEventTouchUpInside];
	}

	return _addMediaButton;
}


@end
