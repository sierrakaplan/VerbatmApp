//
//  profileInformationBar.m
//  Verbatm
//
//  Created by Iain Usiri on 12/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "Icons.h"

#import "Follow_BackendManager.h"

#import "Notifications.h"

#import <Parse/PFUser.h>
#import "ParseBackendKeys.h"
#import "ProfileInformationBar.h"

#import "SizesAndPositions.h"
#import "Styles.h"
#import "FollowingView.h"


@interface ProfileInformationBar ()
@property (nonatomic) UILabel * userTitleName;
@property (nonatomic) UIButton * settingsButton;
@property (nonatomic) BOOL isCurrentUser;

#define BUTTON_Y (self.center.y - ((height - STATUS_BAR_HEIGHT)/2.f))

@end

@implementation ProfileInformationBar

-(instancetype)initWithFrame:(CGRect)frame andUserName: (NSString *) userName
			   isCurrentUser:(BOOL) isCurrentUser isBlockedByCurrentUser:(BOOL) isBlocked
				isProfileTab: (BOOL)profileTab {
	self =  [super initWithFrame:frame];
	if(self){
		[self formatView];
		[self createProfileHeaderWithUserName:userName];
		self.isCurrentUser = isCurrentUser;
		if(!isCurrentUser) {
			self.hasBlockedUser = isBlocked;
			[self createBlockingButton];
        }
		if (!profileTab) {
			[self createBackButton];
		} else {
			[self createSettingsButton];
		}
		[self registerForNotifications];
	}
	return self;
}


-(void)registerForNotifications{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loginSucceeded:)
												 name:NOTIFICATION_USER_LOGIN_SUCCEEDED
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(userNameChanged:)
												 name:NOTIFICATION_USERNAME_CHANGED_SUCCESFULLY
											   object:nil];
}

-(void) userNameChanged: (NSNotification*) notification {
	[self updateUserName];
}

-(void) loginSucceeded: (NSNotification*) notification {
	/*the user has logged in so we can update our username*/
	[self updateUserName];
}

-(void)updateUserName{
	[self.userTitleName removeFromSuperview];
	self.userTitleName = nil;
	[self createProfileHeaderWithUserName:[[PFUser currentUser] valueForKey:VERBATM_USER_NAME_KEY]];
}

-(void)formatView {
	self.backgroundColor = [UIColor colorWithWhite:0 alpha:1.f];
}

-(void) createProfileHeaderWithUserName: (NSString*) userName {
	CGFloat x_point = (CHANNEL_BUTTON_WALL_XOFFSET*2) + SETTINGS_BUTTON_SIZE;
	CGFloat width = self.frame.size.width - (CHANNEL_BUTTON_WALL_XOFFSET*2) - (SETTINGS_BUTTON_SIZE*2);
	CGFloat height = self.frame.size.height;

	self.userTitleName = [[UILabel alloc] initWithFrame:CGRectMake(x_point, BUTTON_Y, width, height)];

	self.userTitleName.text = userName;
	self.userTitleName.textAlignment = NSTextAlignmentCenter;
	self.userTitleName.textColor = VERBATM_GOLD_COLOR;
	self.userTitleName.font = [UIFont fontWithName:HEADER_TEXT_FONT size:HEADER_TEXT_SIZE];
	[self addSubview: self.userTitleName ];
}

-(void)createSettingsButton {
	UIImage * settingsImage = [UIImage imageNamed:SETTINGS_BUTTON_ICON];

	CGFloat height = SETTINGS_BUTTON_SIZE;
	CGFloat width = height+ 20.f;
	CGFloat frame_x = self.frame.size.width - width - CHANNEL_BUTTON_WALL_XOFFSET;

	CGRect iconFrame = CGRectMake(frame_x, BUTTON_Y, width, height );

	self.settingsButton =  [[UIButton alloc] initWithFrame:iconFrame];
	[self.settingsButton setImage:settingsImage forState:UIControlStateNormal];
	self.settingsButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self.settingsButton addTarget:self action:@selector(settingsButtonSelected) forControlEvents:UIControlEventTouchDown];
	[self addSubview:self.settingsButton];
	self.settingsButton.clipsToBounds = YES;;

}

-(void)createBlockingButton {
	UIImage * settingsImage = [UIImage imageNamed:@"profile"];

	CGFloat height = SETTINGS_BUTTON_SIZE;
	CGFloat width = height+ 20.f;
	CGFloat frame_x = self.frame.size.width - width - CHANNEL_BUTTON_WALL_XOFFSET;

	CGRect iconFrame = CGRectMake(frame_x, BUTTON_Y, width, height );

	self.settingsButton =  [[UIButton alloc] initWithFrame:iconFrame];
	[self.settingsButton setImage:settingsImage forState:UIControlStateNormal];
	self.settingsButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self.settingsButton addTarget:self action:@selector(blockButtonSelected) forControlEvents:UIControlEventTouchDown];
	[self addSubview:self.settingsButton];
	self.settingsButton.clipsToBounds = YES;;

}

-(void)blockButtonSelected {
    FollowingView *V = [[FollowingView alloc] initWithFrame:CGRectMake(0, 20, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    
    UIViewController *top = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (top.presentedViewController){
        top = top.presentedViewController;
    }

    [top.view addSubview:V];
}

-(void) createBackButton {

	UIImage * settingsImage = [UIImage imageNamed:BACK_BUTTON_ICON];
	CGFloat height = SETTINGS_BUTTON_SIZE;
	CGFloat width = height;
	CGFloat frame_x = CHANNEL_BUTTON_WALL_XOFFSET;

	CGRect iconFrame = CGRectMake(frame_x, BUTTON_Y, width, height);

	self.settingsButton =  [[UIButton alloc] initWithFrame:iconFrame];
	[self.settingsButton setImage:settingsImage forState:UIControlStateNormal];
	self.settingsButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self.settingsButton addTarget:self action:@selector(backButtonSelected) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.settingsButton];

}

-(void) backButtonSelected {
	[self.delegate backButtonSelected];
}

-(void) settingsButtonSelected {
	[self.delegate settingsButtonSelected];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
