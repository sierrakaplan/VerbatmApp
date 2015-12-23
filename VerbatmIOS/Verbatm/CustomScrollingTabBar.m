//
//  CustomScrollingTabBar.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/3/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "CustomTab.h"
#import "CustomScrollingTabBar.h"
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
		[self setBackgroundColor:[UIColor colorWithWhite:1.f alpha: TAB_BAR_ALPHA]];
		self.scrollEnabled = YES;
		self.showsHorizontalScrollIndicator = NO;
		self.bounces = NO;
	}
	return self;
}

-(void) displayTabs: (NSArray*) tabTitles {
	CGFloat xCoordinate = 0.f;
	for(NSString *tabTitle in tabTitles) {
		NSAttributedString* tabAttributedTitle = [[NSAttributedString alloc] initWithString:tabTitle attributes:self.tabTitleAttributes];
		CGSize textSize = [tabTitle sizeWithAttributes:self.selectedTabTitleAttributes];
		CGFloat tabWidth = textSize.width + TAB_BUTTON_PADDING;

		CGRect buttonFrame = CGRectMake(xCoordinate, 0.f, tabWidth, self.frame.size.height);
		UIButton * newButton = [[UIButton alloc] initWithFrame:buttonFrame];
		newButton.backgroundColor = [UIColor clearColor];
		[newButton setAttributedTitle:tabAttributedTitle forState:UIControlStateNormal];
		[newButton addTarget:self action:@selector(tabPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:newButton];
		[self.tabs addObject:newButton];
		xCoordinate += tabWidth;

		UIView* tabDivider = [[UIView alloc] initWithFrame:CGRectMake(xCoordinate, 0.f, TAB_DIVIDER_WIDTH, self.frame.size.height)];
		[tabDivider setBackgroundColor:[UIColor TAB_DIVIDER_COLOR]];
		[self addSubview:tabDivider];
		xCoordinate += TAB_DIVIDER_WIDTH;
	}
	self.contentSize = CGSizeMake(xCoordinate, 0);
	[self selectTab: self.tabs[0]];
}

-(void) tabPressed: (UIButton*) tabButton {
	[self unselectTab:self.selectedTab];
	[self selectTab:tabButton];
	[self.customScrollingTabBarDelegate tabPressedWithTitle:[tabButton attributedTitleForState: UIControlStateNormal].string];
}

-(void) selectTab: (UIButton*) tab {
	[tab setAttributedTitle:[[NSAttributedString alloc] initWithString:[tab attributedTitleForState: UIControlStateNormal].string
															attributes: self.selectedTabTitleAttributes] forState:UIControlStateNormal];
	self.selectedTab = tab;
}

-(void) unselectTab: (UIButton*) tab {
	[tab setAttributedTitle:[[NSAttributedString alloc] initWithString:[tab attributedTitleForState: UIControlStateNormal].string
																  attributes:self.tabTitleAttributes] forState:UIControlStateNormal];
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
		_tabTitleAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
								NSFontAttributeName: [UIFont fontWithName:TAB_BAR_FONT size:TAB_BAR_FONT_SIZE]};
	}
	return _tabTitleAttributes;
}

-(NSDictionary*) selectedTabTitleAttributes {
	if (!_selectedTabTitleAttributes) {
		NSShadow *shadow = [[NSShadow alloc] init];
		[shadow setShadowBlurRadius:10.f];
		[shadow setShadowColor:[UIColor blackColor]];
		[shadow setShadowOffset:CGSizeMake(0.f, 0.f)];

		_selectedTabTitleAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
//										NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
//										NSShadowAttributeName : shadow,
										NSFontAttributeName: [UIFont fontWithName:TAB_BAR_SELECTED_FONT size:TAB_BAR_FONT_SIZE]};
	}
	return _selectedTabTitleAttributes;
}

@end
