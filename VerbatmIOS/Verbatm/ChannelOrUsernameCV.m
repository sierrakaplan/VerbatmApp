//
//  ChannelOrUsernameCV.m
//  Verbatm
//
//  Created by Iain Usiri on 1/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "ChannelOrUsernameCV.h"

#import "Follow_BackendManager.h"

#import "SizesAndPositions.h"
#import "Styles.h"
#import <Parse/PFObject.h>
#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>

@import UIKit;

@interface ChannelOrUsernameCV ()
@property (nonatomic) Channel *channel;

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
@property (nonatomic) UIButton * followButton;
@property (nonatomic) BOOL currentUserFollowingChannelUser;

#define CHANNEL_LIST_CELL_SEPERATOR_HEIGHT 1.f
#define FOLLOW_BUTTON_SIZE 100.f


@end

@implementation ChannelOrUsernameCV

- (void)awakeFromNib {
	// Initialization code
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isChannel:(BOOL) isChannel isAChannelThatIFollow:(BOOL) channelThatIFollow {
	self = [super initWithStyle: style reuseIdentifier: reuseIdentifier] ;

	if (self) {

        self.backgroundColor = [UIColor whiteColor];
		self.isAChannel = isChannel;
        self.clipsToBounds = YES;
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
    self.channel = channel;
	PFObject *creator = [channel.parseChannelObject valueForKey:CHANNEL_CREATOR_KEY];
    
    if(!(self.channel.usersFollowingChannel && self.channel.usersFollowingChannel.count)){
        
        [self.channel getFollowersAndFollowingWithCompletionBlock:^{
            self.currentUserFollowingChannelUser = [self.channel.usersFollowingChannel containsObject:[PFUser currentUser]];
            if(self.followButton)[self updateUserFollowingChannel];
        }];
    }else{
        self.currentUserFollowingChannelUser = [self.channel.usersFollowingChannel containsObject:[PFUser currentUser]];
        if(self.followButton)[self updateUserFollowingChannel];
    }
    
    
	[creator fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
		if(object) {
			NSString *userName = [creator valueForKey:VERBATM_USER_NAME_KEY];
			dispatch_async(dispatch_get_main_queue(), ^{
				[self setChannelName:channel.name andUserName: userName];
                [self createFollowOrEditButton];
				[self setLabelsForChannel];
                [self updateUserFollowingChannel];
			});
		}
	}];
    
}

-(void) createFollowOrEditButton {
    CGFloat frame_x = self.frame.size.width - PROFILE_HEADER_XOFFSET - FOLLOW_BUTTON_SIZE;
    CGRect followButtonFrame = CGRectMake(frame_x, TAB_BUTTON_PADDING_Y, FOLLOW_BUTTON_SIZE, FOLLOW_BUTTON_SIZE/3.f);
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
        [Follow_BackendManager user:[PFUser currentUser] stopFollowingChannel: self.channel];
    }
    [self.channel currentUserFollowsChannel: self.currentUserFollowingChannelUser];
    [self updateUserFollowingChannel];
}
-(void) updateUserFollowingChannel {
    //todo: images
    if (self.currentUserFollowingChannelUser) {
        [self changeFollowButtonTitle:@"Following" toColor:[UIColor whiteColor]];
        self.followButton.backgroundColor = [UIColor blackColor];
    } else {
        [self changeFollowButtonTitle:@"Follow" toColor:[UIColor blackColor]];
        self.followButton.backgroundColor = [UIColor whiteColor];
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

	CGPoint nameLabelOrigin = CGPointMake(TAB_BUTTON_PADDING_X,TAB_BUTTON_PADDING_Y);
	CGPoint channelNameLabelOrigin  = CGPointMake(TAB_BUTTON_PADDING_X,TAB_BUTTON_PADDING_Y + self.frame.size.height/3.f);
    
    CGFloat maxWidth=self.followButton.frame.origin.x - (TAB_BUTTON_PADDING_X * 2);
    
	self.channelNameLabel = [self getLabel:self.channelName withOrigin:channelNameLabelOrigin andAttributes:self.channelNameLabelAttributes withMaxWidth:maxWidth];
	self.usernameLabel = [self getLabel:self.userName withOrigin:nameLabelOrigin andAttributes:self.userNameLabelAttributes withMaxWidth:maxWidth];
    
	[self addSubview: self.channelNameLabel];
	[self addSubview: self.usernameLabel];
    
    
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
