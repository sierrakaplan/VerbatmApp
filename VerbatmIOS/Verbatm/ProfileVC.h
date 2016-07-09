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

@optional
-(void) userCreateFirstPost;

@end

@interface ProfileVC : UIViewController

@property (nonatomic) BOOL profileInFeed;

@property (weak, nonatomic) id<ProfileVCDelegate> delegate;

@property (weak, nonatomic) PFUser* ownerOfProfile;
@property (nonatomic) Channel* channel; 
@property (nonatomic) NSDate *startingDate;

//let us know if this is the profile of the logged in user
@property (nonatomic) BOOL isCurrentUserProfile;

// This is the profile tab
@property (nonatomic) BOOL isProfileTab;

@property (nonatomic) id userIdToPresent;

-(void) clearOurViews;

//instructs the Profile to begin loading postlist content
-(void) loadContentToPostList;

//to be used sparingly
-(void) refreshProfile;

@end
