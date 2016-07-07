//
//  NotificationTableCell.m
//  Verbatm
//
//  Created by Iain Usiri on 7/4/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "NotificationTableCell.h"
#import "ParseBackendKeys.h"
#import "Styles.h"
#import "SizesAndPositions.h"
#import <Parse/PFUser.h>
#import "Follow_BackendManager.h"
@interface NotificationTableCell ()

@property (nonatomic) UILabel * notificationTextLabel;
@property (nonatomic) UIImageView * likeImage;
@property (nonatomic) UIButton * followButton;
@property (nonatomic) BOOL currentUserFollowingChannelUser;
@property (nonatomic) UIView * seperatorView;

@property (nonatomic) UILabel * postLine;//text saying "post!" so that post is seletable

#define NEW_FOLLOWER_APPEND_TEXT @" is Following you"
#define LIKE_APPEND_TEXT @" likes your "
#define FRIEND_JOINED_V_APPEND_TEXT @" just joined Verbatm"
#define FRIENDS_FIRST_POST @" just created their first "
#define POST_SHARED_APPEND_TEXT @" shared your "
#define FOLLOW_TEXT_BUTTON_GAP (3.f)
#define FOLLOW_BUTTON_X_POS (self.frame.size.width - PROFILE_HEADER_XOFFSET - LARGE_FOLLOW_BUTTON_WIDTH)

#define POST_TEXT_WIDTH 10.f


@end

@implementation NotificationTableCell


-(void)clearViews{
    if(self.followButton){
        [self.followButton removeFromSuperview];
        self.followButton = nil;
    }
    
    if(self.notificationTextLabel){
        [self.notificationTextLabel removeFromSuperview];
        self.notificationTextLabel = nil;
    }
    
    if(self.likeImage){
        [self.likeImage removeFromSuperview];
        self.likeImage = nil;
    }
}


-(void)presentNotification:(NotificationType) notificationType withChannel:(Channel *) channel andObjectId:(id)objectId{
    
    [self clearViews];
    
    self.objectId = objectId;
    self.notificationType = notificationType;
    self.channel = channel;
    if(notificationType & (NewFollower|FriendJoinedVerbatm|FriendsFirstPost|Share)){
        [self createFollowButton];
    }else if (notificationType & Like){
        [self createHeartIcon];
    }
    
    NSString * notifcation = [self getNotificationStringWithNotifcationType:notificationType andChannel:channel];
    [self createNotificationLabelWithAttributedString:[self getAttributedStringFromString:notifcation andNotificationType:notificationType andChannel:channel]];
    
    if(notificationType & (FriendsFirstPost|Like|Share)){
        [self createPostTextLabel];
    }
    
}


-(void)addTapGestureToPostText{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postTextTapped:)];
    [self.postLine addGestureRecognizer:tap];
    [self.postLine setUserInteractionEnabled:YES];
}

-(void)postTextTapped:(UITapGestureRecognizer *) tap{
    [self.delegate presentPostSentFromCell:self];
}

-(void)addTapGestureToNameText{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nameTextTapped:)];
    [self.notificationTextLabel addGestureRecognizer:tap];
    [self.notificationTextLabel setUserInteractionEnabled:YES];
}

-(void)nameTextTapped:(UITapGestureRecognizer *) tap{
    [self.delegate presentUserBlogSentFromCell:self];
}


-(void)layoutSubviews {
    self.backgroundColor = [UIColor clearColor];
    [self addCellSeperator];
}

-(void)addCellSeperator{
    if(!self.seperatorView){
        self.seperatorView = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.frame.size.height - CHANNEL_LIST_CELL_SEPERATOR_HEIGHT, self.frame.size.width,CHANNEL_LIST_CELL_SEPERATOR_HEIGHT)];
        self.seperatorView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.seperatorView];
    }
}


