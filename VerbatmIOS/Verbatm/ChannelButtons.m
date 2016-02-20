
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

@property (strong, nonatomic) NSDictionary* nonSelectedFollowersTabTitleAttributes;
@property (strong, nonatomic) NSDictionary* nonSelectedNumberOfFollowersTitleAttributes;
@property (strong, nonatomic) NSDictionary* nonSelectedChannelNameTitleAttributes;

@property (strong, nonatomic) NSDictionary* selectedFollowersTabTitleAttributes;
@property (strong, nonatomic) NSDictionary* selectedNumberOfFollowersTitleAttributes;
@property (strong, nonatomic) NSDictionary* selectedChannelNameTitleAttributes;

@property (nonatomic, readwrite) NSString * channelName;

@property (nonatomic, readwrite) CGFloat suggestedWidth;

@property (nonatomic, readwrite) Channel * currentChannel;

@property (nonatomic) UIButton * followButton;
@property (nonatomic) BOOL isFollowigProfileUser;//for cases when they are viewing another profile
@property (nonatomic) BOOL buttonSelected;

@end

@implementation ChannelButtons

-(instancetype) initWithFrame:(CGRect)frame andChannel:(Channel *) channel isLoggedInUser:(BOOL) isLoggedInUser{

    self = [super initWithFrame:frame];
    
    if(self){
        [self createNonSelectedTextAttributes];
        [self createSelectedTextAttributes];
        
        [self setLabelsFromChannel:channel];
        [self formatButtonUnSelected];
        self.channelName = channel.name;
        self.currentChannel = channel;
    }
    return self;
}

-(void)formatButtonUnSelected{
    //set background
    self.backgroundColor = CHANNEL_TAB_BAR_BACKGROUND_COLOR_UNSELECTED;
    
    //add thin white border
    self.layer.borderWidth = 0.3;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
}


-(void)formatButtonSelected{
    //set background
    self.backgroundColor = CHANNEL_TAB_BAR_BACKGROUND_COLOR_SELECTED;
    
    //add thin white border
    self.layer.borderWidth = 0.3;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
}

-(void) setLabelsFromChannel:(Channel *) channel{
    
    CGPoint nameLabelOrigin = CGPointMake(0.f,0.f);
    self.channelNameLabel = [self getChannelNameLabel:channel withOrigin:nameLabelOrigin andAttributes:self.nonSelectedChannelNameTitleAttributes];
    
    CGPoint numFollowersOrigin = CGPointMake(0.f,self.frame.size.height/2.f);
    self.numberOfFollowersLabel = [self getChannelFollowersLabel:channel origin:numFollowersOrigin followersTextAttribute:self.nonSelectedFollowersTabTitleAttributes andNumberOfFollowersAttribute:self.nonSelectedNumberOfFollowersTitleAttributes];
    
    
    CGFloat buttonWidth = (TAB_BUTTON_PADDING * 3.f) + FOLLOW_BUTTON_WIDTH +  ((self.numberOfFollowersLabel.frame.size.width >  self.channelNameLabel.frame.size.width) ?
                                                self.numberOfFollowersLabel.frame.size.width :  self.channelNameLabel.frame.size.width);
    
    
    //adjust label frame sizes to be the same with some padding
     self.channelNameLabel.frame = CGRectMake(TAB_BUTTON_PADDING,
                                              self.channelNameLabel.frame.origin.y,
                                              self.channelNameLabel.frame.size.width,
                                              self.channelNameLabel.frame.size.height);
    
    
    
    
    CGFloat numFollowersLabelX;
    if(self.numberOfFollowersLabel.frame.size.width > self.channelNameLabel.frame.size.width){
        numFollowersLabelX = TAB_BUTTON_PADDING;
    }else{
        numFollowersLabelX = self.channelNameLabel.center.x - (self.numberOfFollowersLabel.frame.size.width/2.f);
    }
    
    
    
    self.numberOfFollowersLabel.frame = CGRectMake(numFollowersLabelX,
                                                   self.numberOfFollowersLabel.frame.origin.y,
                                                   self.numberOfFollowersLabel.frame.size.width,
                                                   self.numberOfFollowersLabel.frame.size.height);
    
    [self addSubview: self.channelNameLabel];
    [self addSubview:self.numberOfFollowersLabel];
    
    //tell our parent view to adjust our size
    self.suggestedWidth = buttonWidth;
    
    //to do -- we need to actually querry it and put this based on that
    [self createFollowButton_AreWeFollowingCurrChannel:NO];
}

