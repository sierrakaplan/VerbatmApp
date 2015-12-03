//
//  profileNavBar.m
//  Verbatm
//
//  Created by Iain Usiri on 11/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "ButtonScrollView.h"
#import "ProfileNavBar.h"
#import "CustomNavigationBar.h"
#import "ChannelButtons.h"
#import "Icons.h"
#import "SizesAndPositions.h"
#import "Styles.h"

@interface ProfileNavBar ()

@property (nonatomic, strong) UIView* profileHeader;
@property (nonatomic, strong) UIScrollView* threadNavScrollView;

#define THREAD_BUTTON_WIDTH 150.f
#define THREAD_BAR_BUTTON_FONT_SIZE 17.f
#define THREAD_SCROLLVIEW_ALPHA 0.5

#define SETTINGS_BUTTON_SIZE 50.f
#define SETTINGS_BUTTON_OFFSET 10.f

@end

@implementation ProfileNavBar

//expects an array of thread names (nsstring)
-(instancetype) initWithFrame:(CGRect)frame andThreads:(NSArray *)threads andUserName:(NSString *) userName {
    self = [super initWithFrame:frame];
    if(self){
        [self createProfileHeaderWithUserName:userName];
        [self prepareTabViewForThreads:threads];
    }
    return self;
}

-(void) createProfileHeaderWithUserName: (NSString*) userName {
	UILabel* userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(SETTINGS_BUTTON_SIZE + SETTINGS_BUTTON_OFFSET, BELOW_STATUS_BAR,
																	   self.frame.size.width - SETTINGS_BUTTON_OFFSET*2 - SETTINGS_BUTTON_SIZE*2,
																	   self.profileHeader.frame.size.height)];
	userNameLabel.text = (userName && userName.length) ? userName : @"Iain Usiri";
	userNameLabel.textAlignment = NSTextAlignmentCenter;
	userNameLabel.textColor = [UIColor whiteColor];
	[self.profileHeader addSubview: userNameLabel];
	[self createSettingsButton];
}

-(void) createSettingsButton {
	UIButton* settingsButton = [UIButton buttonWithType: UIButtonTypeCustom];
	settingsButton.frame = CGRectMake(self.frame.size.width - SETTINGS_BUTTON_SIZE - SETTINGS_BUTTON_OFFSET,
									  BELOW_STATUS_BAR + SETTINGS_BUTTON_OFFSET, SETTINGS_BUTTON_SIZE, SETTINGS_BUTTON_SIZE);
	[settingsButton setImage:[UIImage imageNamed:SETTINGS_BUTTON_ICON] forState:UIControlStateNormal];
	[self.profileHeader addSubview:settingsButton];
}

-(void) prepareTabViewForThreads:(NSArray *) threads {
    CGFloat xCoordinate = 0.f;
    for(NSString * threadTitle in threads) {
        CGRect buttonFrame = CGRectMake(xCoordinate, 0.f, THREAD_BUTTON_WIDTH, self.threadNavScrollView.frame.size.height);
        UIButton * newButton = [[UIButton alloc] initWithFrame:buttonFrame];
        newButton.backgroundColor = [UIColor clearColor];
        [newButton addTarget:self action:@selector(threadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [newButton addSubview:[self formatTextForButtonLabel:threadTitle andFrame:newButton.bounds]];
        [self.threadNavScrollView addSubview:newButton];
        xCoordinate += THREAD_BUTTON_WIDTH + 1.f;
    }
    self.threadNavScrollView.contentSize = CGSizeMake(threads.count * THREAD_BUTTON_WIDTH, 0);
	self.threadNavScrollView.scrollEnabled = YES;
}

-(UILabel *)formatTextForButtonLabel:(NSString *) titleText andFrame:(CGRect) frame{
    UILabel * label = [[UILabel alloc] initWithFrame:frame];
    label.text = titleText;
    label.font = [UIFont fontWithName:NAVIGATION_BAR_BUTTON_FONT size:THREAD_BAR_BUTTON_FONT_SIZE];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    return label;
}

-(void) threadButtonPressed:(UIButton*) sender{
    UILabel * textLabel = [sender.subviews firstObject];//only has one subview
    NSString * threadName = textLabel.text;
    [self.delegate newChannelSelectedWithName:threadName];
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
		_threadNavScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.f, self.profileHeader.frame.origin.y + PROFILE_HEADER_HEIGHT,
																			  self.frame.size.width, THREAD_SCROLLVIEW_HEIGHT)];
		[_threadNavScrollView setBackgroundColor:[UIColor colorWithWhite:0.f alpha: THREAD_SCROLLVIEW_ALPHA]];
		self.threadNavScrollView.scrollEnabled = YES;
		self.threadNavScrollView.showsHorizontalScrollIndicator = NO;
		self.threadNavScrollView.bounces = NO;
		[self addSubview: _threadNavScrollView];
	}
	return _threadNavScrollView;
}

@end
