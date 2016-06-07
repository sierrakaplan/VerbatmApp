//
//  ProfileHeaderView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 5/31/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//
// 	The view that is shown at the top of every profile, showing the blogger's name,
//	their followers, who they are following, the blog name and description. It also incorporates
// 	buttons such as settings and edit in the current user's profile and a back button and block buttons
// 	in other users' profiles.

#import <UIKit/UIKit.h>

@protocol ProfileHeaderViewDelegate <NSObject>

// If profile tab
-(void) settingsButtonClicked;

// If someone else's profile
-(void) exitCurrentProfile;
-(void) blockCurrentUserShouldBlock:(BOOL) shouldBlock;

@end

@interface ProfileHeaderView : UIView

// Init with user=nil to indicate current user
// profileTab tells us where in navigation we are - editing and settings are only available
// from the profile tab.
-(instancetype)initWithFrame:(CGRect)frame andUser:(PFUser*)user
				  andChannel:(Channel*)channel inProfileTab:(BOOL) profileTab;

@property (weak, nonatomic) id<ProfileHeaderViewDelegate> delegate;

@end