//If it's my profile it's follower(s) and if it's someone else's profile
//it's follow
-(void) createFollowButton_AreWeFollowingCurrChannel:(BOOL) areFollowing{
    if(self.followButton){
        [self.followButton removeFromSuperview];
        self.followButton = nil;
    }
    
    CGFloat height = FOLLOW_BUTTON_HEIGHT;
    CGFloat width = FOLLOW_BUTTON_WIDTH;
    CGFloat frame_x = self.suggestedWidth - width - (TAB_BUTTON_PADDING/2.f);
    CGFloat frame_y = self.center.y - (height/2.f);
    
    CGRect iconFrame = CGRectMake(frame_x, frame_y, width, height);
    
    UIImage * buttonImage = [UIImage imageNamed:((areFollowing) ? FOLLOW_ICON_IMAGE_SELECTED : FOLLOW_ICON_IMAGE_UNSELECTED)];
    self.isFollowigProfileUser = areFollowing;
    self.followButton = [[UIButton alloc] initWithFrame:iconFrame];
    [self.followButton setImage:buttonImage forState:UIControlStateNormal];
    [self.followButton addTarget:self action:@selector(followOrFollowersSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.followButton];
}
-(void) followOrFollowersSelected {
    
    if(self.buttonSelected){//you can only follow a channel if you're on it
        UIImage * newbuttonImage;
        if(self.isFollowigProfileUser){
            newbuttonImage  = [UIImage imageNamed:FOLLOW_ICON_IMAGE_UNSELECTED];
            self.isFollowigProfileUser = NO;
        }else{
            newbuttonImage = [UIImage imageNamed:FOLLOW_ICON_IMAGE_SELECTED];
            self.isFollowigProfileUser = YES;
        }
        [self.followButton setImage:newbuttonImage forState:UIControlStateNormal];
        [self.followButton setNeedsDisplay];
        
        //[self.delegate followButtonSelectedShouldFollowUser: self.isFollowigProfileUser]; TODO
    }else{
        //since the channel isn't selected then we select it
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}


-(UILabel *) getChannelNameLabel:(Channel *) channel withOrigin:(CGPoint) origin andAttributes:(NSDictionary *) nameLabelAttribute{
    
    NSAttributedString* tabAttributedTitle = [[NSAttributedString alloc] initWithString:channel.name attributes:nameLabelAttribute];
    CGSize textSize = [channel.name sizeWithAttributes:nameLabelAttribute];
    
    CGFloat height = (textSize.height <= self.frame.size.height/2.f) ?
    textSize.height : self.frame.size.height/2.f;
    
    CGRect labelFrame = CGRectMake(origin.x, origin.y, textSize.width, height);
    
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:labelFrame];
    
    [nameLabel setAttributedText:tabAttributedTitle];
    return nameLabel;
}

-(UILabel *) getChannelFollowersLabel:(Channel *) channel origin:(CGPoint) origin followersTextAttribute:(NSDictionary *) followersTextAttribute andNumberOfFollowersAttribute:(NSDictionary *) numberOfFollowersAttribute{
    
    //create bolded number
    NSString * numberOfFollowers = [channel.numberOfFollowers stringValue];
    
    
    
    NSMutableAttributedString * numberOfFollowersAttributed = [[NSMutableAttributedString alloc] initWithString:numberOfFollowers attributes:numberOfFollowersAttribute];
    NSAttributedString * followersText = [[NSAttributedString alloc] initWithString:@" Follower(s)" attributes:followersTextAttribute];
    
    //create frame for label
    CGSize textSize = [[numberOfFollowers stringByAppendingString:@" Follower(s)"] sizeWithAttributes:numberOfFollowersAttribute];
    
    CGFloat height = (textSize.height <= self.frame.size.height/2.f) ?
    textSize.height : self.frame.size.height/2.f;
    
    CGRect labelFrame = CGRectMake(origin.x, origin.y, textSize.width, height);
    
    
    UILabel * followersLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [numberOfFollowersAttributed appendAttributedString:followersText];
    [followersLabel setAttributedText:numberOfFollowersAttributed];
    
    return  followersLabel;
}





-(void)createNonSelectedTextAttributes{
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentCenter;
    self.nonSelectedNumberOfFollowersTitleAttributes =@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                        NSFontAttributeName: [UIFont fontWithName:TAB_BAR_FOLLOWER_NUMBER_FONT size:FOLLOWERS_TEXT_FONT_SIZE],
                                                        NSParagraphStyleAttributeName:paragraphStyle};
    
    //create "followers" text
    self.nonSelectedFollowersTabTitleAttributes =@{
                                                   NSForegroundColorAttributeName: [UIColor whiteColor],
                                                   NSFontAttributeName: [UIFont fontWithName:TAB_BAR_FOLLOWERS_FONT size:FOLLOWERS_TEXT_FONT_SIZE]};
    
    self.nonSelectedChannelNameTitleAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                   NSFontAttributeName: [UIFont fontWithName:TAB_BAR_CHANNEL_NAME_FONT size:TAB_BAR_FONT_SIZE],
                                                   NSParagraphStyleAttributeName:paragraphStyle};
}

