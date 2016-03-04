//
//  profileVC.h
//  Verbatm
//
//  Created by Iain Usiri on 8/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

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

@end
