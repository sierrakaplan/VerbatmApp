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
+(void)currentUserStopFollowingChannel:(Channel *) channelToUnfollow;
//tests to see if the logged in user follows this channel
+(void)currentUserFollowsChannel:(Channel *) channel withCompletionBlock:(void(^)(bool))block;

@end