-(void)createSelectedTextAttributes{
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentCenter;
    self.selectedNumberOfFollowersTitleAttributes =@{NSForegroundColorAttributeName: [UIColor blackColor],
                                                        NSFontAttributeName: [UIFont fontWithName:TAB_BAR_FOLLOWER_NUMBER_FONT size:FOLLOWERS_TEXT_FONT_SIZE],
                                                        NSParagraphStyleAttributeName:paragraphStyle};
    
    //create "followers" text
    self.selectedFollowersTabTitleAttributes =@{
                                                   NSForegroundColorAttributeName: [UIColor blackColor],
                                                   NSFontAttributeName: [UIFont fontWithName:TAB_BAR_FOLLOWERS_FONT size:FOLLOWERS_TEXT_FONT_SIZE]};
    
    self.selectedChannelNameTitleAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                   NSFontAttributeName: [UIFont fontWithName:TAB_BAR_CHANNEL_NAME_FONT size:TAB_BAR_FONT_SIZE],
                                                   NSParagraphStyleAttributeName:paragraphStyle};
}


-(void)markButtonAsSelected{
    UILabel * followersInfoLabel = [self getChannelFollowersLabel:self.currentChannel origin:self.numberOfFollowersLabel.frame.origin followersTextAttribute:self.selectedFollowersTabTitleAttributes andNumberOfFollowersAttribute:self.selectedNumberOfFollowersTitleAttributes];
    UILabel * channelNameLabel = [self getChannelNameLabel:self.currentChannel withOrigin:self.channelNameLabel.frame.origin andAttributes:self.selectedChannelNameTitleAttributes];
    
    //swap labels
    [self.numberOfFollowersLabel removeFromSuperview];
    self.numberOfFollowersLabel = followersInfoLabel;
    [self addSubview:self.numberOfFollowersLabel];
    
    [self.channelNameLabel removeFromSuperview];
    self.channelNameLabel = channelNameLabel;
    [self addSubview:self.channelNameLabel];
    
    [self formatButtonSelected];
    self.buttonSelected = YES;
}

-(void)markButtonAsUnselected{
   UILabel * followersInfoLabel = [self getChannelFollowersLabel:self.currentChannel origin:self.numberOfFollowersLabel.frame.origin followersTextAttribute:self.nonSelectedFollowersTabTitleAttributes andNumberOfFollowersAttribute:self.nonSelectedNumberOfFollowersTitleAttributes];
    UILabel * channelNameLabel = [self getChannelNameLabel:self.currentChannel withOrigin:self.channelNameLabel.frame.origin andAttributes:self.nonSelectedChannelNameTitleAttributes];
    
    //swap labels
    [self.numberOfFollowersLabel removeFromSuperview];
    self.numberOfFollowersLabel = followersInfoLabel;
    [self addSubview:self.numberOfFollowersLabel];
    
    [self.channelNameLabel removeFromSuperview];
    self.channelNameLabel = channelNameLabel;
    [self addSubview:self.channelNameLabel];
    
    [self formatButtonUnSelected];
    self.buttonSelected = NO;
}


//-(NSDictionary*) selectedTabTitleAttributes {
//    if (!_selectedTabTitleAttributes) {
//        NSShadow *shadow = [[NSShadow alloc] init];
//        [shadow setShadowBlurRadius:10.f];
//        [shadow setShadowColor:[UIColor blackColor]];
//        [shadow setShadowOffset:CGSizeMake(0.f, 0.f)];
//        
//        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
//        paragraphStyle.alignment = NSTextAlignmentCenter;
//        
//        _selectedTabTitleAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor],                     NSFontAttributeName: [UIFont fontWithName:TAB_BAR_SELECTED_FONT size:TAB_BAR_FONT_SIZE],
//                                        NSParagraphStyleAttributeName:paragraphStyle};
//    }
//    return _selectedTabTitleAttributes;
//}
//

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
