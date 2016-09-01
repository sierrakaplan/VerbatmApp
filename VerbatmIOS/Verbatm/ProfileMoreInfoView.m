//
//  ProfileMoreInfoView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/29/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel.h"
#import "Icons.h"
#import "Notifications.h"
#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>
#import "ProfileMoreInfoView.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "UserInfoCache.h"
#import "UIView+Effects.h"

@interface ProfileMoreInfoView() <UITextViewDelegate>

@property (nonatomic) Channel* channel;
@property (nonatomic) BOOL isCurrentUserProfile;
@property (nonatomic) CGFloat oldYPos;

@property (nonatomic) UILabel *blogDescription;
@property (nonatomic) BOOL editMode;
@property (nonatomic) UITextView *blogDescriptionEditable;
@property (nonatomic) UILabel *blogDescriptionPlaceholder;

@property (nonatomic) UILabel *numFollowersLabel;
@property (nonatomic) UILabel *numFollowingLabel;

@property (nonatomic) UIButton *followersButton;
@property (nonatomic) UIButton *followingButton;

// Only if not current user
@property (nonatomic) BOOL isFollowing;
@property (nonatomic) UIButton *followButton;
@property (nonatomic) UIButton *blockButton;

// Only if current user
@property (nonatomic) NSDictionary *editButtonAttributes;
@property (nonatomic) UIButton *editButton;

#define Y_OFFSET 20.f

#define FOLLOWERS_TITLE_FONT_SIZE 12.f
#define FOLLOWERS_NUMBER_FONT_SIZE 20.f
#define FOLLOWERS_BUTTON_HEIGHT 50.f
#define FOLLOWERS_BUTTON_WIDTH 100.f
#define FOLLOWERS_BUTTON_Y_POS Y_OFFSET

#define DESCRIPTION_Y_POS (FOLLOWERS_BUTTON_Y_POS + FOLLOWERS_BUTTON_HEIGHT + Y_OFFSET)
#define DESCRIPTION_HEIGHT 120.f
#define DESCRIPTION_FONT_SIZE 16.f
#define DESCRIPTION_X_OFFSET 10.f

#define EDIT_BUTTON_HEIGHT 40.f
#define EDIT_BUTTON_FONT_SIZE 14.f
#define EDIT_TEXT @"Edit Bio"
#define DONE_TEXT @"Done Editing"
#define KEYBOARD_HEIGHT 200.f

#define X_OFFSET 20.f
#define BOTTOM_ICON_Y_OFFSET (self.frame.size.height - TAB_BAR_HEIGHT - BLOCK_BUTTON_SIZE - Y_OFFSET)
#define BLOCK_BUTTON_SIZE 30.f

#define DESCRIPTION_MAX_CHARACTERS 200

@end

@implementation ProfileMoreInfoView

-(instancetype) initWithFrame:(CGRect)frame andChannel:(Channel*)channel
		 isCurrentUserProfile:(BOOL)currentUserProfile {
	self = [super initWithFrame:frame];
	if (self) {
		self.oldYPos = frame.origin.y;
		self.channel = channel;
		self.isCurrentUserProfile = currentUserProfile;
		self.clipsToBounds = YES;
		self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.9];
		[self updateNumFollowersAndFollowing];
		self.editMode = NO;
		[self setBlogDescriptionText: channel.blogDescription];
		[self addSubview: self.followersButton];
		[self addSubview: self.followingButton];
		[self addSubview: self.blogDescription];
		if (self.isCurrentUserProfile) {
			[self addSubview: self.editButton];
		} else {
			self.isFollowing = [[UserInfoCache sharedInstance] checkUserFollowsChannel:channel];
			//todo: make sure if you get to your profile from somewhere else that this button isn't here
			[self addSubview: self.followButton];
			[self updateUserFollowingChannel];
			
			[self addSubview: self.blockButton];
		}
		[self registerForFollowNotification];
	}
	return self;
}

-(void) followersButtonPressed {
	[self.delegate followersButtonPressed];
}

-(void) followingButtonPressed {
	[self.delegate followingButtonPressed];
}

