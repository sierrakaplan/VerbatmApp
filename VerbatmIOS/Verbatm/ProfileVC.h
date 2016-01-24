//
//  profileVC.h
//  Verbatm
//
//  Created by Iain Usiri on 8/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PovInfo.h"
@protocol ProfileVCDelegate <NSObject>

-(void) showTabBar: (BOOL) show;

-(void)profilePovShareButtonSeletedForPOV:(PovInfo *) pov;
-(void)profilePovLikeLiked:(BOOL) liked forPOV:(PovInfo *) pov;

-(void)presentWhoIFollowMyID:(id) userID ;//show list of people the user follows
-(void)presentFollowersListMyID:(id) userID ;//show the list of people who follow me
-(void)presentChannelsToFollow;//show the channels the current user can select
@end

@interface ProfileVC : UIViewController

@property (strong, nonatomic) id<ProfileVCDelegate> delegate;
@property (nonatomic) BOOL isCurrentUserProfile;//let us know if this is the profile of the logged in user
@property (nonatomic) id userIdToPresent;//get this users information

-(void) updateUserInfo;
-(void) offScreen;//told when it's off screen to stop videos
-(void)onScreen;


@end
