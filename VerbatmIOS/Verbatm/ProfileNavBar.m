//
//  profileNavBar.m
//  Verbatm
//
//  Created by Iain Usiri on 11/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "ButtonScrollView.h"
#import "CustomScrollingTabBar.h"
#import "ProfileNavBar.h"
#import "CustomNavigationBar.h"
#import "ChannelButtons.h"
#import "Icons.h"
#import "SizesAndPositions.h"
#import "Styles.h"

@interface ProfileNavBar () <CustomScrollingTabBarDelegate>

@property (nonatomic, strong) UIView* profileHeader;
@property (nonatomic, strong) CustomScrollingTabBar* threadNavScrollView;


#define THREAD_BAR_BUTTON_FONT_SIZE 17.f

#define SETTINGS_BUTTON_SIZE 40.f
#define SETTINGS_BUTTON_OFFSET 10.f

@end

@implementation ProfileNavBar

//expects an array of thread names (nsstring)
-(instancetype) initWithFrame:(CGRect)frame andThreads:(NSArray *)threads andUserName:(NSString *) userName {
    self = [super initWithFrame:frame];
    if(self){
        [self createProfileHeaderWithUserName:userName];
		[self.threadNavScrollView displayTabs:threads];
    }
    return self;
}

-(void) createProfileHeaderWithUserName: (NSString*) userName {
	UILabel* userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(SETTINGS_BUTTON_SIZE + SETTINGS_BUTTON_OFFSET, BELOW_STATUS_BAR,
																	   self.frame.size.width - SETTINGS_BUTTON_OFFSET*2 - SETTINGS_BUTTON_SIZE*2,
																	   self.profileHeader.frame.size.height - SETTINGS_BUTTON_OFFSET*2)];
	userNameLabel.text =  @"Iain Usiri";
	userNameLabel.textAlignment = NSTextAlignmentCenter;
	userNameLabel.textColor = [UIColor whiteColor];
	userNameLabel.font = [UIFont fontWithName:HEADER_TEXT_FONT size:HEADER_TEXT_SIZE];
	[self.profileHeader addSubview: userNameLabel];
//	[self createSettingsButton];
}

-(void) createSettingsButton {
	UIButton* settingsButton = [UIButton buttonWithType: UIButtonTypeCustom];
	settingsButton.frame = CGRectMake(self.frame.size.width - SETTINGS_BUTTON_SIZE - SETTINGS_BUTTON_OFFSET,
									  BELOW_STATUS_BAR + SETTINGS_BUTTON_OFFSET, SETTINGS_BUTTON_SIZE, SETTINGS_BUTTON_SIZE);
	[settingsButton setImage:[UIImage imageNamed:SETTINGS_BUTTON_ICON] forState:UIControlStateNormal];
	[self.profileHeader addSubview:settingsButton];
}


#pragma mark - CustomScrollingTabBarDelegate methods -

-(void) tabPressedWithTitle:(NSString *)title {
	[self.delegate newChannelSelectedWithName:title];
}


#pragma mark - Lazy Instantation -

-(UIView*) profileHeader {
	if (!_profileHeader) {
		_profileHeader = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.bounds.size.width, PROFILE_HEADER_HEIGHT)];
		[_profileHeader setBackgroundColor:[UIColor blackColor]];
		[self addSubview:_profileHeader];
	}
	return _profileHeader;
}

-(UIScrollView*) threadNavScrollView {
	if (!_threadNavScrollView) {
		_threadNavScrollView = [[CustomScrollingTabBar alloc] initWithFrame:CGRectMake(0.f, self.profileHeader.frame.origin.y + PROFILE_HEADER_HEIGHT,
																			  self.frame.size.width, THREAD_SCROLLVIEW_HEIGHT)];

		_threadNavScrollView.customScrollingTabBarDelegate = self;
		[self addSubview: _threadNavScrollView];
	}
	return _threadNavScrollView;
}

@end
