//
//  ChannelOrUsernameCV.m
//  Verbatm
//
//  Created by Iain Usiri on 1/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "ChannelOrUsernameCV.h"

#import "Follow_BackendManager.h"

#import "Notifications.h"

#import "SizesAndPositions.h"
#import "Styles.h"
#import <Parse/PFObject.h>
#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>

#import "UserInfoCache.h"

@import UIKit;

@interface ChannelOrUsernameCV ()
@property (nonatomic) Channel *channel;

@property (nonatomic) BOOL isAChannel;
@property (nonatomic) BOOL isAChannelIFollow;

@property (nonatomic,strong) UILabel * channelNameLabel;
@property (nonatomic, strong) UILabel * usernameLabel;

@property (nonatomic,strong) UILabel * commentLabel;
@property (nonatomic, strong) UILabel * commentUserNameLabel;



@property (nonatomic) NSString * channelName;
@property (nonatomic) NSString * userName;

@property (strong, nonatomic) NSDictionary* channelNameLabelAttributes;
@property (strong, nonatomic) NSDictionary* userNameLabelAttributes;

@property (nonatomic) UIView * seperatorView;

@property (nonatomic) UILabel * headerTitle;//makes the cell a header for the table view
@property (nonatomic) BOOL isHeaderTile;
@property (nonatomic) UIButton * followButton;
@property (nonatomic) BOOL currentUserFollowingChannelUser;



@end

@implementation ChannelOrUsernameCV

- (void)awakeFromNib {
	// Initialization code
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isChannel:(BOOL) isChannel {
	self = [super initWithStyle: style reuseIdentifier: reuseIdentifier] ;

	if (self) {
        self.backgroundColor = [UIColor whiteColor];
		self.isAChannel = isChannel;
        self.clipsToBounds = YES;
		if(!self.channelNameLabelAttributes)[self createSelectedTextAttributes];
        [self registerForFollowNotification];
	}

	return self;
}

-(void)registerForFollowNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userFollowStatusChanged:)
                                                 name:NOTIFICATION_NOW_FOLLOWING_USER
                                               object:nil];
}

-(void)userFollowStatusChanged:(NSNotification *) notification {
    NSDictionary * userInfo = [notification userInfo];
    if(userInfo){
        NSString * userId = userInfo[USER_FOLLOWING_NOTIFICATION_USERINFO_KEY];
        NSNumber * isFollowingAction = userInfo[USER_FOLLOWING_NOTIFICATION_ISFOLLOWING_KEY];
        //only update the follow icon if this is the correct user and also if the action was
        //no registered on this view
        
        if([userId isEqualToString:[self.channel.channelCreator objectId]]&&
               ([isFollowingAction boolValue] != self.currentUserFollowingChannelUser)){
                
			self.currentUserFollowingChannelUser = [isFollowingAction boolValue];
			if(self.followButton)[self updateUserFollowingChannel];
        }
    }
}

#pragma mark - Edit Cell formatting -

-(void)presentComment:(PFObject *) commentObject{
    
   
    PFUser * commentCreator = [commentObject valueForKey:COMMENT_USER_KEY];
    
    [commentCreator fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable user, NSError * _Nullable error) {
            NSString * commentString = [commentObject valueForKey:COMMENT_STRING];
            NSString * creatorName = [user valueForKey:VERBATM_USER_NAME_KEY];
        
            dispatch_async(dispatch_get_main_queue() , ^{
                
                
                
            });
        
    }];
}



-(void)setHeaderTitle{
	self.isHeaderTile = YES;
}

