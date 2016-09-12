//
//  FollowFriendsCell.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/9/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "FollowFriendsCell.h"

@interface FollowFriendsCell()

@property (nonatomic) UITableViewCell *disclosure;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) CGRect disclosureFrame;
@property (nonatomic) CGRect imageViewFrame;

@end

@implementation FollowFriendsCell

-(instancetype) initWithFrame:(CGRect)frame {
	self = [super initWithFrame: frame];
	if (self) {
		self.disclosureFrame = CGRectMake(50.f, 0.f, frame.size.width - 50.f, frame.size.height);
		self.imageViewFrame = CGRectMake(20.f, 15.f, frame.size.height - 30.f,
										 frame.size.height - 30.f);
		self.disclosure = [[UITableViewCell alloc] initWithFrame: self.disclosureFrame];
		self.disclosure.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.disclosure.userInteractionEnabled = NO;
		self.imageView = [[UIImageView alloc] initWithFrame: self.imageViewFrame];
		self.imageView.contentMode = UIViewContentModeScaleAspectFit;

		[self addSubview: self.disclosure];
		[self addSubview: self.imageView];
	}
	return self;
}

-(void) setLabelText:(NSString*)text andImage:(UIImage*)image {
	self.disclosure.textLabel.text = text;
	self.imageView.image = image;
}

-(void) layoutSubviews {
	self.disclosure.frame = self.disclosureFrame;
	self.imageView.frame = self.imageViewFrame;
}

@end
