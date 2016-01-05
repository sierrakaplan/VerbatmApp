//
//  profileNavBar.m
//  Verbatm
//
//  Created by Iain Usiri on 11/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "ButtonScrollView.h"

#import "CustomScrollingTabBar.h"
#import "CustomNavigationBar.h"
#import "Channel.h"

#import "Icons.h"

#import "ProfileNavBar.h"
#import "ProfileInformationBar.h"

#import "SizesAndPositions.h"
#import "Styles.h"

@interface ProfileNavBar () <CustomScrollingTabBarDelegate, ProfileInformationBarProtocol>

@property (nonatomic, strong) ProfileInformationBar * profileHeader;
@property (nonatomic, strong) CustomScrollingTabBar* threadNavScrollView;


#define THREAD_BAR_BUTTON_FONT_SIZE 17.f

#define SETTINGS_BUTTON_SIZE 40.f
#define SETTINGS_BUTTON_OFFSET 10.f

@end

@implementation ProfileNavBar

//expects an array of thread names (nsstring)
-(instancetype) initWithFrame:(CGRect)frame andChannels:(NSArray *)channels andUserName:(NSString *) userName {
    self = [super initWithFrame:frame];
    if(self){
        [self createProfileHeaderWithUserName:userName];
		[self.threadNavScrollView displayTabs:channels];
    }
    return self;
}

-(void) createProfileHeaderWithUserName: (NSString*) userName {
    
    CGRect barFrame = CGRectMake(0.f, 0.f, self.bounds.size.width, PROFILE_HEADER_HEIGHT);
    self.profileHeader = [[ProfileInformationBar alloc] initWithFrame:barFrame andUserName:userName];
    self.profileHeader.delegate = self;
    [self addSubview:self.profileHeader];
}


-(void)settingsButtonSelected {
    [self.delegate settingsButtonClicked];
}

-(void)editButtonSelected{
    
}



#pragma mark - CustomScrollingTabBarDelegate methods -

-(void) tabPressedWithTitle:(NSString *)title {
	[self.delegate newChannelSelectedWithName:title];
}

-(void) createNewChannel{
    //pass information to our delegate
    [self.delegate createNewChannel];
}

#pragma mark - Lazy Instantation -

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
