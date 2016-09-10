//
//  InviteFriendCell.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/9/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "InviteFriendCell.h"
#import "Styles.h"

@interface InviteFriendCell()

@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *phoneNumberLabel;

#define NAME_FONT_SIZE 14.f
#define NUMBER_FONT_SIZE 10.f

#define X_OFFSET 50.f

@end

@implementation InviteFriendCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		[self addSubview: self.nameLabel];
		[self addSubview: self.phoneNumberLabel];
	}
	return self;
}

-(void) layoutSubviews {
	self.nameLabel.frame = CGRectMake(X_OFFSET, 0.f, self.frame.size.width - X_OFFSET, self.frame.size.height/2.f);
	self.phoneNumberLabel.frame = CGRectMake(X_OFFSET, 0.f, self.frame.size.width - X_OFFSET, self.frame.size.height/2.f);
}

-(void) setContactName: (NSString*)name andPhoneNumber:(NSString*)phoneNumber {
	self.nameLabel.text = name;
	self.phoneNumberLabel.text = phoneNumber;
}

#pragma mark - Lazy Instantiation -

-(UILabel*) nameLabel {
	if (!_nameLabel) {
		_nameLabel = [[UILabel alloc] init];
		_nameLabel.font = [UIFont fontWithName:REGULAR_FONT size:NAME_FONT_SIZE];
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
