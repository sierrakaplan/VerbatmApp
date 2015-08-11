//
//  verbatmArticle_TableViewCell.m
//  Verbatm
//
//  Created by Iain Usiri on 3/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "FeedTableViewCell.h"
#import "SizesAndPositions.h"
#import "Styles.h"

@interface FeedTableViewCell()
@property (strong, nonatomic) UILabel * articleTitle;
@property (strong, nonatomic) UILabel * artileAuthorUsername;
@end

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

-(void)setContentWithUsername:(NSString *) username andTitle: (NSString *) title {
    self.articleTitle.text = title;
    self.artileAuthorUsername.text = username;
    [self addSubview:self.articleTitle];
    [self addSubview:self.artileAuthorUsername];
    [self setViewFrames];
}

-(void)setViewFrames{
    
 
    //set frames
    [self.articleTitle setFrame:CGRectMake(FEED_TEXT_X_OFFSET, FEED_TEXT_GAP, self.frame.size.width, TITLE_LABLE_HEIGHT)];
    [self.artileAuthorUsername setFrame:CGRectMake(FEED_TEXT_X_OFFSET, TITLE_LABLE_HEIGHT + 2*FEED_TEXT_GAP, self.frame.size.width, USERNAME_LABLE_HEIGHT)];
    
    //set text font formating
    [self.articleTitle setFont:[UIFont fontWithName:USERNAME_FONT_TYPE size:TITLE_FONT_SIZE]];
    [self.articleTitle setTextColor:[UIColor USERNAME_TEXT_COLOR]];
    self.articleTitle.backgroundColor = [UIColor clearColor];
    
    [self.artileAuthorUsername setFont:[UIFont fontWithName:USERNAME_FONT_TYPE size:USERNAME_FONT_SIZE]];
    [self.artileAuthorUsername setTextColor:[UIColor TITLE_TEXT_COLOR]];
    self.artileAuthorUsername.backgroundColor = [UIColor clearColor];
}


-(UILabel *) articleTitle{
    if(!_articleTitle)_articleTitle = [[UILabel alloc]init];
    return _articleTitle;
}
-(UILabel *) artileAuthorUsername{
    if(!_artileAuthorUsername)_artileAuthorUsername = [[UILabel alloc]init];
    return _artileAuthorUsername;
}


-(void) formatCell {
	[self setBackgroundColor:[UIColor clearColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
