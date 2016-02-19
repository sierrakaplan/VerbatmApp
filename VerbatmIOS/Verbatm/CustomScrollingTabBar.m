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
#import "ChannelButtons.h"
#import "SizesAndPositions.h"
#import "Styles.h"

@interface CustomScrollingTabBar()

// array of UIButtons
@property (strong, nonatomic) NSMutableArray* tabButtons;
@property (strong, nonatomic) NSMutableArray* channels;
@property (strong, nonatomic) ChannelButtons * selectedTab;
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
    UIButton * channelButton = [self getChannelTitleButton:channel andOrigin:newChannelOrigin];

	NSInteger index = [self.tabButtons indexOfObject:createChannelView];
    [self.tabButtons insertObject:channelButton atIndex: index];
	[self.channels insertObject:channel atIndex: index];
    
    CGRect newCreateChannelFrame = CGRectMake(channelButton.frame.origin.x + channelButton.frame.size.width,
                                              createChannelView.frame.origin.y,
                                              createChannelView.frame.size.width,
                                              createChannelView.frame.size.height);
    createChannelView.frame = newCreateChannelFrame;
    [self addSubview:channelButton];
    [self adjustTabFramesToSuggestedSizes];
}

-(void) displayTabs: (NSArray*) channels withStartChannel:(Channel *) startChannel isLoggedInUser:(BOOL) isLoggedInUser {
	CGFloat xCoordinate = 0.f;
    NSInteger startChannelIndex = -1;
	for(Channel * channel in channels) {

        if(startChannel){
            if([startChannel.name isEqualToString:channel.name]){
                startChannelIndex = [channels indexOfObject:channel];
            }
        }
        
        //create channel title button
        CGPoint channelTitleOrigin = CGPointMake(xCoordinate, 0.f);
        UIButton * channelTitleButton = [self getChannelTitleButton:channel andOrigin:channelTitleOrigin];
		[self addSubview:channelTitleButton];
		//store button in our tab list
        [self.tabButtons addObject:channelTitleButton];
		[self.channels addObject: channel];
        
        //advance xCordinate
		xCoordinate += channelTitleButton.frame.size.width;
	}

    self.isLoggedInUser = isLoggedInUser;
    if(isLoggedInUser) {
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
    
    UILabel * textLabel = [[UILabel alloc] initWithFrame:createChannelButton.bounds];
    [textLabel setText:@"+ Create Channel"];
    textLabel.textAlignment = NSTextAlignmentCenter;
    [textLabel setTextColor:VERBATM_GOLD_COLOR];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setFont:[UIFont fontWithName:TAB_BAR_FOLLOWERS_FONT size:CREATE_CHANNEL_BUTTON_FONT_SIZE]];
    
    [createChannelButton addSubview:textLabel];
    
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
    [tabDivider setBackgroundColor:[UIColor TAB_DIVIDER_COLOR]];
    return tabDivider;
}

-(ChannelButtons *) getChannelTitleButton:(Channel *) channel andOrigin: (CGPoint) origin{
    
    //create channel button
    CGRect buttonFrame = CGRectMake(origin.x, origin.y, INITIAL_BUTTON_WIDTH, self.frame.size.height);

    ChannelButtons * newButton = [[ChannelButtons alloc] initWithFrame:buttonFrame andChannel:channel];
    [newButton addTarget:self action:@selector(tabPressed:) forControlEvents:UIControlEventTouchUpInside];
    return newButton;
}


-(void) tabPressed: (ChannelButtons *) tabButton {
	[self unselectTab:self.selectedTab];
	[self selectTab:tabButton];
	[self.customScrollingTabBarDelegate tabPressedWithChannel:tabButton.currentChannel];
}

-(void) selectTab: (ChannelButtons *) tab {
    [tab markButtonAsSelected];
    self.currentChannel = tab.currentChannel;
	self.selectedTab = tab;
}

-(void) selectChannel: (Channel*) channel {
	NSInteger index = [self.channels indexOfObject: channel];
	if (index == NSNotFound) return;
	[self tabPressed: self.tabButtons[index]];
}

-(void) unselectTab: (ChannelButtons*) tab {
    [tab markButtonAsUnselected];
}

//channel button protocol function
//we adjust the frame of this button then shift everything else over
-(void)adjustTabFramesToSuggestedSizes{
    NSUInteger originDiff = 0;
    for(int i = 0; i < self.tabButtons.count; i++) {
        id currentButton = self.tabButtons[i];
        CGFloat width = ([currentButton isKindOfClass:[ChannelButtons class]]) ? [(ChannelButtons *)currentButton suggestedWidth] : ((UIView *)currentButton).frame.size.width;
        
        if(i == (self.tabButtons.count-1)) width = ((UIView*)currentButton).frame.size.width;
        
        ((UIView *)currentButton).frame = CGRectMake(originDiff, ((ChannelButtons *)currentButton).frame.origin.y, width, ((UIView *)currentButton).frame.size.height);
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


@end