-(void) editButtonPressed {
	self.editMode = !self.editMode;
	if (self.editMode) {
		NSAttributedString *title = [[NSAttributedString alloc] initWithString:DONE_TEXT attributes:self.editButtonAttributes];
		[self.editButton setAttributedTitle:title forState:UIControlStateNormal];
		self.blogDescriptionEditable.text = self.blogDescription.text;
		self.editButton.frame = CGRectMake(self.editButton.frame.origin.x, self.blogDescriptionEditable.frame.origin.y +
										   self.blogDescriptionEditable.frame.size.height + Y_OFFSET, self.editButton.frame.size.width,
										   self.editButton.frame.size.height);
		[self.blogDescription removeFromSuperview];
		[self addSubview: self.blogDescriptionEditable];
		[self addSubview: self.blogDescriptionPlaceholder];
		if (self.blogDescriptionEditable.text.length > 0) {
			self.blogDescriptionPlaceholder.hidden = YES;
		}
		//Slide up to be editable with keyboard
		[self animateFrameToYPos:0.f];
		[self.superview bringSubviewToFront:self];
		[self.blogDescriptionEditable becomeFirstResponder];
	} else {
		[self.blogDescriptionEditable resignFirstResponder];
		NSAttributedString *title = [[NSAttributedString alloc] initWithString:EDIT_TEXT attributes:self.editButtonAttributes];
		[self.editButton setAttributedTitle:title forState:UIControlStateNormal];
		NSString *newDescription = self.blogDescriptionEditable.text;
		[self setBlogDescriptionText: newDescription];
		self.editButton.frame = CGRectMake(self.editButton.frame.origin.x, self.blogDescription.frame.origin.y +
										   self.blogDescription.frame.size.height + Y_OFFSET, self.editButton.frame.size.width,
										   self.editButton.frame.size.height);
		[self.channel changeTitle:self.channel.channelName andDescription:self.blogDescriptionEditable.text];
		[self animateFrameToYPos: self.oldYPos];
		[self.blogDescriptionEditable removeFromSuperview];
		[self.blogDescriptionPlaceholder removeFromSuperview];
		[self addSubview: self.blogDescription];
	}
}

-(void) animateFrameToYPos:(CGFloat)yPos {
	[UIView animateWithDuration:0.5f animations:^{
		self.frame = CGRectMake(self.frame.origin.x, yPos, self.frame.size.width, self.frame.size.height);
	}];
}

-(void) setBlogDescriptionText:(NSString*)text {
	self.blogDescription.text = text;
	CGFloat width = self.blogDescription.frame.size.width;
	[self.blogDescription sizeToFit];
	CGRect frame = self.blogDescription.frame;
	frame.size.width = width;
	self.blogDescription.frame = frame;
}

-(void) followButtonPressed {
	self.isFollowing = !self.isFollowing;
	[self.delegate followChannel: self.isFollowing];
	[self.channel currentUserFollowChannel:self.isFollowing];
	[self updateUserFollowingChannel];
}

-(void) blockButtonPressed {
	[self.delegate blockButtonPressed];
}

#pragma mark - Follow status changed -

-(void)registerForFollowNotification {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(userFollowStatusChanged:)
												 name:NOTIFICATION_NOW_FOLLOWING_USER
											   object:nil];
}

-(void)userFollowStatusChanged:(NSNotification *) notification{

	NSDictionary * userInfo = [notification userInfo];
	if(userInfo){
		NSString *userId = userInfo[USER_FOLLOWING_NOTIFICATION_USERINFO_KEY];
		NSNumber *isFollowingAction = userInfo[USER_FOLLOWING_NOTIFICATION_ISFOLLOWING_KEY];
		//only update the follow icon if this is the correct user and also if the action was
		//no registered on this view
		if([userId isEqualToString:[self.channel.channelCreator objectId]]&&
		   ([isFollowingAction boolValue] != self.isFollowing)) {
			self.isFollowing = [isFollowingAction boolValue];
			[self updateUserFollowingChannel];
		}
	}
}

-(void) updateUserFollowingChannel {
	if (self.isFollowing) {
		[self changeFollowButtonTitle:@"Following" toColor:[UIColor blackColor]];
		self.followButton.backgroundColor = [UIColor whiteColor];
	} else {
		[self changeFollowButtonTitle:@"Follow" toColor:[UIColor whiteColor]];
		self.followButton.backgroundColor = [UIColor clearColor];
	}
	[self updateNumFollowersAndFollowing];
}

