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
#import "ChannelButton.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "UserInfoCache.h"

@interface CustomScrollingTabBar()

// array of UIButtons
@property (strong, nonatomic) NSMutableArray* tabButtons;
@property (strong, nonatomic) NSMutableArray* channels;
@property (strong, nonatomic) ChannelButton * selectedTab;
@property (strong, nonatomic) UILabel *createChannelLabel;
@property (nonatomic) BOOL isLoggedInUser;

#define INITIAL_BUTTON_WIDTH 200.f

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


-(void)addNewChannelToList:(Channel *) channel {
    
    UIView * createChannelView = [self.tabButtons lastObject];
    CGPoint newChannelOrigin = createChannelView.frame.origin;
    ChannelButton *channelButton = [self getChannelTitleButton:channel andOrigin:newChannelOrigin];

	NSInteger index = [self.tabButtons indexOfObject:createChannelView];
    [self.tabButtons insertObject:channelButton atIndex: index];
	[self.channels insertObject:channel.name atIndex: index];
    
    CGRect newCreateChannelFrame = CGRectMake(channelButton.frame.origin.x + channelButton.frame.size.width,
                                              createChannelView.frame.origin.y,
                                              createChannelView.frame.size.width,
                                              createChannelView.frame.size.height);
    createChannelView.frame = newCreateChannelFrame;
    [self addSubview:channelButton];
	[self tabPressed: channelButton];
    [self adjustTabFramesToSuggestedSizes];
}

-(void) displayTabs: (NSArray*) channels withStartChannel:(Channel *) startChannel isLoggedInUser:(BOOL) isLoggedInUser {
	CGFloat xCoordinate = 0.f;
    NSInteger startChannelIndex = -1;
	self.isLoggedInUser = isLoggedInUser;
    for(Channel * channel in channels) {
        if(startChannel){
            if([startChannel.name isEqualToString:channel.name]){
                startChannelIndex = [channels indexOfObject:channel];
                [[UserInfoCache sharedInstance] setCurrentChannelIndex:startChannelIndex];
            }
        }
        
        //create channel title button
        CGPoint channelTitleOrigin = CGPointMake(xCoordinate, 0.f);
        ChannelButton* channelTitleButton = [self getChannelTitleButton:channel andOrigin:channelTitleOrigin];
		[self addSubview:channelTitleButton];
		//store button in our tab list
        [self.tabButtons addObject:channelTitleButton];
		[self.channels addObject: channel.name];
        //advance xCordinate
		xCoordinate += channelTitleButton.frame.size.width;
	}
    
	if(isLoggedInUser && channels.count < 1) { //todo: remove if more than 1 channel later
        CGFloat createChannelButtonWidth = (channels.count == 0) ? self.frame.size.width : INITIAL_BUTTON_WIDTH;
        
        CGRect createChannelButtonFrame = CGRectMake(xCoordinate, 0.f,
                                                     createChannelButtonWidth,
                                                     self.frame.size.height);
        
        UIButton * createChannelButton = [self getCreateChannelButtonWithFrame:createChannelButtonFrame];
        [self.tabButtons addObject:createChannelButton];
        [self addSubview:createChannelButton];
    }

    if(startChannelIndex == -1) startChannelIndex = 0;
    
    [self adjustTabFramesToSuggestedSizes];
	if(self.tabButtons.count > 1)[self selectTab: self.tabButtons[startChannelIndex]];
}