-(NSString *) getNotificationStringWithNotifcationType:(NotificationType) notificationType andChannel:(Channel *) channel{
    
    NSString * finalString = @"";
    
    switch (notificationType) {
        case NewFollower:
            finalString = [[channel.channelCreator valueForKey:VERBATM_USER_NAME_KEY] stringByAppendingString:NEW_FOLLOWER_APPEND_TEXT];
            break;
            
        case FriendJoinedVerbatm:
            finalString = [[channel.channelCreator valueForKey:VERBATM_USER_NAME_KEY] stringByAppendingString:FRIEND_JOINED_V_APPEND_TEXT];
            break;
            
        case Like:
            finalString = [[channel.channelCreator valueForKey:VERBATM_USER_NAME_KEY] stringByAppendingString:LIKE_APPEND_TEXT];
            break;
            
        case FriendsFirstPost:
            finalString = [[channel.channelCreator valueForKey:VERBATM_USER_NAME_KEY] stringByAppendingString:FRIENDS_FIRST_POST];
            break;
        case Share:
            finalString = [[channel.channelCreator valueForKey:VERBATM_USER_NAME_KEY] stringByAppendingString:POST_SHARED_APPEND_TEXT];
            break;
    }

    return finalString;
}




-(void)createPostTextLabel{
    
    CGRect frame = CGRectMake(self.notificationTextLabel.frame.origin.x + self.notificationTextLabel.frame.size.width, self.notificationTextLabel.frame.origin.y -1.f, POST_TEXT_WIDTH, self.notificationTextLabel.frame.size.height);
    
    self.postLine = [[UILabel alloc] initWithFrame:frame];
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSDictionary * textAttributes=@{NSForegroundColorAttributeName: [UIColor colorWithRed:0 green:255 blue:255 alpha:1.f],
                                        NSFontAttributeName: [UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWING_INFO_FONT size:CHANNEL_USER_LIST_CHANNEL_NAME_FONT_SIZE],
                                        NSParagraphStyleAttributeName:paragraphStyle};
    

    NSAttributedString * attrString = [[NSAttributedString alloc] initWithString:@"post!" attributes:textAttributes];
    
    [self.postLine setAttributedText:attrString];
    [self.postLine sizeToFit];
    [self addSubview:self.postLine];
   // [self addTapGestureToPostText];
    
}

-(NSAttributedString *)getAttributedStringFromString:(NSString *) notificaitonText andNotificationType:(NotificationType)notificationType andChannel:(Channel *) channel{
    
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentLeft;
   NSDictionary * baseTextAttributes=@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                       NSFontAttributeName: [UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWERS_FONT size:NOTIFICATION_LIST_FONT_SIZE],
                                       NSParagraphStyleAttributeName:paragraphStyle};
    
    NSMutableAttributedString * finalString = [[NSMutableAttributedString alloc] initWithString:notificaitonText attributes:baseTextAttributes];
    
    
    //make creator name bold
    NSString * creatorName = [channel.channelCreator valueForKey:VERBATM_USER_NAME_KEY];
    NSRange rangeOfPostText = [notificaitonText rangeOfString:creatorName];
     [finalString addAttribute:NSFontAttributeName value:[UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWING_INFO_FONT size:NOTIFICATION_LIST_FONT_SIZE] range:rangeOfPostText];
    
    return finalString;
}

-(void)createNotificationLabelWithAttributedString:(NSAttributedString *) notification{
    CGFloat labelWidth = FOLLOW_BUTTON_X_POS - PROFILE_HEADER_XOFFSET - FOLLOW_TEXT_BUTTON_GAP - POST_TEXT_WIDTH;
    CGFloat yposition = (self.frame.size.height - LARGE_FOLLOW_BUTTON_HEIGHT)/2.f;
    CGRect frame = CGRectMake(PROFILE_HEADER_XOFFSET,yposition, labelWidth, LARGE_FOLLOW_BUTTON_HEIGHT);
    self.notificationTextLabel = [[UILabel alloc] initWithFrame:frame];
    [self.notificationTextLabel setAttributedText:notification];
    [self.notificationTextLabel setNumberOfLines:1];
    [self.notificationTextLabel sizeToFit];
    
    if(labelWidth < self.notificationTextLabel.frame.size.width){
        self.notificationTextLabel.frame = frame;
        [self.notificationTextLabel setAdjustsFontSizeToFitWidth:YES];
    }
    
    [self addSubview:self.notificationTextLabel];
   // [self addTapGestureToNameText];
}

