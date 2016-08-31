//
//  ProfileMoreInfoView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/29/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "ProfileMoreInfoView.h"
#import "Styles.h"
#import "UIView+Effects.h"

@interface ProfileMoreInfoView()

@property (nonatomic) UILabel *blogDescription;
@property (nonatomic) UILabel *numFollowersLabel;
@property (nonatomic) UILabel *numFollowingLabel;
@property (nonatomic) UIButton *followersButton;
@property (nonatomic) UIButton *followingButton;

#define FOLLOW_TITLE_FONT_SIZE 12.f
#define FOLLOW_NUMBER_FONT_SIZE 20.f
#define FOLLOW_BUTTON_HEIGHT 50.f
#define FOLLOW_BUTTON_WIDTH 100.f
#define FOLLOW_BUTTON_Y_POS 20.f

#define DESCRIPTION_Y_POS (FOLLOW_BUTTON_Y_POS + FOLLOW_BUTTON_HEIGHT + 20.f)
#define DESCRIPTION_FONT_SIZE 16.f
#define DESCRIPTION_X_OFFSET 10.f

@end

@implementation ProfileMoreInfoView

-(instancetype) initWithFrame:(CGRect)frame andNumFollowers:(NSNumber*)numFollowers
			  andNumFollowing:(NSNumber*)numFollowing andDescription:(NSString*)description {
	self = [super initWithFrame:frame];
	if (self) {
		self.clipsToBounds = YES;
		self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.9];
		self.numFollowersLabel.text = numFollowers.stringValue;
		self.numFollowingLabel.text = numFollowing.stringValue;
		self.blogDescription.text = description;
		[self.blogDescription sizeToFit];
		[self addSubview: self.followersButton];
		[self addSubview: self.followingButton];
		[self addSubview: self.blogDescription];
	}
	return self;
}
//todo: listen to notification about new follower

-(void) followersButtonPressed {
	[self.delegate followersButtonPressed];
}

-(void) followingButtonPressed {
	[self.delegate followingButtonPressed];
}

#pragma mark - Lazy Instantiation -

-(UIButton*) followersButton {
	if (!_followersButton) {
		CGFloat xPos = self.center.x - FOLLOW_BUTTON_WIDTH;
		CGRect frame = CGRectMake(xPos, FOLLOW_BUTTON_Y_POS, FOLLOW_BUTTON_WIDTH, FOLLOW_BUTTON_HEIGHT);
		_followersButton = [[UIButton alloc] initWithFrame:frame];
		_followersButton.backgroundColor = [UIColor clearColor];
		[_followersButton setAttributedTitle:[self getButtonTitleForString:@"FOLLOWERS"] forState:UIControlStateNormal];
		[_followersButton addTarget:self action:@selector(followersButtonPressed) forControlEvents:UIControlEventTouchDown];
		[_followersButton addSubview: self.numFollowersLabel];
		[_followersButton addRightBorderWithColor:[UIColor whiteColor] andWidth:1.f];
		_followersButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
	}
	return _followersButton;
}

-(UIButton*) followingButton {
	if (!_followingButton) {
		CGRect frame = CGRectMake(self.followersButton.frame.origin.x + self.followersButton.frame.size.width,
								  FOLLOW_BUTTON_Y_POS, FOLLOW_BUTTON_WIDTH, FOLLOW_BUTTON_HEIGHT);
		_followingButton = [[UIButton alloc] initWithFrame:frame];
		_followingButton.backgroundColor = [UIColor clearColor];
		[_followingButton setAttributedTitle:[self getButtonTitleForString:@"FOLLOWING"] forState:UIControlStateNormal];
		[_followingButton addTarget:self action:@selector(followingButtonPressed) forControlEvents:UIControlEventTouchDown];
		[_followingButton addSubview: self.numFollowingLabel];
		_followingButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
	}
	return _followingButton;
}

-(UILabel*) numFollowersLabel {
	if (!_numFollowersLabel) {
		CGRect frame = CGRectMake(0.f, 0.f, FOLLOW_BUTTON_WIDTH, FOLLOW_BUTTON_HEIGHT/2.f);
		_numFollowersLabel = [self getNumberLabelWithFrame:frame];
	}
	return _numFollowersLabel;
}

-(UILabel*) numFollowingLabel {
	if (!_numFollowingLabel) {
		CGRect frame = CGRectMake(0.f, 0.f, FOLLOW_BUTTON_WIDTH, FOLLOW_BUTTON_HEIGHT/2.f);
		_numFollowingLabel = [self getNumberLabelWithFrame:frame];
	}
	return _numFollowingLabel;
}

-(NSAttributedString*) getButtonTitleForString:(NSString*)title {
	NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
									  NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:FOLLOW_TITLE_FONT_SIZE]};
	NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:titleAttributes];
	return attributedTitle;
}

-(UILabel*) getNumberLabelWithFrame:(CGRect)frame {
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.font = [UIFont fontWithName:REGULAR_FONT size:FOLLOW_NUMBER_FONT_SIZE];
	label.textColor = [UIColor whiteColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.adjustsFontSizeToFitWidth = YES;
	return label;
}

-(UILabel*) blogDescription {
	if (!_blogDescription) {
		CGRect frame = CGRectMake(DESCRIPTION_X_OFFSET, DESCRIPTION_Y_POS, self.frame.size.width - DESCRIPTION_X_OFFSET*2,
								  self.frame.size.height - DESCRIPTION_Y_POS);
		_blogDescription = [[UILabel alloc] initWithFrame:frame];
		_blogDescription.font = [UIFont fontWithName:ITALIC_FONT size:DESCRIPTION_FONT_SIZE];
		_blogDescription.lineBreakMode = NSLineBreakByWordWrapping;
		_blogDescription.numberOfLines = 5;
		_blogDescription.adjustsFontSizeToFitWidth = YES;
		_blogDescription.textColor = [UIColor whiteColor];
	}
	return _blogDescription;
}

@end
