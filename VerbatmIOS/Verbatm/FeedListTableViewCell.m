//
//  FeedListTableViewCell.m
//  Verbatm
//
//  Created by Iain Usiri on 8/23/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "FeedListTableViewCell.h"
#import "ParseBackendKeys.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import <Parse/PFUser.h>

@interface FeedListTableViewCell ()

@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel * channelNameLabel;
@property (nonatomic) UIView * selectionDot;
@property (nonatomic) UIView * cellSeperator;
@property (nonatomic) BOOL isSelected;

#define MAX_WIDTH (self.frame.size.width - (self.selectionDot.frame.origin.x  + SELECTION_DOT_SIZE + (2* XOFFSET)))

#define SELECTION_DOT_SIZE  12.f
#define XOFFSET 15.f
#define SEPERATOR_HEIGHT 0.3
@end

@implementation FeedListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)presentCellSeperator{
    if(!self.cellSeperator){
        self.cellSeperator = [[UIView alloc] initWithFrame:CGRectMake(-4.f, self.frame.size.height - SEPERATOR_HEIGHT, self.frame.size.width + 6.f, SEPERATOR_HEIGHT)];
        self.cellSeperator.backgroundColor = [UIColor darkGrayColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.cellSeperator];
    }
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier] ;
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

-(void)layoutSubviews{
    [self presentCellSeperator];
}


-(void)presentChannel:(Channel *) channel isSelected:(BOOL) isSelected{
    [self clearView];
    self.isSelected = isSelected;
    self.currentChannel = channel;
    [self createLabelsFromChannel:channel isSelected:isSelected];
}

-(void)createLabelsFromChannel:(Channel *)channel isSelected:(BOOL) isSelected{
    NSString * creatorName = channel.userName;
    [self setLabelForUserName: creatorName];
    [self setSelctionDotAsSelected:isSelected];

 
}

-(void)setSelctionDotAsSelected:(BOOL)selected{
    self.selectionDot.backgroundColor = (selected) ? [UIColor SELECTION_DOT_COLOR] : [UIColor clearColor];
}

-(void)clearView{
    [self.nameLabel removeFromSuperview];
    [self.channelNameLabel removeFromSuperview];
    [self.selectionDot removeFromSuperview];
    self.selectionDot = nil;
    self.nameLabel = nil;
    self.channelNameLabel = nil;
}

-(void) setLabelForUserName:(NSString *) userName {
    
    [self clearView];
    CGFloat xPos = self.selectionDot.frame.origin.x + self.selectionDot.frame.size.width + TAB_BUTTON_PADDING_X;
    CGPoint nameLabelOrigin = CGPointMake(xPos,TAB_BUTTON_PADDING_Y);

    self.nameLabel = [self getLabel:userName withOrigin:nameLabelOrigin andAttributes:[self getUserNameAttributes] withMaxWidth:MAX_WIDTH];
    
    [self.nameLabel setFrame:CGRectMake(xPos, self.nameLabel.frame.origin.y, self.nameLabel.frame.size.width, self.frame.size.height)];
    [self addSubview: self.nameLabel];
    
}

-(UILabel *) getLabel:(NSString *) title withOrigin:(CGPoint) origin andAttributes:(NSDictionary *) nameLabelAttribute withMaxWidth:(CGFloat) maxWidth {
    UILabel * nameLabel = [[UILabel alloc] init];
    
    if(title && nameLabelAttribute){
        NSAttributedString* tabAttributedTitle = [[NSAttributedString alloc] initWithString:title attributes:nameLabelAttribute];
        CGRect textSize = [title boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:nameLabelAttribute context:nil];
        
        CGFloat height;
        height= (textSize.size.height <= (self.frame.size.height/2.f) - 2.f) ?
        textSize.size.height : self.frame.size.height/2.f;
        
        CGFloat width = (maxWidth > 0 && textSize.size.width > maxWidth) ? maxWidth : textSize.size.width;
        
        CGRect labelFrame = CGRectMake(origin.x, origin.y, width, height +7.f);
        
        nameLabel.frame = labelFrame;
        nameLabel.adjustsFontSizeToFitWidth = YES;
        nameLabel.numberOfLines = 1.f;
        nameLabel.backgroundColor = [UIColor clearColor];
        [nameLabel setAttributedText:tabAttributedTitle];
    }
    return nameLabel;
}


-(NSDictionary *)getChannelNameAttributes{
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentCenter;
    return @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                       NSFontAttributeName: [UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWING_INFO_FONT size:CHANNEL_USER_LIST_CHANNEL_NAME_FONT_SIZE],
                                       NSParagraphStyleAttributeName:paragraphStyle};
    
    //create "followers" text
   
}


-(NSDictionary *)getUserNameAttributes{
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentCenter;
   return @{NSForegroundColorAttributeName: [UIColor whiteColor],
      NSFontAttributeName: [UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWERS_FONT size:POSTLIST_USER_LIST_USER_NAME_FONT_SIZE], NSParagraphStyleAttributeName:paragraphStyle};
}


-(UIView *)selectionDot{
    if(!_selectionDot){
        CGFloat ypos = (self.frame.size.height - SELECTION_DOT_SIZE)/2.f ;
        _selectionDot = [[UIView alloc] initWithFrame:CGRectMake(XOFFSET, ypos, SELECTION_DOT_SIZE, SELECTION_DOT_SIZE)];
        _selectionDot.layer.cornerRadius = SELECTION_DOT_SIZE/2.f;
        _selectionDot.layer.borderWidth = 1.f;
        _selectionDot.layer.borderColor = [UIColor SELECTION_DOT_COLOR].CGColor;
        [self addSubview:_selectionDot];
    }
    return _selectionDot;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
