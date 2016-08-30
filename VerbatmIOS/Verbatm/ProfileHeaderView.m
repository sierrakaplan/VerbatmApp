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
@property (nonatomic) CALayer *moreInfoButtonBorder;

#define TEXT_X_OFFSET 10.f

#define USERNAME_Y_OFFSET 100.f
#define USERNAME_HEIGHT 40.f
#define USERNAME_FONT_SIZE 24.f

#define MORE_INFO_BUTTON_SIZE 40.f
#define MORE_INFO_BUTTON_SPACING 5.f

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
	}
	return self;
}

-(void) moreInfoButtonTapped {
	self.moreInfoButtonSelected = !self.moreInfoButtonSelected;
	if (self.moreInfoButtonSelected) {
		self.moreInfoButton.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.3];
	} else {
		self.moreInfoButton.backgroundColor = [UIColor clearColor];
	}
	[self.delegate moreInfoButtonTapped];
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
		CGFloat maxWidth = self.frame.size.width - (TEXT_X_OFFSET + MORE_INFO_BUTTON_SIZE + MORE_INFO_BUTTON_SPACING);
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
		_userNameLabel.frame = frame;
	}
	return _userNameLabel;
}

-(UIButton*) moreInfoButton {
	if (!_moreInfoButton) {
		CGRect frame = CGRectMake(self.userNameLabel.frame.origin.x + self.userNameLabel.frame.size.width +
								  MORE_INFO_BUTTON_SPACING,
								  self.userNameLabel.center.y - MORE_INFO_BUTTON_SIZE/2.f, MORE_INFO_BUTTON_SIZE,
								  MORE_INFO_BUTTON_SIZE);
		_moreInfoButton = [[UIButton alloc] initWithFrame: frame];
		_moreInfoButton.layer.borderColor = [UIColor whiteColor].CGColor;
		_moreInfoButton.contentEdgeInsets = UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f);
		_moreInfoButton.layer.borderWidth = 2.f;
		_moreInfoButton.layer.cornerRadius = 10.f;
		_moreInfoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
		[_moreInfoButton setImage:[UIImage imageNamed:MORE_INFO_ICON] forState:UIControlStateNormal];
		[_moreInfoButton addTarget:self action:@selector(moreInfoButtonTapped) forControlEvents:UIControlEventTouchDown];
	}
	return _moreInfoButton;
}

@end
