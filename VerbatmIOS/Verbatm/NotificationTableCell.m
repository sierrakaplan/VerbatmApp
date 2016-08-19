//
//  NotificationTableCell.m
//  Verbatm
//
//  Created by Iain Usiri on 7/4/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Icons.h"
#import "NotificationTableCell.h"
#import "ParseBackendKeys.h"
#import "Styles.h"
#import "SizesAndPositions.h"
#import <Parse/PFUser.h>
#import "Follow_BackendManager.h"
#import "Notifications.h"
#import "UserInfoCache.h"

@interface NotificationTableCell ()

@property (nonatomic) UILabel * notificationTextLabel;
@property (nonatomic) UIImageView * likeImage;
@property (nonatomic) UIButton * followButton;
@property (nonatomic) BOOL currentUserFollowingChannelUser;
@property (nonatomic) UIView * separatorView;

@property (nonatomic) UILabel * postLine;//text saying "post!" so that post is seletable

#define NEW_FOLLOWER_APPEND_TEXT @" is following you"
#define LIKE_APPEND_TEXT @" likes your "
#define FRIEND_JOINED_V_APPEND_TEXT @" just joined Verbatm"
#define FRIENDS_FIRST_POST @" just created their first "
#define POST_SHARED_APPEND_TEXT @" shared your "
#define REBLOG_APPEND_TEXT @" reblogged your "
#define COMMENT_APPEND_TEXT @" commented on your "

#define FOLLOW_TEXT_BUTTON_GAP (3.f)
#define FOLLOW_BUTTON_X_POS (self.frame.size.width - PROFILE_HEADER_XOFFSET - LARGE_FOLLOW_BUTTON_WIDTH)

#define POST_TEXT_WIDTH 10.f


@end

@implementation NotificationTableCell


-(void)clearViews {
	if(self.notificationTextLabel){
		[self.notificationTextLabel removeFromSuperview];
		self.notificationTextLabel = nil;
	}

	if(self.likeImage){
		[self.likeImage removeFromSuperview];
		self.likeImage = nil;
	}

    if(self.followButton){
        [self.followButton removeFromSuperview];
        self.followButton = nil;
    }

	if(self.separatorView){
		[self.separatorView removeFromSuperview];
		self.separatorView = nil;
	}

	if (self.postLine) {
		[self.postLine removeFromSuperview];
		self.postLine = nil;
	}
}


-(void)presentNotification:(NotificationType) notificationType withChannel:(Channel *) channel andParseObject:(PFObject *)parseObject{
    
    [self clearViews];
    
    self.parseObject = parseObject;
    self.notificationType = notificationType;
    self.channel = channel;
    if(notificationType & NotificationTypeLike){
         [self createHeartIcon];
    }else if(notificationType & (NotificationTypeNewFollower | NotificationTypeFriendJoinedVerbatm)) {
        [self createFollowButton];
        [self registerForFollowNotification];
    }
    
    NSString * notifcation = [self getNotificationStringWithNotifcationType:notificationType andChannel:channel];
    [self createNotificationLabelWithAttributedString:[self getAttributedStringFromString:notifcation andNotificationType:notificationType andChannel:channel]];
    
    if(notificationType & (NotificationTypeFriendsFirstPost|NotificationTypeLike|NotificationTypeShare|NotificationTypeReblog|NotificationTypeNewComment)){
        [self createPostTextLabel];
    }
}


-(void)registerForFollowNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userFollowStatusChanged:)
                                                 name:NOTIFICATION_NOW_FOLLOWING_USER
                                               object:nil];
}

-(void)userFollowStatusChanged:(NSNotification *) notification{
    NSDictionary * userInfo = [notification userInfo];
    if(userInfo){
        NSString * userId = userInfo[USER_FOLLOWING_NOTIFICATION_USERINFO_KEY];
        NSNumber * isFollowingAction = userInfo[USER_FOLLOWING_NOTIFICATION_ISFOLLOWING_KEY];
        if([userId isEqualToString:[self.channel.channelCreator objectId]] &&
           ([isFollowingAction boolValue] != self.currentUserFollowingChannelUser)) {
			self.currentUserFollowingChannelUser = [isFollowingAction boolValue];
            [self updateUserFollowingChannel];
        }
    }
}

