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
#import "Notification_BackendManager.h"
#import "Notifications.h"
#import "UserInfoCache.h"

@implementation Follow_BackendManager

//this function should not be called for a channel that is already being followed
+(void)currentUserFollowChannel:(Channel *) channelToFollow {
	PFObject * newFollowObject = [PFObject objectWithClassName:FOLLOW_PFCLASS_KEY];
	[newFollowObject setObject:[PFUser currentUser]forKey:FOLLOW_USER_KEY];
	[newFollowObject setObject:channelToFollow.parseChannelObject forKey:FOLLOW_CHANNEL_FOLLOWED_KEY];
	// Will return error if follow already existed - ignore
	[newFollowObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
		if(succeeded){
			[channelToFollow.parseChannelObject incrementKey:CHANNEL_NUM_FOLLOWS];
			[channelToFollow.parseChannelObject saveInBackground];
			[[[UserInfoCache sharedInstance] getUserChannel].parseChannelObject incrementKey:CHANNEL_NUM_FOLLOWING];
			[[[UserInfoCache sharedInstance] getUserChannel].parseChannelObject saveInBackground];
			NSDictionary * userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[channelToFollow.channelCreator objectId],USER_FOLLOWING_NOTIFICATION_USERINFO_KEY,nil];


			NSNotification * not = [[NSNotification alloc]initWithName:NOTIFICATION_NOW_FOLLOWING_USER object:nil userInfo:userInfo];
			[[NSNotificationCenter defaultCenter] postNotification:not];
			[Notification_BackendManager createNotificationWithType:NewFollower receivingUser:channelToFollow.channelCreator relevantPostObject:nil];
		}
	}];
}

+(void)user:(PFUser *)user stopFollowingChannel:(Channel *) channelToUnfollow {
	PFQuery *followQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
	[followQuery whereKey:FOLLOW_CHANNEL_FOLLOWED_KEY equalTo:channelToUnfollow.parseChannelObject];
	[followQuery whereKey:FOLLOW_USER_KEY equalTo:user];
	[followQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
													NSError * _Nullable error) {
		if(objects && !error && objects.count) {
			PFObject * followObj = [objects firstObject];
			[followObj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
				if(succeeded){
					[channelToUnfollow.parseChannelObject incrementKey:CHANNEL_NUM_FOLLOWS byAmount:[NSNumber numberWithInteger:-1]];
					[channelToUnfollow.parseChannelObject saveInBackground];
					[[[UserInfoCache sharedInstance] getUserChannel].parseChannelObject incrementKey:CHANNEL_NUM_FOLLOWING byAmount:[NSNumber numberWithInteger:-1]];
					[[[UserInfoCache sharedInstance] getUserChannel].parseChannelObject saveInBackground];
					[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STOPPED_FOLLOWING_USER object:nil];
				}
			}];
		}
	}];
}

+ (void) channelIDsUserFollowing: (PFUser*) user withCompletionBlock:(void(^)(NSArray*)) block {
	PFQuery *followingQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
	[followingQuery whereKey:FOLLOW_USER_KEY equalTo:user];
	[followingQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
														  NSError * _Nullable error) {
		if (error) {
			[[Crashlytics sharedInstance] recordError:error];
			block (@[]);
		} else {
			NSMutableArray *channelObjects = [[NSMutableArray alloc] init];
			for (PFObject *followObject in objects) {
				PFObject *channelObj = followObject[FOLLOW_CHANNEL_FOLLOWED_KEY];
				[channelObjects addObject: channelObj];
			}
			block(channelObjects);
		}
	}];
}

// Returns all of the channels a user is following as array of Channels
+ (void) channelsUserFollowing: (PFUser*) user withCompletionBlock:(void(^)(NSArray*)) block {
	if (!user) return;
	PFQuery *followingQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
	[followingQuery whereKey:FOLLOW_USER_KEY equalTo:user];
	[followingQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
														  NSError * _Nullable error) {
		if(error) {
			[[Crashlytics sharedInstance] recordError:error];
			block (@[]);
		} else {
			NSMutableArray *channelIDs = [[NSMutableArray alloc] init];
			for (PFObject *followObject in objects) {
				PFObject *channelObj = followObject[FOLLOW_CHANNEL_FOLLOWED_KEY];
				[channelIDs addObject: channelObj.objectId];
			}
			PFQuery *channelsQuery = [PFQuery queryWithClassName:CHANNEL_PFCLASS_KEY];
			[channelsQuery whereKey:@"objectId" containedIn: channelIDs];
			[channelsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
				if (error) {
					[[Crashlytics sharedInstance] recordError: error];
					block (@[]);
				} else {
					NSMutableArray *channels = [[NSMutableArray alloc] init];
					for (PFObject *channelObject in objects) {
						Channel *channel = [[Channel alloc] initWithChannelName:[channelObject valueForKey:CHANNEL_NAME_KEY]
														  andParseChannelObject:channelObject
															  andChannelCreator:[channelObject valueForKey:CHANNEL_CREATOR_KEY]];
						channel.latestPostDate = channelObject[CHANNEL_LATEST_POST_DATE];
						[channels addObject: channel];
					}

					NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"latestPostDate" ascending:NO];
					NSArray *sortedChannels = [channels sortedArrayUsingDescriptors:@[sort]];
					block(sortedChannels);
				}
			}];
		}
	}];
}

// Returns all of the users following a given channel as an array of PFUsers
+ (void) usersFollowingChannel: (Channel*) channel withCompletionBlock:(void(^)(NSMutableArray*)) block {

	PFQuery *followersQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
	[followersQuery whereKey:FOLLOW_CHANNEL_FOLLOWED_KEY equalTo:channel.parseChannelObject];
	[followersQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
													   NSError * _Nullable error) {
		if(objects && !error) {
			NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:objects.count];
			for (PFObject *followObject in objects) {
				PFUser *userFollowing = followObject[FOLLOW_USER_KEY];
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
