//
//  UserAndChannelListsTVC.h
//  Verbatm
//
//  Created by Iain Usiri on 1/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"
/*
 This VC presents information about:
 1) who has liked a post
 2) who has shared a post
 3)All channels on Verbatm
 4)Your followers - sorted by channels
 5)People you are following
 */




@protocol UserAndChannelListsTVCDelegate <NSObject>
-(void)openChannel:(Channel *) channel;

-(void)selectedUser:(id)userId;

@end


typedef enum{
    
    likersList = 0,
    followersList =1,
    followingList =2
    
}ListLoadType;

@interface UserAndChannelListsTVC : UITableViewController
//show which users like this post
-(void) presentUserLikeInformationForPost:(id) post;

//show which uses shared this post
-(void) presentUserShareInformationForPost:(id) post;

//Gives us the channels to display and if we should show the users that follow them then
-(void)presentChannelsForUser:(id) userId shouldDisplayFollowers:(BOOL) displayFollowers;

//show which users are being followed by userId
-(void)presentWhoIsFollowedBy:(id)userId;

-(void)presentList:(ListLoadType) listType forChannel:(Channel *) channel;

@property (nonatomic, weak) id<UserAndChannelListsTVCDelegate> listDelegate;
@property (nonatomic) ListLoadType currentListType;
-(void)presentList:(ListLoadType) listType forChannel:(Channel *) channel;
@end
