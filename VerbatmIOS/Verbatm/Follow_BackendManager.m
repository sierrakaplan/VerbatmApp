//
//  Follow_BackendManager.m
//  Verbatm
//
//  Created by Iain Usiri on 2/6/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Follow_BackendManager.h"
#import "ParseBackendKeys.h"
#import <Parse/PFQuery.h>
#import <Parse/PFUser.h>
#import <Parse/PFObject.h>
#import <Parse/PFRelation.h>

@implementation Follow_BackendManager

//this function should not be called for a channel that is already being followed
-(void)currentUserFollowChannel:(Channel *) channelToFollow {
    PFObject * newPageObject = [PFObject objectWithClassName:FOLLOW_PFCLASS_KEY];
    [newPageObject setObject:[PFUser currentUser]forKey:FOLLOW_USER_KEY];
    [newPageObject setObject:channelToFollow.parseChannelObject forKey:FOLLOW_CHANNEL_FOLLOWED_KEY];
    [newPageObject saveInBackground];
}



@end
