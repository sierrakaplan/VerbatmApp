//
//  Follow_BackendManager.h
//  Verbatm
//
//  Created by Iain Usiri on 2/6/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Channel.h"

@interface Follow_BackendManager : NSObject

+(void)currentUserFollowChannel:(Channel *) channelToFollow;

+(void)user:(PFUser *)user stopFollowingChannel:(Channel *) channelToUnfollow;

//tests to see if the logged in user follows this channel
+(void)currentUserFollowsChannel:(Channel *) channel withCompletionBlock:(void(^)(bool))block;

+ (void) usersFollowingChannel: (Channel*) channel withCompletionBlock:(void(^)(NSMutableArray*)) block;
+ (void) channelsUserFollowing: (PFUser*) user withCompletionBlock:(void(^)(NSMutableArray*)) block;
+ (void) numberChannelsUserFollowing: (PFUser*) user withCompletionBlock:(void(^)(NSNumber*)) block;
+ (void) numberUsersFollowingChannel: (Channel*) channel withCompletionBlock:(void(^)(NSNumber*)) block;

@end
