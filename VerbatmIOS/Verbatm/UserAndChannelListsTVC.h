//
//  UserAndChannelListsTVC.h
//  Verbatm
//
//  Created by Iain Usiri on 1/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

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


@interface UserAndChannelListsTVC : UITableViewController
//show which users like this post
-(void) presentUserLikeInformationForPost:(id) post;

//show which uses shared this post
-(void) presentUserShareInformationForPost:(id) post;

//Gives us the channels to display and if we should show the users that follow them then
-(void)presentChannelsForUser:(id) userId shouldDisplayFollowers:(BOOL) displayFollowers;

//show which users are being followed by userId
-(void)presentWhoIsFollowedBy:(id)userId;

-(void)presentAllVerbatmChannels;

@property (nonatomic, weak) id<UserAndChannelListsTVCDelegate> listDelegate;

@end
