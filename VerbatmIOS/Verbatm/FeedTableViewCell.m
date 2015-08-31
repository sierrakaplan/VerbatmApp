//
//  verbatmArticle_TableViewCell.m
//  Verbatm
//
//  Created by Iain Usiri on 3/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "FeedTableViewCell.h"

@implementation FeedTableViewCell

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		[self formatCell];
	}
	return self;
}

- (void)awakeFromNib {
	[self formatCell];
}

-(void) formatCell {
	[self setBackgroundColor:[UIColor clearColor]];
	[self.textLabel setTextColor:[UIColor whiteColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
