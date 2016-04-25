//
//  ProfileNavBar.m
//  Verbatm
//
//  Created by Iain Usiri on 11/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "CustomScrollingTabBar.h"
#import "CustomNavigationBar.h"
#import "Channel.h"
#import "Channel_BackendObject.h"

#import "Durations.h"

#import "FollowInfoBar.h"
#import "Follow_BackendManager.h"

#import "Icons.h"

#import "Notifications.h"

#import <Parse/PFUser.h>
#import "ProfileNavBar.h"
#import "ProfileInformationBar.h"
#import "ParseBackendKeys.h"

#import "SizesAndPositions.h"
#import "Styles.h"

#import "User_BackendObject.h"

@interface ProfileNavBar () <CustomScrollingTabBarDelegate, ProfileInformationBarProtocol>

@property (nonatomic, strong) ProfileInformationBar * profileHeader;
@property (nonatomic, strong) CustomScrollingTabBar* threadNavScrollView;

@property (nonatomic, strong) UIView * arrowExtension;

@property (nonatomic) CGRect followersInfoFrameOpen;
@property (nonatomic) CGRect followersInfoFrameClosed;

@property (nonatomic) CGPoint panLastLocation;//used to help change size of view dynamically

#define THREAD_BAR_BUTTON_FONT_SIZE 17.f

@end

@implementation ProfileNavBar

//expects an array of thread names (nsstring)
-(instancetype) initWithFrame:(CGRect)frame andChannels:(NSArray *)channels
					  andUser:(PFUser *)profileUser isCurrentLoggedInUser:(BOOL) isCurrentUser
				 isProfileTab:(BOOL) profileTab {
	self = [super initWithFrame:frame];
	if(self) {
		if (!isCurrentUser) {
			[User_BackendObject userIsBlockedByCurrentUser:profileUser withCompletionBlock:^(BOOL blocked) {
				[self createProfileHeaderWithUserName:[profileUser valueForKey:VERBATM_USER_NAME_KEY]
										isCurrentUser:NO isBlocked:blocked isProfileTab:profileTab];
			}];
		} else {
			[self createProfileHeaderWithUserName:[profileUser valueForKey:VERBATM_USER_NAME_KEY]
									isCurrentUser:YES isBlocked:NO isProfileTab:profileTab];
		}

		Channel* startChannel = (channels.count > 0) ? channels[0] : nil;
		[self.threadNavScrollView displayTabs:channels withStartChannel:startChannel isLoggedInUser:isCurrentUser];
		[self registerForNotifications];
	}
	return self;
}

-(void)registerForNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginSucceeded:)
                                                 name:NOTIFICATION_USER_LOGIN_SUCCEEDED
                                               object:nil];
}

-(void) loginSucceeded: (NSNotification*) notification {
    [self.threadNavScrollView removeFromSuperview];
    self.threadNavScrollView = nil;
    [Channel_BackendObject getChannelsForUser:[PFUser currentUser] withCompletionBlock:^(NSMutableArray * channels) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.threadNavScrollView displayTabs:channels withStartChannel:nil isLoggedInUser:YES];
        });
    }];
}

-(void)newChannelCreated:(Channel *)channel{
    if(channel){
        [self.threadNavScrollView addNewChannelToList:channel];
    }
}

-(void) createProfileHeaderWithUserName: (NSString*) userName isCurrentUser:(BOOL) isCurrentUser
							  isBlocked: (BOOL) blocked isProfileTab: (BOOL) profileTab {
    CGRect barFrame = CGRectMake(0.f, 0.f, self.bounds.size.width, PROFILE_HEADER_HEIGHT);
    self.profileHeader = [[ProfileInformationBar alloc] initWithFrame:barFrame andUserName:userName
														isCurrentUser:isCurrentUser isBlockedByCurrentUser:blocked
														 isProfileTab:profileTab];
    self.profileHeader.delegate = self;
    [self addSubview:self.profileHeader];
}

-(void)blockCurrentUserShouldBlock:(BOOL) shouldBlock {
    [self.delegate blockCurrentUserShouldBlock:shouldBlock];
}

-(void)updateUserIsBlocked:(BOOL)blocked {
	self.profileHeader.hasBlockedUser = blocked;
}

-(void)backButtonSelected {
    [self.delegate exitCurrentProfile];
}

-(void)settingsButtonSelected {
    [self.delegate settingsButtonClicked];
}

//told when the follow/followers button is selected
-(void)followButtonSelectedShouldFollowUser:(BOOL) followUser {
    if(followUser)[Follow_BackendManager currentUserFollowChannel:self.threadNavScrollView.currentChannel];
	else [Follow_BackendManager user:[PFUser currentUser] stopFollowingChannel:self.threadNavScrollView.currentChannel];
}


#pragma mark -Follow Infor Bar Delegate-

-(void) selectChannel: (Channel*) channel {
	[self.threadNavScrollView selectChannel: channel];
}

#pragma mark - CustomScrollingTabBarDelegate methods -

-(void) tabPressedWithChannel:(Channel *)channel {
	[self.delegate newChannelSelected:channel];
}

-(void) createNewChannel{
    //pass information to our delegate
    [self.delegate createNewChannel];
}

#pragma mark - Lazy Instantation -

-(UIScrollView*) threadNavScrollView {
	if (!_threadNavScrollView) {
		_threadNavScrollView = [[CustomScrollingTabBar alloc] initWithFrame:CGRectMake(2.f, self.profileHeader.frame.origin.y + PROFILE_HEADER_HEIGHT,
																			  self.frame.size.width-4.f, USER_CELL_VIEW_HEIGHT)];

		_threadNavScrollView.customScrollingTabBarDelegate = self;
		[self addSubview: _threadNavScrollView];
	}
	return _threadNavScrollView;
}

@end
