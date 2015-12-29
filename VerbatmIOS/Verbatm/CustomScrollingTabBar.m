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
    [self adjustTabFramesToSuggestedSizes];
	[self selectTab: self.tabs[0]];
    
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
	[self.customScrollingTabBarDelegate tabPressedWithTitle:tabButton.channelName];
}

-(void) selectTab: (ChannelButtons *) tab {
//    [tab setAttributedTitle:[[NSAttributedString alloc] initWithString:tab.channelName
//															attributes: self.selectedTabTitleAttributes] forState:UIControlStateNormal];
	self.selectedTab = tab;
}

-(void) unselectTab: (ChannelButtons*) tab {
//	[tab setAttributedTitle:[[NSAttributedString alloc] initWithString:tab.channelName
//																  attributes:self.tabTitleAttributes] forState:UIControlStateNormal];
}



//channel button protocol function
//we adjust the frame of this button then shift everything else over
-(void)adjustTabFramesToSuggestedSizes{
    NSUInteger originDiff = 0;
    for(int i = 0; i < self.tabs.count; i++) {
        ChannelButtons * currentButton = self.tabs[i];
        CGFloat width = [currentButton suggestedWidth];
        currentButton.frame = CGRectMake(originDiff, currentButton.frame.origin.y, width, currentButton.frame.size.height);
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
