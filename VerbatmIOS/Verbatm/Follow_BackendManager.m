//
//  Follow_BackendManager.m
//  Verbatm
//
//  Created by Iain Usiri on 2/6/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "Follow_BackendManager.h"
#import "ParseBackendKeys.h"
#import <Parse/PFQuery.h>
#import <Parse/PFUser.h>
#import <Parse/PFObject.h>
#import <Parse/PFRelation.h>
#import <PromiseKit/PromiseKit.h>

#import "Notifications.h"

@implementation Follow_BackendManager

//this function should not be called for a channel that is already being followed
+(void)currentUserFollowChannel:(Channel *) channelToFollow {
	[channelToFollow.parseChannelObject incrementKey:CHANNEL_NUM_FOLLOWS];
	[channelToFollow.parseChannelObject saveInBackground];
	PFObject * newFollowObject = [PFObject objectWithClassName:FOLLOW_PFCLASS_KEY];
	[newFollowObject setObject:[PFUser currentUser]forKey:FOLLOW_USER_KEY];
	[newFollowObject setObject:channelToFollow.parseChannelObject forKey:FOLLOW_CHANNEL_FOLLOWED_KEY];
	[newFollowObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
		if(succeeded){
            NSNotification * not = [[NSNotification alloc]initWithName:NOTIFICATION_NOW_FOLLOWING_USER object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:not];
		}
	}];
}

+(void)user:(PFUser *)user stopFollowingChannel:(Channel *) channelToUnfollow {
	[channelToUnfollow.parseChannelObject incrementKey:CHANNEL_NUM_FOLLOWS byAmount:[NSNumber numberWithInteger:-1]];
	[channelToUnfollow.parseChannelObject saveInBackground];
	PFQuery *followQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
	[followQuery whereKey:FOLLOW_CHANNEL_FOLLOWED_KEY equalTo:channelToUnfollow.parseChannelObject];
	[followQuery whereKey:FOLLOW_USER_KEY equalTo:user];
	[followQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
														 NSError * _Nullable error) {
		if(objects && !error && objects.count) {
			PFObject * followObj = [objects firstObject];
			[followObj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
				if(succeeded){
					[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STOPPED_FOLLOWING_USER object:nil];
				}
			}];
		}
	}];
}

//checks to see if there is a follow relation between the channel and the user
+ (void)currentUserFollowsChannel:(Channel *) channel withCompletionBlock:(void(^)(bool)) block {
	if(!channel) return;
	PFQuery *followQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
	[followQuery whereKey:FOLLOW_CHANNEL_FOLLOWED_KEY equalTo:channel.parseChannelObject];
	[followQuery whereKey:FOLLOW_USER_KEY equalTo:[PFUser currentUser]];
	[followQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
														 NSError * _Nullable error) {
		if(objects && !error && objects.count > 0) {
			block(YES);
			return;
		}
		block (NO);
	}];
}

// Returns the number of users following a given channel
+ (void) numberUsersFollowingChannel: (Channel*) channel withCompletionBlock:(void(^)(NSNumber*)) block {
	[Follow_BackendManager usersFollowingChannel:channel withCompletionBlock:^(NSArray *users) {
		if (users) {
			block([NSNumber numberWithLong:users.count]);
			return;
		}
		block([NSNumber numberWithInt:0]);
	}];
}

// Returns the number of channels a user is following
+ (void) numberChannelsUserFollowing: (PFUser*) user withCompletionBlock:(void(^)(NSNumber*)) block {
	[Follow_BackendManager channelsUserFollowing:user withCompletionBlock:^(NSArray *channels) {
		if (channels) {
			block([NSNumber numberWithLong:channels.count]);
			return;
		}
		block([NSNumber numberWithInt:0]);
	}];
}

// Returns all of the channels a user is following as array of PFObjects
+ (void) channelsUserFollowing: (PFUser*) user withCompletionBlock:(void(^)(NSMutableArray*)) block {
	if (!user) return;
	PFQuery *followingQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
	[followingQuery whereKey:FOLLOW_USER_KEY equalTo:user];
	[followingQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
														  NSError * _Nullable error) {
		if(objects && !error) {
			NSMutableArray *channels = [[NSMutableArray alloc] initWithCapacity: objects.count];
            NSMutableArray * channelPromises = [[NSMutableArray alloc] init];
			for (PFObject *followObject in objects) {
				PFObject *channelObj = followObject[FOLLOW_CHANNEL_FOLLOWED_KEY];
                
                [channelPromises addObject:[AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve)
                    {
                        [channelObj fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                            if(object){
                                [channels addObject: [[Channel alloc] initWithChannelName:[channelObj valueForKey:CHANNEL_NAME_KEY] andParseChannelObject:channelObj andChannelCreator:user]];
                            }
                            resolve(nil);
                    }];
                }]];
			}
            
            PMKWhen(channelPromises).then(^(id nothing) {
                block(channels);
            });
            
		} else {
			[[Crashlytics sharedInstance] recordError:error];
            block (nil);
		}
	}];
}

// Returns all of the users following a given channel as an array of PFUsers
+ (void) usersFollowingChannel: (Channel*) channel withCompletionBlock:(void(^)(NSMutableArray*)) block {
	if (!channel) return;
	PFQuery *followersQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
	[followersQuery whereKey:FOLLOW_CHANNEL_FOLLOWED_KEY equalTo:channel.parseChannelObject];
	[followersQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
														  NSError * _Nullable error) {
		if(objects && !error) {
			NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:objects.count];
			for (PFObject *followObject in objects) {
				PFUser *userFollowing = followObject[FOLLOW_USER_KEY];
				if ([users containsObject: userFollowing]) {
					//somehow a duplicate
					[followObject deleteInBackground];
					continue;
				}
				[userFollowing fetchIfNeededInBackground];
				[users addObject:userFollowing];
			}
			block (users);
			return;
		}
		block (nil);
	}];
}

-(void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
