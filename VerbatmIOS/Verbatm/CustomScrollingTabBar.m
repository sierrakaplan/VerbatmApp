//
//  CustomScrollingTabBar.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/3/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "CustomTab.h"
#import "CustomScrollingTabBar.h"
#import "Channel.h"

#import "Styles.h"

@interface CustomScrollingTabBar()

// array of UIButtons
@property (strong, nonatomic) NSMutableArray* tabs;
@property (strong, nonatomic) UIButton* selectedTab;
@property (strong, nonatomic) NSDictionary* tabTitleAttributes;
@property (strong, nonatomic) NSDictionary* selectedTabTitleAttributes;

#define TAB_BUTTON_PADDING 25.f
#define TAB_DIVIDER_WIDTH 2.f
#define TAB_DIVIDER_COLOR clearColor

@end

@implementation CustomScrollingTabBar

-(instancetype) initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setBackgroundColor:[UIColor clearColor]];
		self.scrollEnabled = YES;
		self.showsHorizontalScrollIndicator = NO;
		self.bounces = NO;
	}
	return self;
}

-(void) displayTabs: (NSArray*) channels {
	CGFloat xCoordinate = 0.f;
	for(Channel * channel in channels) {
        //create channel title button
        CGPoint channelTitleOrigin = CGPointMake(xCoordinate, 0.f);
        UIButton * channelTitleButton = [self getChannelTitleButton:channel andOrigin:channelTitleOrigin];
		[self addSubview:channelTitleButton];
		//store button in our tab list
        [self.tabs addObject:channelTitleButton];
        
        //advance xCordinate
		xCoordinate += channelTitleButton.frame.size.width;

		//add divider | between buttons
        //CGPoint dividerOrigin = CGPointMake(xCoordinate, 0.f);
		//[self addSubview:[self getDividerAtPoint:dividerOrigin]];
        
        //advance xCoordinate
		//xCoordinate += TAB_DIVIDER_WIDTH;
	}
	self.contentSize = CGSizeMake(xCoordinate, 0);
	[self selectTab: self.tabs[0]];
}

-(UIView *) getDividerAtPoint:(CGPoint) origin{
    UIView* tabDivider = [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y, TAB_DIVIDER_WIDTH, self.frame.size.height)];
    [tabDivider setBackgroundColor:[UIColor TAB_DIVIDER_COLOR]];
    return tabDivider;
}

-(UIButton *) getChannelTitleButton:(Channel *) channel andOrigin: (CGPoint) origin{
  
    
    CGPoint nameLabelOrigin = CGPointMake(0.f,0.f);
    UILabel * nameLabel = [self getChannelNameLabel:channel withOrigin:nameLabelOrigin];
    
    CGPoint numFollowersOrigin = CGPointMake(0.f,self.frame.size.height/2.f);
    UILabel * followerNumberLabel = [self getChannelFollowersLabel:channel andOrigin:numFollowersOrigin];
    
    
    
    
    CGFloat buttonWidth = TAB_BUTTON_PADDING + ((followerNumberLabel.frame.size.width > nameLabel.frame.size.width) ?
                            followerNumberLabel.frame.size.width : nameLabel.frame.size.width);
    
    //create channel button
    CGRect buttonFrame = CGRectMake(origin.x, origin.y, buttonWidth, self.frame.size.height);
    
    
    //adjust label frame sizes to be the same with some padding
    nameLabel.frame = CGRectMake(buttonWidth/2.f - nameLabel.frame.size.width/2.f, nameLabel.frame.origin.y,nameLabel.frame.size.width, nameLabel.frame.size.height);
    followerNumberLabel.frame = CGRectMake(buttonWidth/2.f - followerNumberLabel.frame.size.width/2.f, followerNumberLabel.frame.origin.y, followerNumberLabel.frame.size.width, followerNumberLabel.frame.size.height);
    
    
    UIButton * newButton = [[UIButton alloc] initWithFrame:buttonFrame];
    newButton.backgroundColor = [UIColor clearColor];
    
    newButton.layer.borderWidth = 0.3;
    newButton.layer.borderColor = [UIColor whiteColor].CGColor;

    [newButton addSubview:nameLabel];
    [newButton addSubview:followerNumberLabel];
    
    [newButton addTarget:self action:@selector(tabPressed:) forControlEvents:UIControlEventTouchUpInside];
    return newButton;
}

-(NSAttributedString *)getAttributedStringFromChannel:(Channel *) channel{
    NSAttributedString* tabAttributedTitle = [[NSAttributedString alloc] initWithString:channel.name attributes:self.tabTitleAttributes];
    return tabAttributedTitle;
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

-(void) tabPressed: (UIButton*) tabButton {
	[self unselectTab:self.selectedTab];
	[self selectTab:tabButton];
	[self.customScrollingTabBarDelegate tabPressedWithTitle:[tabButton attributedTitleForState: UIControlStateNormal].string];
}

-(void) selectTab: (UIButton*) tab {
//	[tab setAttributedTitle:[[NSAttributedString alloc] initWithString:[tab attributedTitleForState: UIControlStateNormal].string
//															attributes: self.selectedTabTitleAttributes] forState:UIControlStateNormal];
	self.selectedTab = tab;
}

-(void) unselectTab: (UIButton*) tab {
//	[tab setAttributedTitle:[[NSAttributedString alloc] initWithString:[tab attributedTitleForState: UIControlStateNormal].string
//																  attributes:self.tabTitleAttributes] forState:UIControlStateNormal];
}

#pragma mark - Lazy Instantiation -

-(NSMutableArray*) tabs {
	if (!_tabs) {
		_tabs = [[NSMutableArray alloc] init];
	}
	return _tabs;
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

@end
