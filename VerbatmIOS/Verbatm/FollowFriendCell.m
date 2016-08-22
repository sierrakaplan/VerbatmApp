//
//  FollowFriendCell.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/20/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "FollowFriendCell.h"
#import "Channel.h"
#import "Follow_BackendManager.h"
#import "SizesAndPositions.h"
#import "Styles.h"

@interface FollowFriendCell()

@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UIButton *followButton;

@property (nonatomic) BOOL isFollowed;
@property (weak, readwrite) Channel *channelBeingPresented;

#define OFFSET 15.f

@end

@implementation FollowFriendCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.isFollowed = NO;
	}
	return self;
}

-(void) layoutSubviews {
	CGFloat height = 40.f; //todo
	CGFloat followButtonWidth = 100.f; //todo:
	self.followButton.frame = CGRectMake(self.frame.size.width - OFFSET - followButtonWidth, OFFSET,
										 followButtonWidth, height);
	self.userNameLabel.frame = CGRectMake(OFFSET, OFFSET, self.frame.size.width - OFFSET*2 - followButtonWidth,
										  height);
}

-(void) presentFriendChannel: (Channel*)friendChannel {
	self.channelBeingPresented = friendChannel;
	[friendChannel getChannelOwnerNameWithCompletionBlock:^(NSString *name) {
		[self.userNameLabel setText: name];
	}];
	[self updateFollowIcon];
	[self addSubview: self.followButton];
	[self addSubview: self.userNameLabel];
}

-(void) followButtonPressed {
	self.isFollowed = !self.isFollowed;
	if (self.isFollowed) {
		[Follow_BackendManager currentUserFollowChannel: self.channelBeingPresented];
	} else {
		[Follow_BackendManager currentUserStopFollowingChannel: self.channelBeingPresented];
	}
	[self updateFollowIcon];
}

-(void) updateFollowIcon {
	if (self.isFollowed) {
		[self changeFollowButtonTitle:@"Following" toColor:[UIColor blackColor]];
		self.followButton.backgroundColor = VERBATM_GOLD_COLOR;
	} else {
		[self changeFollowButtonTitle:@"Follow" toColor:[UIColor whiteColor]];
		self.followButton.backgroundColor = [UIColor clearColor];
	}
}

-(void) changeFollowButtonTitle:(NSString*)title toColor:(UIColor*) color{
	NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: color,
									  NSFontAttributeName: [UIFont fontWithName:BOLD_FONT size: 18.f]}; //todo
	NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:titleAttributes];
	[self.followButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
}

#pragma mark - Lazy Instantiation -

-(UILabel *) userNameLabel {
	if (!_userNameLabel) {
		_userNameLabel = [[UILabel alloc] init];
		[_userNameLabel setAdjustsFontSizeToFitWidth:YES];
		[_userNameLabel setFont:[UIFont fontWithName:REGULAR_FONT size: 24.f]]; //todo
		[_userNameLabel setTextColor: [UIColor whiteColor]];
		[_userNameLabel setTextAlignment: NSTextAlignmentLeft];
	}
	return _userNameLabel;
}

-(UIButton *) followButton {
	if (!_followButton) {
		_followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_followButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
		[_followButton addTarget:self action:@selector(followButtonPressed) forControlEvents:UIControlEventTouchDown];
		_followButton.clipsToBounds = YES;
		_followButton.layer.borderColor = VERBATM_GOLD_COLOR.CGColor;
		_followButton.layer.borderWidth = 3.f;
		_followButton.layer.cornerRadius = 7.f;

	}
	return _followButton;
}

@end
