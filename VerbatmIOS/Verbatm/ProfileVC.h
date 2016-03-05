//
//  ProfileVC.h
//  Verbatm
//
//  Created by Iain Usiri on 8/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//
//	View controller for the profile - responsible for laying out the channels, the post list
// 	showing posts for whichever channel is currently selected, and the profile navigation bar,
//	as well as the settings screen.

#import <UIKit/UIKit.h>
#import <Parse/PFUser.h>
#import "Channel.h"

@protocol ProfileVCDelegate <NSObject>

-(void) showTabBar: (BOOL) show;

-(void)presentWhoIFollowMyID:(id) userID ;//show list of people the user follows
-(void)presentFollowersListMyID:(id) userID ;//show the list of people who follow me
-(void)presentChannelsToFollow;//show the channels the current user can select

@end

@interface ProfileVC : UIViewController

@property (strong, nonatomic) id<ProfileVCDelegate> delegate;

@property (weak, nonatomic) PFUser* userOfProfile;

//let us know if this is the profile of the logged in user
@property (nonatomic) BOOL isCurrentUserProfile;

@property (nonatomic) id userIdToPresent;

//channel that should be presented first
@property (nonatomic) Channel * startChannel;

-(void) showPublishingProgress;
@property (nonatomic) BOOL currentlyBeingViewed;//set when this view is selected
@end