-(void)createHeartIcon{
    CGFloat x_pos = (FOLLOW_BUTTON_X_POS) + ((LARGE_FOLLOW_BUTTON_WIDTH -LARGE_FOLLOW_BUTTON_HEIGHT) /2.f);
    CGFloat y_pos = (self.frame.size.height - LARGE_FOLLOW_BUTTON_HEIGHT)/2.f;
    CGRect frame = CGRectMake(x_pos, y_pos, LARGE_FOLLOW_BUTTON_HEIGHT, LARGE_FOLLOW_BUTTON_HEIGHT);
    self.likeImage = [[UIImageView alloc] initWithFrame:frame];
    [self.likeImage setImage:[UIImage imageNamed:LIKE_NOTIFICATION_IMAGE_ICON]];
    self.likeImage.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.likeImage];
}

-(void)getFollowInformation{
    if(!(self.channel.usersFollowingChannel && self.channel.usersFollowingChannel.count)){
        [Follow_BackendManager currentUserFollowsChannel:self.channel withCompletionBlock:^(bool isFollowing) {
            self.currentUserFollowingChannelUser = isFollowing;
            if(self.followButton)[self updateUserFollowingChannel];
        }];
    }else{
        self.currentUserFollowingChannelUser = [self.channel.usersFollowingChannel containsObject:[PFUser currentUser]];
        if(self.followButton)[self updateUserFollowingChannel];
    }
}


-(void) createFollowButton {
    if(self.followButton){
        [self.followButton removeFromSuperview];
        self.followButton = nil;
    }
    
    CGFloat frame_x = FOLLOW_BUTTON_X_POS;
    CGFloat frame_y = (self.frame.size.height -  LARGE_FOLLOW_BUTTON_HEIGHT)/2.f;
    CGRect followButtonFrame = CGRectMake(frame_x, frame_y, LARGE_FOLLOW_BUTTON_WIDTH, LARGE_FOLLOW_BUTTON_HEIGHT);
    
    self.followButton = [[UIButton alloc] initWithFrame: followButtonFrame];
    self.followButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.followButton.clipsToBounds = YES;
    self.followButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.followButton.layer.borderWidth = 2.f;
    self.followButton.layer.cornerRadius = 10.f;
    [self.followButton addTarget:self action:@selector(followButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: self.followButton];
    [self getFollowInformation];
}

-(void) followButtonSelected {
    self.currentUserFollowingChannelUser = !self.currentUserFollowingChannelUser;
    if (self.currentUserFollowingChannelUser) {
        [Follow_BackendManager currentUserFollowChannel: self.channel];
    } else {
        [Follow_BackendManager user:[PFUser currentUser] stopFollowingChannel: self.channel];
    }
    [self.channel currentUserFollowsChannel: self.currentUserFollowingChannelUser];
    [self updateUserFollowingChannel];
}
-(void) updateUserFollowingChannel {
    //todo: images
    if (self.currentUserFollowingChannelUser) {
        [self changeFollowButtonTitle:@"Following" toColor:[UIColor blackColor]];
        self.followButton.backgroundColor = [UIColor whiteColor];
    } else {
        [self changeFollowButtonTitle:@"+ Follow" toColor:[UIColor whiteColor]];
        self.followButton.backgroundColor = [UIColor clearColor];
    }
}

-(void) changeFollowButtonTitle:(NSString*)title toColor:(UIColor*) color{
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: color,
                                      NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:FOLLOW_TEXT_FONT_SIZE]};
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:titleAttributes];
    [self.followButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