-(void)layoutSubviews {
    self.backgroundColor = [UIColor clearColor];
    [self addCellSeperator];
}

-(void)addCellSeperator{
    if(!self.separatorView){
        self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.frame.size.height - CHANNEL_LIST_CELL_SEPERATOR_HEIGHT, self.frame.size.width,CHANNEL_LIST_CELL_SEPERATOR_HEIGHT)];
        self.separatorView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.separatorView];
    }
}


-(NSString *) getNotificationStringWithNotifcationType:(NotificationType) notificationType andChannel:(Channel *) channel{
    
    NSString * finalString = @"";
    
    switch (notificationType) {
        case NotificationTypeNewFollower:
            finalString = [[channel.channelCreator valueForKey:VERBATM_USER_NAME_KEY] stringByAppendingString:NEW_FOLLOWER_APPEND_TEXT];
            break;
            
        case NotificationTypeFriendJoinedVerbatm:
            finalString = [[channel.channelCreator valueForKey:VERBATM_USER_NAME_KEY] stringByAppendingString:FRIEND_JOINED_V_APPEND_TEXT];
            break;
            
        case NotificationTypeLike:
            finalString = [[channel.channelCreator valueForKey:VERBATM_USER_NAME_KEY] stringByAppendingString:LIKE_APPEND_TEXT];
            break;
            
        case NotificationTypeFriendsFirstPost:
            finalString = [[channel.channelCreator valueForKey:VERBATM_USER_NAME_KEY] stringByAppendingString:FRIENDS_FIRST_POST];
            break;
        case NotificationTypeShare:
            finalString = [[channel.channelCreator valueForKey:VERBATM_USER_NAME_KEY] stringByAppendingString:POST_SHARED_APPEND_TEXT];
            break;
        case NotificationTypeReblog:
            finalString = [[channel.channelCreator valueForKey:VERBATM_USER_NAME_KEY] stringByAppendingString:REBLOG_APPEND_TEXT];
            break;
        case NotificationTypeNewComment:
            finalString = [[channel.channelCreator valueForKey:VERBATM_USER_NAME_KEY] stringByAppendingString:COMMENT_APPEND_TEXT];
            break;
    }

    return finalString;
}




-(void)createPostTextLabel{
    
    CGRect frame = CGRectMake(self.notificationTextLabel.frame.origin.x + self.notificationTextLabel.frame.size.width, self.notificationTextLabel.frame.origin.y, POST_TEXT_WIDTH, self.notificationTextLabel.frame.size.height);
    
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
}

-(void)createHeartIcon {
    CGFloat x_pos = (FOLLOW_BUTTON_X_POS) + ((LARGE_FOLLOW_BUTTON_WIDTH -LARGE_FOLLOW_BUTTON_HEIGHT) /2.f);
    CGFloat y_pos = (self.frame.size.height - LARGE_FOLLOW_BUTTON_HEIGHT)/2.f;
    CGRect frame = CGRectMake(x_pos, y_pos, LARGE_FOLLOW_BUTTON_HEIGHT, LARGE_FOLLOW_BUTTON_HEIGHT);
    self.likeImage = [[UIImageView alloc] initWithFrame:frame];
    [self.likeImage setImage:[UIImage imageNamed:LIKE_NOTIFICATION_IMAGE_ICON]];
    self.likeImage.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.likeImage];
}

-(void)getFollowInformation{
	self.currentUserFollowingChannelUser = [[UserInfoCache sharedInstance] checkUserFollowsChannel: self.channel];
	[self updateUserFollowingChannel];
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
        [Follow_BackendManager currentUserStopFollowingChannel: self.channel];
    }
    [self.channel currentUserFollowChannel: self.currentUserFollowingChannelUser];
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
