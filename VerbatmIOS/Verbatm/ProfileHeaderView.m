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
#import "Styles.h"

@interface ProfileHeaderView()

@property (nonatomic) UIImageView *coverPhotoImageView;
@property (nonatomic) UIView *transparentTintCoverView;
@property (nonatomic) NSString *userName;
@property (nonatomic) UILabel *userNameLabel;
@property (nonatomic) UIButton *moreInfoButton;

#define TEXT_X_OFFSET 10.f

#define USERNAME_Y_OFFSET 50.f
#define USERNAME_HEIGHT 40.f
#define USERNAME_FONT_SIZE 24.f

#define MORE_INFO_BUTTON_SIZE 30.f
#define MORE_INFO_BUTTON_SPACING 5.f

@end

@implementation ProfileHeaderView

-(instancetype) initWithFrame:(CGRect)frame andChannel: (Channel*) channel {
	self = [super initWithFrame: frame];
	if (self) {
		[channel loadCoverPhotoWithCompletionBlock:^(UIImage *coverPhoto, NSData *data) {
			[self.coverPhotoImageView setImage: coverPhoto];
		}];
		[self addSubview: self.coverPhotoImageView];
		[self addSubview: self.transparentTintCoverView];
		[channel getChannelOwnerNameWithCompletionBlock:^(NSString *username) {
			self.userName = username;
			[self addSubview: self.userNameLabel];
		}];
		[self addSubview: self.moreInfoButton];
	}
	return self;
}

-(void) moreInfoButtonTapped {
	[self.delegate moreInfoButtonTapped];
}

#pragma mark - Lazy Instantiation -

-(UIImageView*) coverPhotoImageView {
	if (!_coverPhotoImageView) {
		_coverPhotoImageView = [[UIImageView alloc] initWithFrame: self.bounds];
		_coverPhotoImageView.backgroundColor = [UIColor lightGrayColor];
		_coverPhotoImageView.clipsToBounds = YES;
		_coverPhotoImageView.contentMode = UIViewContentModeScaleAspectFill;
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
		CGFloat xOffset = TEXT_X_OFFSET + MORE_INFO_BUTTON_SIZE + MORE_INFO_BUTTON_SPACING;
		CGFloat maxWidth = self.frame.size.width - xOffset*2;
		CGRect frame = CGRectMake(xOffset, USERNAME_Y_OFFSET,
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
		frame.origin.x = self.center.x - (frame.size.width + MORE_INFO_BUTTON_SIZE + MORE_INFO_BUTTON_SPACING)/2.f;
		_userNameLabel.frame = frame;
	}
	return _userNameLabel;
}

-(UIButton*) moreInfoButton {
	if (!_moreInfoButton) {
		CGRect frame = CGRectMake(self.userNameLabel.frame.origin.x + self.userNameLabel.frame.size.width +
								  MORE_INFO_BUTTON_SPACING,
								  self.userNameLabel.frame.origin.y, MORE_INFO_BUTTON_SIZE, MORE_INFO_BUTTON_SIZE);
		_moreInfoButton = [[UIButton alloc] initWithFrame: frame];
		_moreInfoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
		[_moreInfoButton setImage:[UIImage imageNamed:MORE_INFO_ICON] forState:UIControlStateNormal];
		[_moreInfoButton addTarget:self action:@selector(moreInfoButtonTapped) forControlEvents:UIControlEventTouchDown];
	}
	return _moreInfoButton;
}

@end
