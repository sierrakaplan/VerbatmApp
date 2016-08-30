//
//  ProfileListHeader.m
//  Verbatm
//
//  Created by Iain Usiri on 8/24/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "ProfileListHeader.h"
#import "Styles.h"
#import "SizesAndPositions.h"

@interface ProfileListHeader ()

@property(nonatomic) UILabel * title;

#define UPDATED_PROFILES_TITLE @"Updated Profiles"
#define REGULAR_PROFILES_TITLE @"All Profiles"
@end

@implementation ProfileListHeader



-(void)clearView{
    [self.title removeFromSuperview];
    self.title = nil;
}

-(void)setHeaderTitleWithSectionIndex:(NSInteger) index{
    
    [self clearView];
    self.backgroundColor = [UIColor blackColor];
    
    
    CGFloat titleWidth = 200.f;
    CGPoint nameLabelOrigin = CGPointMake((self.frame.size.width - titleWidth)/2.f,TAB_BUTTON_PADDING_Y);
    NSString * titleText;
    
    if(index == 0){
        titleText = UPDATED_PROFILES_TITLE;
    }else{
        titleText = REGULAR_PROFILES_TITLE;
    }
    self.title = [self getLabel:titleText withOrigin:nameLabelOrigin andAttributes:[self getUserNameAttributes] withMaxWidth:titleWidth];
   
}

-(void)layoutSubviews{
    CGFloat yPos = (self.frame.size.height/2.f) - (self.title.frame.size.height/2.f);
    CGFloat xPos = (self.frame.size.width/2.f) - (self.title.frame.size.width/2.f);
    
    self.title.frame = CGRectMake(xPos, yPos, self.title.frame.size.width, self.title.frame.size.height);
    
    [self addSubview:self.title];
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

-(NSDictionary *)getUserNameAttributes{
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    return @{NSForegroundColorAttributeName: [UIColor SELECTION_DOT_COLOR],
             NSFontAttributeName: [UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWERS_FONT size:CHANNEL_USER_LIST_USER_NAME_FONT_SIZE], NSParagraphStyleAttributeName:paragraphStyle};
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