-(UIButton *)getCreateChannelButtonWithFrame:(CGRect) frame {
    UIButton * createChannelButton = [[UIButton alloc] initWithFrame:frame];
    //set background
    createChannelButton.backgroundColor = CHANNEL_TAB_BAR_BACKGROUND_COLOR_UNSELECTED;
    
    //add thin white border
    createChannelButton.layer.borderWidth = 0.3;
    createChannelButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.createChannelLabel = [[UILabel alloc] initWithFrame:createChannelButton.bounds];
    [self.createChannelLabel setText:@"+ Create Blog"];
    self.createChannelLabel.textAlignment = NSTextAlignmentCenter;
    [self.createChannelLabel setTextColor:VERBATM_GOLD_COLOR];
    [self.createChannelLabel setBackgroundColor:[UIColor clearColor]];
    [self.createChannelLabel setFont:[UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWERS_FONT size:CREATE_CHANNEL_BUTTON_FONT_SIZE]];
    
    [createChannelButton addSubview:self.createChannelLabel];
	[createChannelButton addTarget:self action:@selector(createChannelButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    return createChannelButton;
}

-(void)createChannelButtonSelected:(UIButton *) button{
    [self.customScrollingTabBarDelegate createNewChannel];
}

-(void)adjustContentSize{
    UIView * lastView = [self.tabButtons lastObject];
    self.contentSize = CGSizeMake(lastView.frame.origin.x + lastView.frame.size.width,0);
}

-(UIView *) getDividerAtPoint:(CGPoint) origin{
    UIView* tabDivider = [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y, TAB_DIVIDER_WIDTH, self.frame.size.height)];
    [tabDivider setBackgroundColor:[UIColor CHANNEL_TAB_BAR_DIVIDER_COLOR]];
    return tabDivider;
}

-(ChannelButton *) getChannelTitleButton:(Channel *) channel andOrigin: (CGPoint) origin{
	//create channel button
    CGRect buttonFrame = CGRectMake(origin.x, origin.y, INITIAL_BUTTON_WIDTH, self.frame.size.height);

    ChannelButton * newButton = [[ChannelButton alloc] initWithFrame:buttonFrame andChannel:channel isLoggedInUser:self.isLoggedInUser];
    [newButton addTarget:self action:@selector(tabPressed:) forControlEvents:UIControlEventTouchUpInside];
    return newButton;
}

-(void) tabPressed: (ChannelButton *) tabButton {
	[self unselectTab:self.selectedTab];
	[self selectTab:tabButton];
	[self.customScrollingTabBarDelegate tabPressedWithChannel:tabButton.currentChannel];
}

-(void) selectTab: (ChannelButton *) tab {
	NSInteger channelIndex = [self.tabButtons indexOfObject:tab];
	[tab markButtonAsSelected];
	//store this as the current tab index to view
	[[UserInfoCache sharedInstance] setCurrentChannelIndex: channelIndex];
	self.currentChannel = tab.currentChannel;
	self.selectedTab = tab;

	// Scroll to tab
	CGFloat channelOffset = 0.f;
	for (int i = 0; i < channelIndex; i++) {
		channelOffset += ((UIButton *)self.tabButtons[i]).frame.size.width;
	}
	//Show half of previous tab
	if (channelOffset > 0) channelOffset -= ((UIButton *)self.tabButtons[channelIndex-1]).frame.size.width/2.f;
	[UIView animateWithDuration:0.2f animations:^{
		self.contentOffset = CGPointMake(channelOffset, 0.f);
	}completion:^ (BOOL finished) {
	}];
}

-(void) selectChannel: (Channel*) channel {
	NSInteger index = [self.channels indexOfObject: channel.name];
	if (index == NSNotFound) return;
	[self tabPressed: self.tabButtons[index]];
}

-(void) unselectTab: (ChannelButton*) tab {
    [tab markButtonAsUnselected];
}

//channel button protocol function
//we adjust the frame of this button then shift everything else over
-(void)adjustTabFramesToSuggestedSizes{
    NSUInteger originDiff = 0;
    for(int i = 0; i < self.tabButtons.count; i++) {
        UIButton *currentButton = self.tabButtons[i];
        CGFloat width = ([currentButton isKindOfClass:[ChannelButton class]]) ? [(ChannelButton *)currentButton suggestedWidth] : ((TAB_BUTTON_PADDING * 3.f) + self.createChannelLabel.frame.size.width);
        
        //check if it's the last button in the scroll bar
        if(i == (self.tabButtons.count-1)){
            if(self.isLoggedInUser) {
                //it's the "create new channel button"
                //so we allow it to maintain the width we calculated earlier
                width = ((UIView*)currentButton).frame.size.width;
            } else{
                if(self.tabButtons.count == 1){
                    width = self.frame.size.width;
                }
            }
        }
        
        ((UIView *)currentButton).frame = CGRectMake(originDiff, ((UIView *)currentButton).frame.origin.y, width, ((UIView *)currentButton).frame.size.height);
        
        if(self.isLoggedInUser && [currentButton isKindOfClass:[ChannelButton class]]){
            [(ChannelButton *)currentButton recenterTextLabels];
        }
        
        [currentButton setNeedsDisplay];
        originDiff += width;
    }
    [self adjustContentSize];
}


#pragma mark - Lazy Instantiation -

-(NSMutableArray*) tabButtons {
	if (!_tabButtons) {
		_tabButtons = [[NSMutableArray alloc] init];
	}
	return _tabButtons;
}

-(NSMutableArray*) channels {
	if (!_channels) {
		_channels = [[NSMutableArray alloc] init];
	}
	return _channels;
}

@end
