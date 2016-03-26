//
//  PostChannelAndCreatorBar.m
//  Verbatm
//
//  Created by Iain Usiri on 3/22/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "PostChannelAndCreatorBar.h"
#import <Parse/PFObject.h>
#import "Styles.h"
#import "ParseBackendKeys.h"
@interface PostChannelAndCreatorBar ()
@property (nonatomic) UILabel * userNameLabel;
@property (nonatomic) UILabel * channelNameLable;
@property (nonatomic) Channel * channel;

#define Label_x_offset 3.f
#define Label_y_offset 3.f

@end


@implementation PostChannelAndCreatorBar


-(instancetype) initWithFrame:(CGRect)frame andChannel:(Channel *) channel{
    self = [super initWithFrame:frame];
    if(self){
        self.channel = channel;
    }
    return self;
}

-(void)createLabelsFromChannel:(Channel *) channel{
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary * userNameAttributes =  @{NSForegroundColorAttributeName: [UIColor whiteColor],
      NSFontAttributeName: [UIFont fontWithName:CHANNEL_TAB_BAR_NAME_FONT size:CHANNEL_TAB_BAR_NAME_FONT_SIZE],
      NSParagraphStyleAttributeName:paragraphStyle};
    
    UILabel * userNameLabel = [self getLabelWithString:[channel getChannelOwnerUserName] andAttributes:userNameAttributes];
    
    CGRect userNameFrame = CGRectMake(Label_x_offset, Label_y_offset, userNameLabel.frame.size.width, userNameLabel.frame.size.height);
    
    userNameLabel.frame = userNameFrame;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addSubview:userNameLabel];
    });
}

-(UILabel *) getLabelWithString:(NSString *) string andAttributes:(NSDictionary *) nameLabelAttribute{
    NSAttributedString* tabAttributedTitle = [[NSAttributedString alloc] initWithString:string attributes:nameLabelAttribute];
    CGSize textSize = [string sizeWithAttributes:nameLabelAttribute];
    
    CGFloat height = (textSize.height <= self.frame.size.height/2.f) ?
    textSize.height : self.frame.size.height/2.f;
    
    CGRect labelFrame = CGRectMake(0.f, 0.f, textSize.width, height);
    
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:labelFrame];
    
    [nameLabel setAttributedText:tabAttributedTitle];
    return nameLabel;
}



@end
