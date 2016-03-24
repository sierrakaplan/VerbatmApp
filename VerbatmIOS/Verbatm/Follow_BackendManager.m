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
#import "Notifications.h"

@implementation Follow_BackendManager

//this function should not be called for a channel that is already being followed
+(void)currentUserFollowChannel:(Channel *) channelToFollow {
    
    //updating the number of followers on the channel object
    NSNumber * followerNum = [channelToFollow.parseChannelObject valueForKey:CHANNEL_NUM_FOLLOWERS_KEY];
    int numFollowers = followerNum.intValue;
    numFollowers++;
    [channelToFollow.parseChannelObject  setValue:[NSNumber numberWithInt:numFollowers] forKey:CHANNEL_NUM_FOLLOWERS_KEY];
    
    [channelToFollow.parseChannelObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            //recording the actual follow relationship  in our follow table
            PFObject * newFollowObject = [PFObject objectWithClassName:FOLLOW_PFCLASS_KEY];
            [newFollowObject setObject:[PFUser currentUser]forKey:FOLLOW_USER_KEY];
            [newFollowObject setObject:channelToFollow.parseChannelObject forKey:FOLLOW_CHANNEL_FOLLOWED_KEY];
            [newFollowObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded){
                    NSLog(@"Now following channel");
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NOW_FOLLOWING_USER object:nil];
                }
            }];
        }
    }];
    
    
    
}

+(void)currentUserStopFollowingChannel:(Channel *) channelToUnfollow{
    
    
    //updating the number of followers on the channel object
    NSNumber * followerNum = [channelToUnfollow.parseChannelObject valueForKey:CHANNEL_NUM_FOLLOWERS_KEY];
    int numFollowers = followerNum.intValue;
    numFollowers--;
    [channelToUnfollow.parseChannelObject  setValue:[NSNumber numberWithInt:numFollowers] forKey:CHANNEL_NUM_FOLLOWERS_KEY];
    
    [channelToUnfollow.parseChannelObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        //we just delete the Follow Object
        PFQuery * userChannelQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
        [userChannelQuery whereKey:FOLLOW_CHANNEL_FOLLOWED_KEY equalTo:channelToUnfollow.parseChannelObject];
        [userChannelQuery whereKey:FOLLOW_USER_KEY equalTo:[PFUser currentUser]];
        [userChannelQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                             NSError * _Nullable error) {
            if(objects && !error) {
                if(objects.count){
                    PFObject * followObj = [objects firstObject];
                    [followObj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if(succeeded){
                            NSLog(@"Stopped following channel sucessfully");
                             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STOPPED_FOLLOWING_USER object:nil];
                        }
                    }];
                }
            }
        }];
    }];
}

//checks to see if there is a follow relation between the channel and the user
+(void)currentUserFollowsChannel:(Channel *) channel withCompletionBlock:(void(^)(bool))block{
    if(!channel)return;
    //we just delete the Follow Object
    PFQuery * userChannelQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
    [userChannelQuery whereKey:FOLLOW_CHANNEL_FOLLOWED_KEY equalTo:channel.parseChannelObject];
    [userChannelQuery whereKey:FOLLOW_USER_KEY equalTo:[PFUser currentUser]];
    [userChannelQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                         NSError * _Nullable error) {
        if(objects && !error) {
            if(objects.count == 0)block(NO);
            else block(YES);
        }
    }];
    
}



@end