-(void) changeFollowButtonTitle:(NSString*)title toColor:(UIColor*) color {
	NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: color,
									  NSFontAttributeName: [UIFont fontWithName:BOLD_FONT size:FOLLOW_TEXT_FONT_SIZE]};
	NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:titleAttributes];
	[self.followButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
}

-(void) updateNumFollowersAndFollowing {
	NSString *numFollowers = ((NSNumber*)self.channel.parseChannelObject[CHANNEL_NUM_FOLLOWS]).stringValue;
	NSString *numFollowing = ((NSNumber*)self.channel.parseChannelObject[CHANNEL_NUM_FOLLOWING]).stringValue;

	self.numFollowersLabel.text = numFollowers;
	self.numFollowingLabel.text = numFollowing;
}

#pragma mark - Editing description -

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {

	NSInteger length = textView.text.length + string.length - range.length;
	if([string isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
		[self editButtonPressed];
		return NO;
	}
	if (textView == self.blogDescriptionEditable) {
		return length <= DESCRIPTION_MAX_CHARACTERS;
	}
	return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	if(textView == self.blogDescriptionEditable) {
		self.blogDescriptionPlaceholder.hidden = YES;
	}
}

- (void)textViewDidChange:(UITextView *)textView {
	if(textView == self.blogDescriptionEditable) {
		self.blogDescriptionPlaceholder.hidden = ([textView.text length] > 0);
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	if(textView == self.blogDescriptionEditable) {
		self.blogDescriptionPlaceholder.hidden = ([textView.text length] > 0);
	}
}


#pragma mark - Lazy Instantiation -

-(UIButton*) followersButton {
	if (!_followersButton) {
		CGFloat xPos = self.center.x - FOLLOWERS_BUTTON_WIDTH;
		CGRect frame = CGRectMake(xPos, FOLLOWERS_BUTTON_Y_POS, FOLLOWERS_BUTTON_WIDTH, FOLLOWERS_BUTTON_HEIGHT);
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
								  FOLLOWERS_BUTTON_Y_POS, FOLLOWERS_BUTTON_WIDTH, FOLLOWERS_BUTTON_HEIGHT);
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
		CGRect frame = CGRectMake(0.f, 0.f, FOLLOWERS_BUTTON_WIDTH, FOLLOWERS_BUTTON_HEIGHT/2.f);
		_numFollowersLabel = [self getNumberLabelWithFrame:frame];
	}
	return _numFollowersLabel;
}

-(UILabel*) numFollowingLabel {
	if (!_numFollowingLabel) {
		CGRect frame = CGRectMake(0.f, 0.f, FOLLOWERS_BUTTON_WIDTH, FOLLOWERS_BUTTON_HEIGHT/2.f);
		_numFollowingLabel = [self getNumberLabelWithFrame:frame];
	}
	return _numFollowingLabel;
}

-(NSAttributedString*) getButtonTitleForString:(NSString*)title {
	NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
									  NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:FOLLOWERS_TITLE_FONT_SIZE]};
	NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:titleAttributes];
	return attributedTitle;
}

