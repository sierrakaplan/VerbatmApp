
//
//  ChannelButtons.m
//  Verbatm
//
//  Created by Iain Usiri on 11/28/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "Channel.h"
#import "ChannelButton.h"
#import "BlogPopupView.h"

#import "Icons.h"

#import "Follow_BackendManager.h"

#import "SizesAndPositions.h"
#import "Styles.h"

#import <Parse/PFUser.h>

@interface ChannelButton ()
@property (nonatomic,strong) UILabel *channelNameLabel;
@property (nonatomic, strong) UILabel *numberOfFollowersLabel;

@property (strong, nonatomic) NSDictionary *unSelectedFollowersTabTitleAttributes;
@property (strong, nonatomic) NSDictionary *unSelectedNumberOfFollowersTitleAttributes;
@property (strong, nonatomic) NSDictionary *unSelectedChannelNameTitleAttributes;

@property (strong, nonatomic) NSDictionary *selectedFollowersTabTitleAttributes;
@property (strong, nonatomic) NSDictionary *selectedNumberOfFollowersTitleAttributes;
@property (strong, nonatomic) NSDictionary *selectedChannelNameTitleAttributes;

@property (nonatomic, readwrite) NSString *channelName;

@property (nonatomic, readwrite) CGFloat suggestedWidth;

@property (nonatomic, readwrite) Channel *currentChannel;

@property (nonatomic) UIButton *followButton;
@property (nonatomic) NSNumber *numFollowers;
@property (nonatomic) BOOL isFollowingProfileUser;
@property (nonatomic) BOOL isLoggedInUser;
@property (nonatomic) BOOL buttonSelected;
@property (nonatomic) UIViewController *topVC;
@property (nonatomic) BlogPopupView *blogPopupView;
@end

@implementation ChannelButton

-(instancetype) initWithFrame:(CGRect)frame andChannel:(Channel *) channel isLoggedInUser:(BOOL) isLoggedInUser {

    self = [super initWithFrame:frame];
    
    if(self){
        self.channelName = channel.name;
        self.currentChannel = channel;
        self.isLoggedInUser = isLoggedInUser;
        [self setTopViewController];
        [self createNonSelectedTextAttributes];
        [self createSelectedTextAttributes];
        [self setLabelsFromChannel:channel];
        [self formatButtonUnSelected];
        UILongPressGestureRecognizer *btn_LongPress_gesture = [[UILongPressGestureRecognizer alloc]
                                                               initWithTarget:self action:@selector(handleBtnLongPressGesture:)];
        [self addGestureRecognizer:btn_LongPress_gesture];
    }
    return self;
}

-(void) setTopViewController {
    UIViewController *top = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (top.presentedViewController){
        top = top.presentedViewController;
    }
    self.topVC = top;
}

- (void)handleBtnLongPressGesture:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        self.blogPopupView = [[BlogPopupView alloc] initWithFrame:CGRectMake(screenWidth/8.f, screenHeight/8.f, (screenWidth * 0.75), (screenHeight * 0.75)) forBlog:self.currentChannel];
       
        [UIView animateWithDuration:0.5 animations:^{
            [self.topVC.view addSubview:self.blogPopupView];
            [self.topVC.view bringSubviewToFront:self.blogPopupView];
        }];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
    }
}

-(void) setLabelsFromChannel:(Channel *) channel{
    
    CGPoint nameLabelOrigin = CGPointMake(0.f,0.f);
    self.channelNameLabel = [self getChannelNameLabel:channel withOrigin:nameLabelOrigin andAttributes:self.unSelectedChannelNameTitleAttributes];
    
    CGPoint numFollowersOrigin = CGPointMake(0.f,self.frame.size.height/2.f);
    self.numberOfFollowersLabel = [self getChannelFollowersLabel:channel origin:numFollowersOrigin followersTextAttribute:self.unSelectedFollowersTabTitleAttributes andNumberOfFollowersAttribute:self.unSelectedNumberOfFollowersTitleAttributes];
    
    CGFloat buttonWidth = (TAB_BUTTON_PADDING_X * 3.f) + FOLLOW_BUTTON_WIDTH + ((self.numberOfFollowersLabel.frame.size.width > self.channelNameLabel.frame.size.width) ? self.numberOfFollowersLabel.frame.size.width :  self.channelNameLabel.frame.size.width);
    
    //adjust label frame sizes to be the same with some padding
     self.channelNameLabel.frame = CGRectMake(TAB_BUTTON_PADDING_X,
                                              self.channelNameLabel.frame.origin.y,
                                              self.channelNameLabel.frame.size.width,
                                              self.channelNameLabel.frame.size.height);

    CGFloat numFollowersLabelX;
    if(self.numberOfFollowersLabel.frame.size.width > self.channelNameLabel.frame.size.width){
        numFollowersLabelX = TAB_BUTTON_PADDING_X;
    } else {
        numFollowersLabelX = self.channelNameLabel.center.x - (self.numberOfFollowersLabel.frame.size.width/2.f);
    }
    
    self.numberOfFollowersLabel.frame = CGRectMake(numFollowersLabelX,
                                                   self.numberOfFollowersLabel.frame.origin.y,
                                                   self.numberOfFollowersLabel.frame.size.width,
                                                   self.numberOfFollowersLabel.frame.size.height);
    
    [self addSubview: self.channelNameLabel];
    [self addSubview: self.numberOfFollowersLabel];
    
    //tell our parent view to adjust our size
    self.suggestedWidth = buttonWidth;
    
    if(!self.isLoggedInUser){
        [self createFollowIcon];
    }
}

