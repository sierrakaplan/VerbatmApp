//
//  fManager.h
//  Verbatm
//
//  Created by Iain Usiri on 2/6/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Channel.h"

@interface Follow_BackendManager : NSObject

+(void)currentUserFollowChannel:(Channel *) channelToFollow;

+(void)currentUserStopFollowingChannel:(Channel *) channelToUnfollow;

+ (void) usersFollowingChannel: (Channel*) channel withCompletionBlock:(void(^)(NSMutableArray*)) block;

// Returns array of Channel pfobjects but not fetched (so only contain ids)
+ (void) channelIDsUserFollowing: (PFUser*) user withCompletionBlock:(void(^)(NSArray*)) block;

// Returns array of Channel* objects - this loads each Channel and takes longer
+ (void) channelsUserFollowing: (PFUser*) user withCompletionBlock:(void(^)(NSArray*)) block;


@end
