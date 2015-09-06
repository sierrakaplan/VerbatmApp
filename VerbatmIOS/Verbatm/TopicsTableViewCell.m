//
//  TopicsTableViewCell.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/6/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "TopicsTableViewCell.h"

@interface TopicsTableViewCell()

@property (strong, nonatomic) UILabel * topicTitle;

@end

@implementation TopicsTableViewCell

- (void)awakeFromNib {
    // Initialization code if made in storyboard
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void) layoutSubviews {
	[super layoutSubviews];
	[self formatSelf];
	[self formatTextSubview];
}

-(void) formatSelf {
	[self setBackgroundColor:[UIColor clearColor]];
}

-(void) formatTextSubview {

}


#pragma mark - Set Content -

-(void) setContentWithTitle:(NSString*) title {

}

@end