-(void)presentChannel:(Channel *) channel{
    self.channel = channel;
	PFUser *creator = [channel.parseChannelObject valueForKey:CHANNEL_CREATOR_KEY];
    
    if(!(self.channel.usersFollowingChannel && self.channel.usersFollowingChannel.count)){
        if(![[creator objectId] isEqualToString:[[PFUser currentUser] objectId]]){
			self.currentUserFollowingChannelUser = [[UserInfoCache sharedInstance] checkUserFollowsChannel: self.channel];
			if(self.followButton)[self updateUserFollowingChannel];
        }
        
    }else{
        self.currentUserFollowingChannelUser = [self.channel.usersFollowingChannel containsObject:[PFUser currentUser]];
        if(self.followButton)[self updateUserFollowingChannel];
    }
    
    
	[creator fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
		if(object) {
			NSString *userName = [creator valueForKey:VERBATM_USER_NAME_KEY];
			dispatch_async(dispatch_get_main_queue(), ^{
				[self setChannelName:channel.name andUserName: userName];
                
                if(![[creator objectId] isEqualToString:[[PFUser currentUser] objectId]])[self createFollowButton];
                
				[self setLabelsForChannel];
                [self updateUserFollowingChannel];
			});
		}
	}];
    
}

-(void) createFollowButton {
    
    if(self.followButton){
        [self.followButton removeFromSuperview];
        self.followButton = nil;
    }
    
    CGFloat frame_x = self.frame.size.width - PROFILE_HEADER_XOFFSET - LARGE_FOLLOW_BUTTON_WIDTH;
    CGRect followButtonFrame = CGRectMake(frame_x, TAB_BUTTON_PADDING_Y, LARGE_FOLLOW_BUTTON_WIDTH, LARGE_FOLLOW_BUTTON_HEIGHT);
    self.followButton = [[UIButton alloc] initWithFrame: followButtonFrame];
    self.followButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.followButton.clipsToBounds = YES;
    self.followButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.followButton.layer.borderWidth = 2.f;
    self.followButton.layer.cornerRadius = 10.f;
    [self.followButton addTarget:self action:@selector(followButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: self.followButton];
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
    if(self.followButton){
        if (self.currentUserFollowingChannelUser) {
            [self changeFollowButtonTitle:@"\u2713 Following" toColor:[UIColor whiteColor]];
            self.followButton.backgroundColor = [UIColor blackColor];
        } else {
            [self changeFollowButtonTitle:@"+ Follow" toColor:[UIColor blackColor]];
            self.followButton.backgroundColor = [UIColor whiteColor];
        }
    }
}

-(void) changeFollowButtonTitle:(NSString*)title toColor:(UIColor*) color{
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: color,
                                      NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:FOLLOW_TEXT_FONT_SIZE]};
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:titleAttributes];
    [self.followButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
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
	} else {
		if(self.headerTitle)[self.headerTitle removeFromSuperview];
		self.headerTitle = nil;
	}
    [self addCellSeperator];
}

-(void)addCellSeperator{
    if(!self.seperatorView){
        self.seperatorView = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.frame.size.height - CHANNEL_LIST_CELL_SEPERATOR_HEIGHT, self.frame.size.width,CHANNEL_LIST_CELL_SEPERATOR_HEIGHT)];
        self.seperatorView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.seperatorView];
    }
}

-(void) setLabelsForChannel{

    if(self.channelNameLabel){
        [self.channelNameLabel removeFromSuperview];
        
        self.channelNameLabel = nil;
    }
    if(self.usernameLabel){
        [self.usernameLabel removeFromSuperview];
        self.usernameLabel = nil;
    }

    CGPoint nameLabelOrigin = CGPointMake(TAB_BUTTON_PADDING_X,TAB_BUTTON_PADDING_Y);
	CGPoint channelNameLabelOrigin  = CGPointMake(TAB_BUTTON_PADDING_X,TAB_BUTTON_PADDING_Y + self.frame.size.height/3.f);
    
    CGFloat maxWidth=self.followButton.frame.origin.x - (TAB_BUTTON_PADDING_X * 2);
    
	self.channelNameLabel = [self getLabel:self.channelName withOrigin:channelNameLabelOrigin andAttributes:self.channelNameLabelAttributes withMaxWidth:maxWidth];
	self.usernameLabel = [self getLabel:self.userName withOrigin:nameLabelOrigin andAttributes:self.userNameLabelAttributes withMaxWidth:maxWidth];
    
	[self addSubview: self.channelNameLabel];
	[self addSubview: self.usernameLabel];
    
}


