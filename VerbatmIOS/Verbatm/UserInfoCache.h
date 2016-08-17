//
//  UserInfoCache.h
//  Verbatm
//
//  Created by Iain Usiri on 3/21/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel.h"
#import <Foundation/Foundation.h>

@interface UserInfoCache : NSObject

@property (nonatomic, readonly) Channel *userChannel;


+(instancetype)sharedInstance;

-(void)loadUserChannelsWithCompletionBlock:(void(^)())block;

-(Channel *) getUserChannel;

// Returns the follow object if the user follows the channel
-(PFObject*) userFollowsChannel:(Channel*)channel;

//tells you if the user follows this channel
//use this if all you need is true/false answer
-(BOOL)checkUserFollowsChannel:(Channel*)channel;

//increments followers number in backend
-(void)registerNewFollower;

//decrements followers number in backend
-(void)registerRemovedFollower;

-(void)storeCurrentUserNowFollowingChannel:(Channel *)channel;

-(void)storeCurrentUserStoppedFollowing:(Channel *)channel;

@end

