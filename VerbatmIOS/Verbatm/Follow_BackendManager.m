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
	PFObject * newFollowObject = [PFObject objectWithClassName:FOLLOW_PFCLASS_KEY];
	[newFollowObject setObject:[PFUser currentUser]forKey:FOLLOW_USER_KEY];
	[newFollowObject setObject:channelToFollow.parseChannelObject forKey:FOLLOW_CHANNEL_FOLLOWED_KEY];
	[newFollowObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
		if(succeeded){
			NSLog(@"Now following channel");
		}
	}];
}

+(void)currentUserStopFollowingChannel:(Channel *) channelToUnfollow{
	//we just delete the Follow Object
	PFQuery * userChannelQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
	[userChannelQuery whereKey:FOLLOW_CHANNEL_FOLLOWED_KEY equalTo:channelToUnfollow.parseChannelObject];
	[userChannelQuery whereKey:FOLLOW_USER_KEY equalTo:[PFUser currentUser]];
	[userChannelQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
														 NSError * _Nullable error) {
		if(objects && !error && objects.count){
			PFObject * followObj = [objects firstObject];
			[followObj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
				if(succeeded){
					NSLog(@"Stopped following channel sucessfully");
					[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STOPPED_FOLLOWING_USER object:nil];
				}
			}];
		}
	}];
}

//checks to see if there is a follow relation between the channel and the user
+ (void)currentUserFollowsChannel:(Channel *) channel withCompletionBlock:(void(^)(bool)) block {
	if(!channel) return;
	PFQuery *userChannelQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
	[userChannelQuery whereKey:FOLLOW_CHANNEL_FOLLOWED_KEY equalTo:channel.parseChannelObject];
	[userChannelQuery whereKey:FOLLOW_USER_KEY equalTo:[PFUser currentUser]];
	[userChannelQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
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
	if (!channel) return;
	PFQuery *numFollowersQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
	[numFollowersQuery whereKey:FOLLOW_CHANNEL_FOLLOWED_KEY equalTo:channel.parseChannelObject];
	[numFollowersQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
														  NSError * _Nullable error) {
		if(objects && !error) {
			block ([NSNumber numberWithInteger:objects.count]);
			return;
		}
		block ([NSNumber numberWithInt: 0]);
	}];
}

// Returns the number of channels a user is following
+ (void) numberChannelsUserFollowing: (PFUser*) user withCompletionBlock:(void(^)(NSNumber*)) block {
	if (!user) return;
	PFQuery *numFollowingQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
	[numFollowingQuery whereKey:FOLLOW_USER_KEY equalTo:user];
	[numFollowingQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
														  NSError * _Nullable error) {
		if(objects && !error) {
			block ([NSNumber numberWithInteger:objects.count]);
			return;
		}
		block ([NSNumber numberWithInt: 0]);
	}];
}

// Returns all of the channels a user is following as array of PFObjects
+ (void) channelsUserFollowing: (PFUser*) user withCompletionBlock:(void(^)(NSArray*)) block {
	if (!user) return;
	PFQuery *numFollowingQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
	[numFollowingQuery whereKey:FOLLOW_USER_KEY equalTo:user];
	[numFollowingQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
														  NSError * _Nullable error) {
		if(objects && !error) {
			block (objects);
			return;
		}
		block (nil);
	}];
}

// Returns all of the users following a given channel as an array of PFUsers
+ (void) usersFollowingChannel: (Channel*) channel withCompletionBlock:(void(^)(NSArray*)) block {
	if (!channel) return;
	PFQuery *numFollowersQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
	[numFollowersQuery whereKey:FOLLOW_CHANNEL_FOLLOWED_KEY equalTo:channel.parseChannelObject];
	[numFollowersQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
														  NSError * _Nullable error) {
		if(objects && !error) {
			block (objects);
			return;
		}
		block (nil);
	}];
}

@end