-(UILabel*) getNumberLabelWithFrame:(CGRect)frame {
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.font = [UIFont fontWithName:REGULAR_FONT size:FOLLOWERS_NUMBER_FONT_SIZE];
	label.textColor = [UIColor whiteColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.adjustsFontSizeToFitWidth = YES;
	return label;
}

-(UILabel*) blogDescription {
	if (!_blogDescription) {
		CGRect frame = CGRectMake(DESCRIPTION_X_OFFSET, DESCRIPTION_Y_POS, self.frame.size.width - DESCRIPTION_X_OFFSET*2,
								  DESCRIPTION_HEIGHT);
		_blogDescription = [[UILabel alloc] initWithFrame:frame];
		_blogDescription.font = [UIFont fontWithName:ITALIC_FONT size:DESCRIPTION_FONT_SIZE];
		_blogDescription.lineBreakMode = NSLineBreakByWordWrapping;
		_blogDescription.numberOfLines = 5;
		_blogDescription.adjustsFontSizeToFitWidth = YES;
		_blogDescription.textColor = [UIColor whiteColor];
	}
	return _blogDescription;
}

-(UITextView *) blogDescriptionEditable {
	if (!_blogDescriptionEditable) {
		CGRect frame = CGRectMake(self.blogDescription.frame.origin.x, self.blogDescription.frame.origin.y,
								  self.blogDescription.frame.size.width, DESCRIPTION_HEIGHT);
		_blogDescriptionEditable = [[UITextView alloc] initWithFrame: frame];
		_blogDescriptionEditable.backgroundColor = [UIColor clearColor];
		_blogDescriptionEditable.layer.borderWidth = 0.5f;
		_blogDescriptionEditable.layer.borderColor = [UIColor whiteColor].CGColor;
		_blogDescriptionEditable.layer.cornerRadius = 5.f;
		_blogDescriptionEditable.text = self.blogDescription.text;
		_blogDescriptionEditable.editable = YES;
		_blogDescriptionEditable.delegate = self;
		_blogDescriptionEditable.font = self.blogDescription.font;
		_blogDescriptionEditable.textColor = [UIColor whiteColor];
		_blogDescriptionEditable.textContainerInset = UIEdgeInsetsMake(0.f, 2.f, 0.f, 0.f);
		_blogDescriptionEditable.textContainer.lineFragmentPadding = 0;
		_blogDescriptionEditable.returnKeyType = UIReturnKeyDone;
	}
	return _blogDescriptionEditable;
}

-(UILabel *) blogDescriptionPlaceholder {
	if (!_blogDescriptionPlaceholder) {
		_blogDescriptionPlaceholder = [[UILabel alloc] initWithFrame: self.blogDescriptionEditable.frame];
		_blogDescriptionPlaceholder.font = [UIFont fontWithName:LIGHT_ITALIC_FONT size:DESCRIPTION_FONT_SIZE];
		[_blogDescriptionPlaceholder setTextColor:[UIColor whiteColor]];
		_blogDescriptionPlaceholder.text = @"Tap here to add a blog description!";
	}
	return _blogDescriptionPlaceholder;
}

-(UIButton*) editButton {
	if (!_editButton) {
		CGRect frame = CGRectMake(0.f, self.blogDescription.frame.origin.y + self.blogDescription.frame.size.height,
								  self.frame.size.width, EDIT_BUTTON_HEIGHT);
		_editButton = [[UIButton alloc] initWithFrame: frame];
		self.editButtonAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.1 green:0.5 blue:1.f alpha:1.f],
											   NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:EDIT_BUTTON_FONT_SIZE]};
		NSAttributedString *title = [[NSAttributedString alloc] initWithString:EDIT_TEXT attributes:self.editButtonAttributes];
		[_editButton setAttributedTitle:title forState:UIControlStateNormal];
		[_editButton addTarget:self action:@selector(editButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _editButton;
}

-(UIButton*) followButton {
	if (!_followButton) {
		CGFloat xPos = self.blockButton.frame.origin.x - X_OFFSET - FOLLOW_BUTTON_WIDTH;
		CGRect frame = CGRectMake(xPos, BOTTOM_ICON_Y_OFFSET,
								  FOLLOW_BUTTON_WIDTH, BLOCK_BUTTON_SIZE);
		_followButton = [[UIButton alloc] initWithFrame:frame];
		_followButton.clipsToBounds = YES;
		_followButton.layer.borderColor = [UIColor whiteColor].CGColor;
		_followButton.layer.borderWidth = 2.f;
		_followButton.layer.cornerRadius = 10.f;
		[_followButton addTarget:self action:@selector(followButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _followButton;
}

-(UIButton*) blockButton {
	if (!_blockButton) {
		CGRect frame = CGRectMake(self.frame.size.width - X_OFFSET - BLOCK_BUTTON_SIZE, BOTTOM_ICON_Y_OFFSET,
								  BLOCK_BUTTON_SIZE, BLOCK_BUTTON_SIZE);
		_blockButton = [[UIButton alloc] initWithFrame: frame];
		_blockButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
		[_blockButton setImage:[UIImage imageNamed:BLOCK_ICON] forState:UIControlStateNormal];
		[_blockButton addTarget:self action:@selector(blockButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _blockButton;
}

@end
