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
@property (strong, nonatomic) NSMutableArray* tabs;
@property (strong, nonatomic) ChannelButtons * selectedTab;


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
    
    UIView * createChannelView = [self.tabs lastObject];
    CGPoint newChannelOrigin = createChannelView.frame.origin;
    UIButton * channelButton = [self getChannelTitleButton:channel andOrigin:newChannelOrigin];
    
    [self.tabs insertObject:channelButton atIndex:[self.tabs indexOfObject:createChannelView]];
    
    CGRect newCreateChannelFrame = CGRectMake(channelButton.frame.origin.x + channelButton.frame.size.width,
                                              createChannelView.frame.origin.y,
                                              createChannelView.frame.size.width,
                                              createChannelView.frame.size.height);
    createChannelView.frame = newCreateChannelFrame;
    [self addSubview:channelButton];
    [self adjustTabFramesToSuggestedSizes];
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
	}
    
    CGFloat createChannelButtonWidth = (channels.count == 0) ? self.frame.size.width : INITIAL_BUTTON_WIDTH;
    
    
    CGRect createChannelButtonFrame = CGRectMake(xCoordinate, 0.f,
                                                 createChannelButtonWidth,
                                                 self.frame.size.height);
    
    UIButton * createChannelButton = [self getCreateChannelButtonWithFrame:createChannelButtonFrame];
    [self.tabs addObject:createChannelButton];
    [self addSubview:createChannelButton];
    
    [self adjustTabFramesToSuggestedSizes];
	if(self.tabs.count > 1)[self selectTab: self.tabs[0]];
    
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
    UIView * lastView = [self.tabs lastObject];
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
    
	self.selectedTab = tab;
}

-(void) unselectTab: (ChannelButtons*) tab {
    [tab markButtonAsUnselected];
}



//channel button protocol function
//we adjust the frame of this button then shift everything else over
-(void)adjustTabFramesToSuggestedSizes{
    NSUInteger originDiff = 0;
    for(int i = 0; i < self.tabs.count; i++) {
        id currentButton = self.tabs[i];
        
        
        
        CGFloat width = ([currentButton isKindOfClass:[ChannelButtons class]]) ? [(ChannelButtons *)currentButton suggestedWidth] : ((UIView *)currentButton).frame.size.width;
        
        if(i == (self.tabs.count-1)) width = ((UIView*)currentButton).frame.size.width;
        
        ((UIView *)currentButton).frame = CGRectMake(originDiff, ((ChannelButtons *)currentButton).frame.origin.y, width, ((UIView *)currentButton).frame.size.height);
        originDiff += width;
    }
    [self adjustContentSize];
}


#pragma mark - Lazy Instantiation -

-(NSMutableArray*) tabs {
	if (!_tabs) {
		_tabs = [[NSMutableArray alloc] init];
	}
	return _tabs;
}


@end