-(void)setLabelsForComment:(NSString *) comment andUserName:(NSString *) userName{
    
    if(self.commentLabel){
        [self.commentLabel removeFromSuperview];
        
        self.commentLabel = nil;
    }
    
    if(self.commentUserNameLabel){
        [self.commentUserNameLabel removeFromSuperview];
        self.commentUserNameLabel = nil;
    }
    
    CGPoint nameLabelOrigin = CGPointMake(TAB_BUTTON_PADDING_X,TAB_BUTTON_PADDING_Y);
    CGPoint channelNameLabelOrigin  = CGPointMake(TAB_BUTTON_PADDING_X,TAB_BUTTON_PADDING_Y + self.frame.size.height/3.f);
    
    CGFloat maxWidth = self.frame.size.width - (TAB_BUTTON_PADDING_X * 2);
    
    self.channelNameLabel = [self getLabel:comment withOrigin:channelNameLabelOrigin andAttributes:self.channelNameLabelAttributes withMaxWidth:maxWidth];
    self.usernameLabel = [self getLabel:comment withOrigin:nameLabelOrigin andAttributes:self.userNameLabelAttributes withMaxWidth:maxWidth];
    
    
    
    [self addSubview: self.commentLabel];
    [self addSubview: self.commentUserNameLabel];
    
}


-(void)setComment:(PFObject *) parseCommentObject{
    
    
    
    
    
    
}


-(UILabel *) getLabel:(NSString *) title withOrigin:(CGPoint) origin andAttributes:(NSDictionary *) nameLabelAttribute withMaxWidth:(CGFloat) maxWidth {
    UILabel * nameLabel = [[UILabel alloc] init];
    
    if(title && nameLabelAttribute){
        NSAttributedString* tabAttributedTitle = [[NSAttributedString alloc] initWithString:title attributes:nameLabelAttribute];
        CGSize textSize = [title sizeWithAttributes:nameLabelAttribute];

        CGFloat height = (textSize.height <= (self.frame.size.height/2.f) - 2.f) ?
        textSize.height : self.frame.size.height/2.f;
        
        CGFloat width = (maxWidth > 0 && textSize.width > maxWidth) ? maxWidth : textSize.width;
        
        CGRect labelFrame = CGRectMake(origin.x, origin.y, width, height +7.f);
        
        nameLabel.frame = labelFrame;
        nameLabel.adjustsFontSizeToFitWidth = YES;
        nameLabel.numberOfLines = 1.f;
        nameLabel.backgroundColor = [UIColor clearColor];
        [nameLabel setAttributedText:tabAttributedTitle];
    }
	return nameLabel;
}



-(void)createSelectedTextAttributes{
	NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
	paragraphStyle.alignment                = NSTextAlignmentCenter;
	self.channelNameLabelAttributes =@{NSForegroundColorAttributeName: [UIColor blackColor],
									   NSFontAttributeName: [UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWING_INFO_FONT size:CHANNEL_USER_LIST_CHANNEL_NAME_FONT_SIZE],
									   NSParagraphStyleAttributeName:paragraphStyle};

	//create "followers" text
	self.userNameLabelAttributes =@{NSForegroundColorAttributeName: [UIColor blackColor],
									NSFontAttributeName: [UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWERS_FONT size:CHANNEL_USER_LIST_USER_NAME_FONT_SIZE]};
}



-(UILabel *) getHeaderTitleForViewWithText:(NSString *) text{

	CGRect labelFrame = CGRectMake(0.f, 0.f, self.frame.size.width + 10, self.frame.size.height - 12.f);
	UILabel * titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
	titleLabel.backgroundColor = [UIColor whiteColor];

	NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
	paragraphStyle.alignment = NSTextAlignmentCenter;

	NSDictionary * informationAttribute = @{NSForegroundColorAttributeName:
												[UIColor clearColor],
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
