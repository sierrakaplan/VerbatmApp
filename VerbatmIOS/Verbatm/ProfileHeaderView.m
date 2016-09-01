//
//  ProfileHeaderView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/29/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel.h"
#import "Icons.h"
#import "ProfileHeaderView.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "UIView+Effects.h"

@interface ProfileHeaderView()

@property (nonatomic) BOOL currentUserProfile;
@property (nonatomic) UIImageView *coverPhotoImageView;
@property (nonatomic) UIView *transparentTintCoverView;

@property (nonatomic) NSString *userName;
@property (nonatomic) UILabel *userNameLabel;

@property (nonatomic) UIButton *moreInfoButton;
@property (nonatomic) BOOL moreInfoButtonSelected;
@property (nonatomic) UIButton *addCoverPhotoButton;
@property (nonatomic) UIButton *settingsButton;

#define TEXT_X_OFFSET 10.f

#define USERNAME_Y_OFFSET (STATUS_BAR_HEIGHT + 10.f)
#define USERNAME_HEIGHT 40.f
#define USERNAME_FONT_SIZE 24.f

#define ICON_SIZE 50.f
#define ICON_SPACING 20.f
#define ICON_Y_OFFSET 10.f

#define COVER_PHOTO_BORDER 5.f

@end

@implementation ProfileHeaderView

-(instancetype) initWithFrame:(CGRect)frame andChannel: (Channel*) channel
		 inCurrentUserProfile:(BOOL)currentUserProfile {
	self = [super initWithFrame: frame];
	if (self) {
		self.currentUserProfile = currentUserProfile;
		self.moreInfoButtonSelected = NO;
		self.backgroundColor = [UIColor blackColor];
		[channel loadCoverPhotoWithCompletionBlock:^(UIImage *coverPhoto, NSData *data) {
			if (coverPhoto) {
				[self.coverPhotoImageView setImage: coverPhoto];
			}
		}];
		[self addSubview: self.coverPhotoImageView];
		[channel getChannelOwnerNameWithCompletionBlock:^(NSString *username) {
			self.userName = username;
			[self addSubview: self.userNameLabel];
		}];
		[self addSubview: self.moreInfoButton];
		if (self.currentUserProfile) {
			[self addSubview: self.addCoverPhotoButton];
			[self addSubview: self.settingsButton];
		}

		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapped)];
		[self.coverPhotoImageView addGestureRecognizer: tapGesture];
	}
	return self;
}

-(void) setNewCoverPhoto: (UIImage*)coverPhoto {
	[self.coverPhotoImageView setImage: coverPhoto];
}

-(void) headerTapped {
	[self.delegate headerViewTapped];
}

-(void) moreInfoButtonTapped {
	self.moreInfoButtonSelected = !self.moreInfoButtonSelected;
	[self.delegate moreInfoButtonTapped];
}

-(void) addCoverPhotoButtonTapped {
	[self.delegate addCoverPhotoButtonTapped];
}

-(void) settingsButtonTapped {
	[self.delegate settingsButtonTapped];
}

#pragma mark - Lazy Instantiation -

-(UIImageView*) coverPhotoImageView {
	if (!_coverPhotoImageView) {
		CGRect frame = CGRectMake(COVER_PHOTO_BORDER, STATUS_BAR_HEIGHT, self.bounds.size.width - COVER_PHOTO_BORDER*2,
								  self.bounds.size.height - STATUS_BAR_HEIGHT);
		_coverPhotoImageView = [[UIImageView alloc] initWithFrame: frame];
		[_coverPhotoImageView setImage:[UIImage imageNamed: NO_COVER_PHOTO_IMAGE]];
		_coverPhotoImageView.backgroundColor = [UIColor lightGrayColor];
		_coverPhotoImageView.clipsToBounds = YES;
		_coverPhotoImageView.contentMode = UIViewContentModeScaleAspectFill;
		[_coverPhotoImageView addSubview: self.transparentTintCoverView];
		_coverPhotoImageView.userInteractionEnabled = YES;
	}
	return _coverPhotoImageView;
}

