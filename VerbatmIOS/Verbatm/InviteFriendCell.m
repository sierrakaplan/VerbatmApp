//
//  InviteFriendCell.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/9/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "InviteFriendCell.h"
#import "Styles.h"
#import "UIImage+ImageEffectsAndTransforms.h"

@interface InviteFriendCell()

@property (nonatomic) UIButton *selectedButton;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *phoneNumberLabel;

#define X_OFFSET 50.f
#define NAME_FONT_SIZE 18.f
#define NUMBER_FONT_SIZE 12.f

#define RADIO_BUTTON_OFFSET 10.f
#define RADIO_BUTTON_SIZE 20.f


@end

@implementation InviteFriendCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		[self addSubview: self.selectedButton];
		[self addSubview: self.nameLabel];
		[self addSubview: self.phoneNumberLabel];
		self.buttonIsSelected = NO;
	}
	return self;
}

-(void) layoutSubviews {
	self.selectedButton.frame = CGRectMake(RADIO_BUTTON_OFFSET, (self.frame.size.height - RADIO_BUTTON_SIZE)/2.f,
										   RADIO_BUTTON_SIZE, RADIO_BUTTON_SIZE);
	self.nameLabel.frame = CGRectMake(X_OFFSET, 10.f, self.frame.size.width - X_OFFSET, self.frame.size.height/2.f);
	self.phoneNumberLabel.frame = CGRectMake(X_OFFSET, self.frame.size.height/2.f, self.frame.size.width - X_OFFSET, self.frame.size.height/2.f);
}

-(void) setContactName: (NSString*)name andPhoneNumber:(NSString*)phoneNumber {
	self.nameLabel.text = name;
	self.phoneNumberLabel.text = phoneNumber;
}

-(void) toggleButton {
	self.buttonIsSelected = !self.buttonIsSelected;
	if (self.buttonIsSelected) {
		[self.selectedButton setImage:[UIImage makeImageWithColorAndSize:[UIColor blueColor] andSize:self.selectedButton.frame.size]
							 forState:UIControlStateNormal];
	} else {
		[self.selectedButton setImage:[UIImage new] forState:UIControlStateNormal];
	}
}

#pragma mark - Lazy Instantiation -

-(UIButton*) selectedButton {
	if (!_selectedButton) {
		_selectedButton = [[UIButton alloc] init];
		_selectedButton.clipsToBounds = YES;
		_selectedButton.layer.cornerRadius = RADIO_BUTTON_SIZE/2.f;
		_selectedButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
		_selectedButton.layer.borderWidth = 2.f;
	}
	return _selectedButton;
}

-(UILabel*) nameLabel {
	if (!_nameLabel) {
		_nameLabel = [[UILabel alloc] init];
		_nameLabel.font = [UIFont fontWithName:BOLD_FONT size:NAME_FONT_SIZE];
		_nameLabel.textColor = [UIColor blackColor];
	}
	return _nameLabel;
}

-(UILabel*) phoneNumberLabel {
	if (!_phoneNumberLabel) {
		_phoneNumberLabel = [[UILabel alloc] init];
		_phoneNumberLabel.font = [UIFont fontWithName:REGULAR_FONT size:NUMBER_FONT_SIZE];
		_phoneNumberLabel.textColor = [UIColor darkGrayColor];
	}
	return _phoneNumberLabel;
}

@end
