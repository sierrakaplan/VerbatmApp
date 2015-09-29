//
//  TopicsTableViewCell.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/6/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "TopicsTableViewCell.h"
#import "SizesAndPositions.h"
#import "Styles.h"

@interface TopicsTableViewCell()

@property (strong, nonatomic) UIView * topicTextView;
@property (strong, nonatomic) UILabel * topicTitle;

@end

@implementation TopicsTableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
	if (self) {
	}
	return self;
}

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
	CGRect topicTextViewFrame = CGRectMake(TOPIC_CELL_PADDING, TOPIC_CELL_PADDING,
										   self.frame.size.width - TOPIC_CELL_PADDING*2, self.frame.size.height - TOPIC_CELL_PADDING);
	self.topicTextView = [[UIView alloc] initWithFrame:topicTextViewFrame];
	[self.topicTextView setBackgroundColor:[UIColor STORY_BACKGROUND_COLOR]];

	[self.topicTitle setFrame: CGRectMake(FEED_TEXT_X_OFFSET,
										   FEED_TEXT_GAP,
										   topicTextViewFrame.size.width - FEED_TEXT_X_OFFSET*2,
										   TITLE_LABEL_HEIGHT)];

	[self formatUILabel:self.topicTitle
			   withFont: [UIFont fontWithName:TITLE_FONT size:FEED_TITLE_FONT_SIZE]
		   andTextColor: [UIColor TITLE_TEXT_COLOR]
	   andNumberOfLines: 4];

	[self.topicTextView addSubview: self.topicTitle];
	[self addSubview: self.topicTextView];
}

-(void) formatUILabel: (UILabel*)label withFont: (UIFont*)font andTextColor: (UIColor*) textColor
	 andNumberOfLines: (NSInteger) numLines {
	[label setFont:font];
	[label setTextColor:textColor];
	[label setLineBreakMode: NSLineBreakByWordWrapping];
	[label setNumberOfLines: numLines];
	[label sizeToFit];
	[label setFrame: CGRectMake(label.frame.origin.x, label.frame.origin.y,
								self.topicTextView.frame.size.width - FEED_TEXT_X_OFFSET*2,
								label.frame.size.height)];
	[label setTextAlignment: NSTextAlignmentCenter];
	label.backgroundColor = [UIColor clearColor];
}


#pragma mark - Set Content -

-(void) setContentWithTitle:(NSString*) title {
	self.topicTitle.text = title;
}

#pragma mark - Lazy Instantiation -

-(UILabel *) topicTitle {
	if(!_topicTitle) _topicTitle = [[UILabel alloc]init];
	return _topicTitle;
}

@end