-(UIView *)transparentTintCoverView {
	if(!_transparentTintCoverView) {
		_transparentTintCoverView = [[UIView alloc] initWithFrame: self.bounds];
		_transparentTintCoverView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.3];
	}
	return _transparentTintCoverView;
}

-(UILabel*) userNameLabel {
	if (!_userNameLabel) {
		CGFloat maxWidth = self.frame.size.width - (TEXT_X_OFFSET*2);
		CGRect frame = CGRectMake(TEXT_X_OFFSET, USERNAME_Y_OFFSET,
								  maxWidth, USERNAME_HEIGHT);
		_userNameLabel = [[UILabel alloc] initWithFrame:frame];
		_userNameLabel.font = [UIFont fontWithName:BOLD_FONT size:USERNAME_FONT_SIZE];
		_userNameLabel.textAlignment = NSTextAlignmentCenter;
		_userNameLabel.adjustsFontSizeToFitWidth = YES;
		_userNameLabel.textColor = [UIColor whiteColor];
		_userNameLabel.text = self.userName;
		[_userNameLabel sizeToFit];
		frame = _userNameLabel.frame;
		if (frame.size.width > maxWidth) {
			frame.size.width = maxWidth;
		}
		frame.origin.x = self.frame.size.width - frame.size.width - TEXT_X_OFFSET;
		_userNameLabel.frame = frame;
	}
	return _userNameLabel;
}

-(UIButton*) moreInfoButton {
	if (!_moreInfoButton) {
		CGFloat xOffset = 0.f;
		if (self.currentUserProfile) {
			xOffset = self.addCoverPhotoButton.frame.origin.x - ICON_SIZE;
		} else {
			xOffset = self.frame.size.width - ICON_SIZE;
		}
		_moreInfoButton = [self getBottomIconWithXOffset:xOffset andIcon:[UIImage imageNamed:MORE_INFO_ICON]
											   andAction:@selector(moreInfoButtonTapped)];
	}
	return _moreInfoButton;
}

-(UIButton*) addCoverPhotoButton {
	if (!_addCoverPhotoButton) {
		CGFloat xOffset = self.settingsButton.frame.origin.x - ICON_SIZE;
		_addCoverPhotoButton = [self getBottomIconWithXOffset:xOffset andIcon:[UIImage imageNamed:ADD_COVER_PHOTO_ICON]
													andAction:@selector(addCoverPhotoButtonTapped)];
	}
	return _addCoverPhotoButton;
}

-(UIButton*) settingsButton {
	if (!_settingsButton) {
		CGFloat xOffset = self.frame.size.width - ICON_SIZE;
		_settingsButton = [self getBottomIconWithXOffset:xOffset andIcon:[UIImage imageNamed:SETTINGS_BUTTON_ICON]
											   andAction:@selector(settingsButtonTapped)];
	}
	return _settingsButton;
}

-(UIButton*) getBottomIconWithXOffset:(CGFloat)xOffset andIcon:(UIImage*)icon andAction:(SEL)action {
	CGFloat yPos = self.coverPhotoImageView.frame.size.height + self.coverPhotoImageView.frame.origin.y - ICON_SIZE - ICON_Y_OFFSET;
	CGRect frame = CGRectMake(xOffset, yPos, ICON_SIZE, ICON_SIZE);
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
	button.imageView.contentMode = UIViewContentModeScaleAspectFit;
	button.imageEdgeInsets = UIEdgeInsetsMake(ICON_SPACING, ICON_SPACING, ICON_SPACING, ICON_SPACING);
	[button setImage:icon forState:UIControlStateNormal];
	[button addTarget:self action:action forControlEvents:UIControlEventTouchDown];
	return button;
}

@end
