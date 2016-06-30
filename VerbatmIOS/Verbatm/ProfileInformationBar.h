//
//  profileInformationBar.h
//  Verbatm
//
//  Created by Iain Usiri on 12/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//
// 	Shows the username, followers/following, and edit button for a profile

#import <UIKit/UIKit.h>


@protocol ProfileInformationBarDelegate <NSObject>

// Only available in profile tab
-(void) settingsButtonSelected;

-(void) editButtonSelected;

// Only available if not profile tab
-(void) backButtonSelected;

// Only available in someone else's profile
-(void) blockCurrentUserShouldBlock:(BOOL) shouldBlock;
-(void)followersButtonSelected;
-(void)followingButtonSelected;

@end

@interface ProfileInformationBar : UIView

@property (nonatomic, weak) id <ProfileInformationBarDelegate> delegate;

// Init with user=nil to indicate current user
// profileTab tells us where in navigation we are - editing and settings are only available
// from the profile tab.
-(instancetype)initWithFrame:(CGRect)frame andUser:(PFUser*)user
				  andChannel:(Channel*)channel inProfileTab:(BOOL) profileTab;

@end
