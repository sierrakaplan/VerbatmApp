//
//  ChannelOrUsernameCV.m
//  Verbatm
//
//  Created by Iain Usiri on 1/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "ChannelOrUsernameCV.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import <Parse/PFObject.h>
#import "ParseBackendKeys.h"


@import UIKit;

@interface ChannelOrUsernameCV ()

    @property (nonatomic) BOOL isAChannel;
    @property (nonatomic) BOOL isAChannelIFollow;

    @property (nonatomic,strong) UILabel * channelNameLabel;
    @property (nonatomic, strong) UILabel * usernameLabel;

    @property (nonatomic) NSString * channelName;
    @property (nonatomic) NSString * userName;

    @property (strong, nonatomic) NSDictionary* channelNameLabelAttributes;
    @property (strong, nonatomic) NSDictionary* userNameLabelAttributes;

    @property (nonatomic) UIView * seperatorView;

    @property (nonatomic) UILabel * headerTitle;//makes the cell a header for the table view
    @property (nonatomic) BOOL isHeaderTile;
@end

@implementation ChannelOrUsernameCV

- (void)awakeFromNib {
    // Initialization code
}


- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isChannel:(BOOL) isChannel isAChannelThatIFollow:(BOOL) channelThatIFollow {
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier] ;
    
    if (self) {
        
        self.backgroundColor = CHANNEL_TAB_BAR_BACKGROUND_COLOR_UNSELECTED;
        self.isAChannel = isChannel;
        self.isAChannelIFollow = channelThatIFollow;
        if(!self.channelNameLabelAttributes)[self createSelectedTextAttributes];
    }
    
    return self;
}



#pragma mark - Edit Cell formatting -


-(void)setHeaderTitle{
    self.isHeaderTile = YES;
}

-(void)presentChannel:(Channel *) channel{
     PFObject *creator = [channel.parseChannelObject valueForKey:CHANNEL_CREATOR_KEY];
    [creator fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(object){
            
            NSString *userName = [creator valueForKey:VERBATM_USER_NAME_KEY];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setChannelName:channel.name andUserName: userName];
                [self setLabelsForChannel];
            });
        }
    }];
}

-(void)setChannelName:(NSString *)channelName andUserName:(NSString *) userName {
    self.channelName = channelName;
     self.userName = userName;
    self.isHeaderTile = NO;
}

-(void)layoutSubviews {
    //do formatting here
    if(self.isHeaderTile){
        //it's in the tab bar list and it should have a title
        self.headerTitle = [self getHeaderTitleForViewWithText:@"Discover"];
        [self addSubview:self.headerTitle];
    }else {
        if(self.headerTitle)[self.headerTitle removeFromSuperview];
        self.headerTitle = nil;
       
    }
}


-(void) setLabelsForChannel{
    
    CGPoint channelNameLabelOrigin = CGPointMake(TAB_BUTTON_PADDING,2.f);
    CGPoint nameLabelOrigin = CGPointMake(TAB_BUTTON_PADDING,self.frame.size.height/2.f);
    
    self.channelNameLabel = [self getLabel:self.channelName withOrigin:channelNameLabelOrigin andAttributes:self.channelNameLabelAttributes];
    self.usernameLabel = [self getLabel:self.userName withOrigin:nameLabelOrigin andAttributes:self.userNameLabelAttributes];
    
    [self addSubview: self.channelNameLabel];
    [self addSubview:self.usernameLabel];
    
    if(!self.seperatorView){
        self.seperatorView = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.frame.size.height, self.frame.size.width,CHANNEL_LIST_CELL_SEPERATOR_HEIGHT)];
        self.seperatorView.backgroundColor = CHANNEL_LIST_CELL_SEPERATOR_COLOR;
        [self addSubview:self.seperatorView];
    }
    
    
}


-(UILabel *) getLabel:(NSString *) title withOrigin:(CGPoint) origin andAttributes:(NSDictionary *) nameLabelAttribute {
    
    NSAttributedString* tabAttributedTitle = [[NSAttributedString alloc] initWithString:title attributes:nameLabelAttribute];
    CGSize textSize = [title sizeWithAttributes:nameLabelAttribute];
    
    CGFloat height = (textSize.height <= (self.frame.size.height/2.f) - 2.f) ?
    textSize.height : self.frame.size.height/2.f;
    
    CGRect labelFrame = CGRectMake(origin.x, origin.y, textSize.width, height);
    
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:labelFrame];
    
    [nameLabel setAttributedText:tabAttributedTitle];
    return nameLabel;
}



-(void)createSelectedTextAttributes{
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentCenter;
    self.channelNameLabelAttributes =@{NSForegroundColorAttributeName: VERBATM_GOLD_COLOR,
                                                     NSFontAttributeName: [UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWING_INFO_FONT size:CHANNEL_USER_LIST_CHANNEL_NAME_FONT_SIZE],
                                                     NSParagraphStyleAttributeName:paragraphStyle};
    
    //create "followers" text
    self.userNameLabelAttributes =@{
                                                NSForegroundColorAttributeName: [UIColor grayColor],
                                                NSFontAttributeName: [UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWERS_FONT size:CHANNEL_USER_LIST_USER_NAME_FONT_SIZE]};
    
//    self.selectedChannelNameTitleAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
//                                                NSFontAttributeName: [UIFont fontWithName:CHANNEL_TAB_BAR_NAME_FONT size:CHANNEL_TAB_BAR_NAME_FONT_SIZE],
//                                                NSParagraphStyleAttributeName:paragraphStyle};
}



-(UILabel *) getHeaderTitleForViewWithText:(NSString *) text{
    
    CGRect labelFrame = CGRectMake(0.f, 0.f, self.frame.size.width + 10, self.frame.size.height - 12.f);
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
    titleLabel.backgroundColor = [UIColor whiteColor];
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary * informationAttribute = @{NSForegroundColorAttributeName:
                                                [UIColor blackColor],
                                            NSFontAttributeName:
                                                [UIFont fontWithName:INFO_LIST_HEADER_FONT size:INFO_LIST_HEADER_FONT_SIZE],
                                            NSParagraphStyleAttributeName:paragraphStyle};
    
    NSAttributedString * titleAttributed = [[NSAttributedString alloc] initWithString:text attributes:informationAttribute];
    
    [titleLabel setAttributedText:titleAttributed];
    
    return titleLabel;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
