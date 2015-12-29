
//
//  ChannelButtons.m
//  Verbatm
//
//  Created by Iain Usiri on 11/28/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "Channel.h"
#import "ChannelButtons.h"
#import "SizesAndPositions.h"
#import "Styles.h"


@interface ChannelButtons ()
@property (nonatomic,strong) UILabel * channelNameLabel;
@property (nonatomic, strong) UILabel * numberOfFollowersLabel;

@property (strong, nonatomic) NSDictionary* tabTitleAttributes;
@property (strong, nonatomic) NSDictionary* selectedTabTitleAttributes;

@property (nonatomic, readwrite) NSString * channelName;

@property (nonatomic, readwrite) CGFloat suggestedWidth;
@end

@implementation ChannelButtons

-(instancetype) initWithFrame:(CGRect)frame andChannel:(Channel *) channel{
    
    self = [super initWithFrame:frame];
    
    if(self){
        [self setLabelsFromChannel:channel];
        [self formatButton];
        self.channelName = channel.name;
    }
    return self;
}

-(void)formatButton{
    //set background
    self.backgroundColor = [UIColor clearColor];
    [self setImage:[UIImage imageNamed:TAB_BUTTON_BACKGROUND_IMAGE] forState:UIControlStateNormal];//slightly dark background to make text more visible
    
    //add thin white border
    self.layer.borderWidth = 0.3;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
}


-(void) setLabelsFromChannel:(Channel *) channel{
    
    CGPoint nameLabelOrigin = CGPointMake(0.f,0.f);
    self.channelNameLabel = [self getChannelNameLabel:channel withOrigin:nameLabelOrigin];
    
    CGPoint numFollowersOrigin = CGPointMake(0.f,self.frame.size.height/2.f);
    self.numberOfFollowersLabel = [self getChannelFollowersLabel:channel andOrigin:numFollowersOrigin];
    
    
    CGFloat buttonWidth = TAB_BUTTON_PADDING + ((self.numberOfFollowersLabel.frame.size.width >  self.channelNameLabel.frame.size.width) ?
                                                self.numberOfFollowersLabel.frame.size.width :  self.channelNameLabel.frame.size.width);
    
    
    //adjust label frame sizes to be the same with some padding
     self.channelNameLabel.frame = CGRectMake(buttonWidth/2.f -
                                              self.channelNameLabel.frame.size.width/2.f,
                                              self.channelNameLabel.frame.origin.y,
                                              self.channelNameLabel.frame.size.width,
                                              self.channelNameLabel.frame.size.height);
    
    
    self.numberOfFollowersLabel.frame = CGRectMake(buttonWidth/2.f -
                                                   self.numberOfFollowersLabel.frame.size.width/2.f,
                                                   self.numberOfFollowersLabel.frame.origin.y,
                                                   self.numberOfFollowersLabel.frame.size.width,
                                                   self.numberOfFollowersLabel.frame.size.height);
    
    [self addSubview: self.channelNameLabel];
    [self addSubview:self.numberOfFollowersLabel];
    
    //tell our parent view to adjust our size
    self.suggestedWidth = buttonWidth;
}


-(UILabel *) getChannelNameLabel:(Channel *) channel withOrigin:(CGPoint) origin{
    
    NSAttributedString* tabAttributedTitle = [[NSAttributedString alloc] initWithString:channel.name attributes:self.tabTitleAttributes];
    CGSize textSize = [channel.name sizeWithAttributes:self.tabTitleAttributes];
    
    CGFloat height = (textSize.height <= self.frame.size.height/2.f) ?
    textSize.height : self.frame.size.height/2.f;
    
    CGRect labelFrame = CGRectMake(origin.x, origin.y, textSize.width, height);
    
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:labelFrame];
    
    [nameLabel setAttributedText:tabAttributedTitle];
    return nameLabel;
}

-(UILabel *) getChannelFollowersLabel:(Channel *) channel andOrigin:(CGPoint) origin{
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentCenter;
    
    //create bolded number
    NSString * numberOfFollowers = [channel.numberOfFollowers stringValue];
    
    NSDictionary * numberOfFolowersAttributes =@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                 NSFontAttributeName: [UIFont fontWithName:TAB_BAR_FOLLOWER_NUMBER_FONT size:FOLLOWERS_TEXT_FONT_SIZE],
                                                 NSParagraphStyleAttributeName:paragraphStyle};
    
    NSMutableAttributedString * numberOfFollowersAttributed = [[NSMutableAttributedString alloc] initWithString:numberOfFollowers attributes:numberOfFolowersAttributes];
    
    
    //create "followers" text
    NSDictionary * followersTextAttributes =@{
                                              NSForegroundColorAttributeName: [UIColor whiteColor],
                                              NSFontAttributeName: [UIFont fontWithName:TAB_BAR_FOLLOWERS_FONT size:FOLLOWERS_TEXT_FONT_SIZE]};
    
    NSAttributedString * followersText = [[NSAttributedString alloc] initWithString:@" Follower(s)" attributes:followersTextAttributes];
    
    //create frame for label
    CGSize textSize = [[numberOfFollowers stringByAppendingString:@" Follower(s)"] sizeWithAttributes:numberOfFolowersAttributes];
    
    CGFloat height = (textSize.height <= self.frame.size.height/2.f) ?
    textSize.height : self.frame.size.height/2.f;
    
    CGRect labelFrame = CGRectMake(origin.x, origin.y, textSize.width, height);
    
    
    UILabel * followersLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [numberOfFollowersAttributed appendAttributedString:followersText];
    [followersLabel setAttributedText:numberOfFollowersAttributed];
    
    return  followersLabel;
}






-(NSDictionary*) tabTitleAttributes {
    if (!_tabTitleAttributes) {
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        _tabTitleAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                NSFontAttributeName: [UIFont fontWithName:TAB_BAR_CHANNEL_NAME_FONT size:TAB_BAR_FONT_SIZE],
                                NSParagraphStyleAttributeName:paragraphStyle};
    }
    return _tabTitleAttributes;
}

-(NSDictionary*) selectedTabTitleAttributes {
    if (!_selectedTabTitleAttributes) {
        NSShadow *shadow = [[NSShadow alloc] init];
        [shadow setShadowBlurRadius:10.f];
        [shadow setShadowColor:[UIColor blackColor]];
        [shadow setShadowOffset:CGSizeMake(0.f, 0.f)];
        
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        _selectedTabTitleAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor],                     NSFontAttributeName: [UIFont fontWithName:TAB_BAR_SELECTED_FONT size:TAB_BAR_FONT_SIZE],
                                        NSParagraphStyleAttributeName:paragraphStyle};
    }
    return _selectedTabTitleAttributes;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