-(void)createFollowIcon{
    [Follow_BackendManager currentUserFollowsChannel:self.currentChannel withCompletionBlock:^(bool isFollowing) {
		self.isFollowingProfileUser = isFollowing;
          dispatch_async(dispatch_get_main_queue(), ^{
              [self createFollowButton];
          });
     }];
}

//If it's my profile it's follower(s) and if it's someone else's profile
//it's follow
-(void) createFollowButton {
    if(self.followButton){
        [self.followButton removeFromSuperview];
        self.followButton = nil;
    }
    
    CGFloat height = FOLLOW_BUTTON_HEIGHT;
    CGFloat width = FOLLOW_BUTTON_WIDTH;
    CGFloat frame_x = self.suggestedWidth - width - (TAB_BUTTON_PADDING_X);
    CGFloat frame_y = self.center.y - (height/2.f);
    
    CGRect iconFrame = CGRectMake(frame_x, frame_y, width, height);
    
    self.followButton = [[UIButton alloc] initWithFrame:iconFrame];
	[self updateFollowingIconSelected: self.buttonSelected];
    [self.followButton addTarget:self action:@selector(followButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.followButton];
}

-(void) followButtonSelected {
    if(self.buttonSelected) {
		self.isFollowingProfileUser = !self.isFollowingProfileUser;
        if(self.isFollowingProfileUser) {
			self.numFollowers = [NSNumber numberWithInteger:([self.numFollowers integerValue]+1)];
            [Follow_BackendManager currentUserFollowChannel:self.currentChannel];
        } else {
			self.numFollowers = [NSNumber numberWithInteger:([self.numFollowers integerValue]-1)];
			[Follow_BackendManager user:[PFUser currentUser] stopFollowingChannel:self.currentChannel];
        }
        [self updateFollowingIconSelected:YES];
		[self changeNumFollowersLabel];
    } else {
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

-(UILabel *) getChannelFollowersLabel:(Channel *) channel origin:(CGPoint) origin
			   followersTextAttribute:(NSDictionary *) followersTextAttribute
		andNumberOfFollowersAttribute:(NSDictionary *) numberOfFollowersAttribute {

	//create bolded number
	NSString * numberOfFollowers = @"0";

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

	[Follow_BackendManager numberUsersFollowingChannel:channel withCompletionBlock:^(NSNumber *numFollowers) {
		self.numFollowers = numFollowers;
		[self changeNumFollowersLabel];
	}];

	return followersLabel;
}

-(void) updateFollowingIconSelected: (BOOL) selected {
	UIImage * newbuttonImage;
	if(self.isFollowingProfileUser) {
		newbuttonImage  = selected ? [UIImage imageNamed:FOLLOWING_ICON_DARK] : [UIImage imageNamed:FOLLOWING_ICON_LIGHT];
	} else {
		newbuttonImage  = selected ? [UIImage imageNamed:FOLLOW_ICON_DARK] : [UIImage imageNamed:FOLLOW_ICON_LIGHT];
	}
	[self.followButton setImage:newbuttonImage forState:UIControlStateNormal];
}

- (void) changeNumFollowersLabel {
	NSMutableAttributedString *currentFollowersLabelText = [[NSMutableAttributedString alloc]
															initWithAttributedString: self.numberOfFollowersLabel.attributedText];
	NSString *numberOfFollowers = [self.numFollowers stringValue];
	[currentFollowersLabelText.mutableString setString:[numberOfFollowers stringByAppendingString:@" Follower(s)"]];
	[self.numberOfFollowersLabel setAttributedText: currentFollowersLabelText];
}

-(void) markButtonAsSelected {
	NSMutableAttributedString *currentFollowersLabelText = [[NSMutableAttributedString alloc]
															initWithAttributedString: self.numberOfFollowersLabel.attributedText];
	[currentFollowersLabelText setAttributes:self.selectedFollowersTabTitleAttributes
									   range:(NSRange){0,[currentFollowersLabelText length]}];
	[self.numberOfFollowersLabel setAttributedText: currentFollowersLabelText];

	NSMutableAttributedString *currentChannelNameLabelText = [[NSMutableAttributedString alloc]
															initWithAttributedString: self.channelNameLabel.attributedText];
	[currentChannelNameLabelText setAttributes:self.selectedChannelNameTitleAttributes
										 range:(NSRange){0,[currentChannelNameLabelText length]}];
	[self.channelNameLabel setAttributedText: currentChannelNameLabelText];
	[self updateFollowingIconSelected:YES];
    [self formatButtonSelected];
    self.buttonSelected = YES;
}

-(void) markButtonAsUnselected {

	NSMutableAttributedString *currentFollowersLabelText = [[NSMutableAttributedString alloc]
															initWithAttributedString: self.numberOfFollowersLabel.attributedText];
	[currentFollowersLabelText setAttributes:self.unSelectedFollowersTabTitleAttributes
									   range:(NSRange){0,[currentFollowersLabelText length]}];
	[self.numberOfFollowersLabel setAttributedText: currentFollowersLabelText];


	NSMutableAttributedString *currentChannelNameLabelText = [[NSMutableAttributedString alloc]
															  initWithAttributedString: self.channelNameLabel.attributedText];
	[currentChannelNameLabelText setAttributes:self.unSelectedChannelNameTitleAttributes
										 range:(NSRange){0,[currentChannelNameLabelText length]}];
	[self.channelNameLabel setAttributedText: currentChannelNameLabelText];
	[self updateFollowingIconSelected:NO];
    [self formatButtonUnSelected];
    self.buttonSelected = NO;
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

//should be recentered in specific scenarious
//1) if in current user profile so there's no follow icon
//2) if in general user profile and there's only one channel
-(void)recenterTextLabels {
    [self centerViewFrame_XCord:self.channelNameLabel];
    [self centerViewFrame_XCord:self.numberOfFollowersLabel];
}

-(void)centerViewFrame_XCord:(UIView *)view{
    view.frame = CGRectMake((self.frame.size.width/2.f) - (view.frame.size.width/2.f), view.frame.origin.y, view.frame.size.width, view.frame.size.height);
}

-(void)createNonSelectedTextAttributes{
	NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
	paragraphStyle.alignment = NSTextAlignmentCenter;

	self.unSelectedNumberOfFollowersTitleAttributes =@{NSForegroundColorAttributeName: [UIColor whiteColor],
													   NSFontAttributeName: CHANNEL_TAB_BAR_FOLLOWERS_FONT_ATTRIBUTE,
													   NSParagraphStyleAttributeName:paragraphStyle};

	self.unSelectedFollowersTabTitleAttributes =@{NSForegroundColorAttributeName: [UIColor whiteColor],
												  NSFontAttributeName: CHANNEL_TAB_BAR_FOLLOWERS_FONT_ATTRIBUTE};

	self.unSelectedChannelNameTitleAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
												  NSFontAttributeName: CHANNEL_TAB_BAR_NAME_FONT_ATTRIBUTE,
												  NSParagraphStyleAttributeName:paragraphStyle};
}

-(void)createSelectedTextAttributes{
	NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
	paragraphStyle.alignment                = NSTextAlignmentCenter;
	self.selectedNumberOfFollowersTitleAttributes =@{NSForegroundColorAttributeName: [UIColor blackColor],
														NSFontAttributeName: CHANNEL_TAB_BAR_FOLLOWERS_FONT_ATTRIBUTE,
													 NSParagraphStyleAttributeName:paragraphStyle};

	self.selectedFollowersTabTitleAttributes =@{NSForegroundColorAttributeName: [UIColor blackColor],
												NSFontAttributeName: CHANNEL_TAB_BAR_FOLLOWERS_FONT_ATTRIBUTE};

	self.selectedChannelNameTitleAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
												NSFontAttributeName: CHANNEL_TAB_BAR_NAME_FONT_ATTRIBUTE,
												NSParagraphStyleAttributeName:paragraphStyle};
}

@end
