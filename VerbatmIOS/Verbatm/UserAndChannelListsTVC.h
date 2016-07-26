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
	LikersList = 0,
    FollowersList = 1,
    FollowingList = 2
} ListType;

@interface UserAndChannelListsTVC : UITableViewController

@property (nonatomic, weak) id<UserAndChannelListsTVCDelegate> listDelegate;
@property (nonatomic) ListType currentListType;

-(void)presentList:(ListType) listType forChannel:(Channel *) channel orPost:(PFObject *) post;

@end
