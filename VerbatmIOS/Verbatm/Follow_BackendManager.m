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
			[[UserInfoCache sharedInstance] registerNewFollower];
			[[UserInfoCache sharedInstance] storeCurrentUserNowFollowingChannel:channelToFollow];
			[Follow_BackendManager NotifyNewFollowingActionOnChannel:channelToFollow isFollowing:YES];

			[Notification_BackendManager createNotificationWithType:NewFollower receivingUser:channelToFollow.channelCreator relevantPostObject:nil];
		}
	}];
}

+(void)NotifyNewFollowingActionOnChannel:(Channel *)channel isFollowing:(BOOL) isFollowing{
	NSDictionary * userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[channel.channelCreator objectId],USER_FOLLOWING_NOTIFICATION_USERINFO_KEY,[NSNumber numberWithBool:isFollowing],USER_FOLLOWING_NOTIFICATION_ISFOLLOWING_KEY,nil];
	NSNotification * notification = [[NSNotification alloc]initWithName:NOTIFICATION_NOW_FOLLOWING_USER object:nil userInfo:userInfo];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}


+(void)blockUser:(PFUser *) user fromFollowingChannel:(Channel *) channelToUnfollow {
	PFQuery *followQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
	[followQuery whereKey:FOLLOW_CHANNEL_FOLLOWED_KEY equalTo:channelToUnfollow.parseChannelObject];
	[followQuery whereKey:FOLLOW_USER_KEY equalTo:user];
	followQuery.limit = 1000;
	[followQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
													NSError * _Nullable error) {

		if(objects && !error && objects.count) {
			// Should only be 1, but because of bugs might be more
			BOOL __block duplicate = NO;
			for (PFObject * followObj in objects) {
				[followObj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
					if(succeeded && !duplicate) {
						duplicate = YES;
						[channelToUnfollow.parseChannelObject incrementKey:CHANNEL_NUM_FOLLOWS byAmount:[NSNumber numberWithInteger:-1]];
						[channelToUnfollow.parseChannelObject saveInBackground];
					}
				}];
			}
		}

	}];
}


+(void)currentUserStopFollowingChannel:(Channel *) channelToUnfollow {
	PFQuery *followQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
	[followQuery whereKey:FOLLOW_CHANNEL_FOLLOWED_KEY equalTo:channelToUnfollow.parseChannelObject];
	[followQuery whereKey:FOLLOW_USER_KEY equalTo:[PFUser currentUser]];
	[followQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
													NSError * _Nullable error) {

		if(objects && !error && objects.count) {
			// Should only be 1, but because of bugs might be more
			BOOL __block duplicate = NO;
			for (PFObject * followObj in objects) {
				[followObj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
					if(succeeded && !duplicate) {
						duplicate = YES;
						[channelToUnfollow.parseChannelObject incrementKey:CHANNEL_NUM_FOLLOWS byAmount:[NSNumber numberWithInteger:-1]];
						[channelToUnfollow.parseChannelObject saveInBackground];
						[[UserInfoCache sharedInstance] registerRemovedFollower];
						[[UserInfoCache sharedInstance] storeCurrentUserStoppedFollowing:channelToUnfollow];
						[Follow_BackendManager NotifyNewFollowingActionOnChannel:channelToUnfollow isFollowing:NO];
					}
				}];
			}
		}

	}];
}

+ (void) channelIDsUserFollowing: (PFUser*) user withCompletionBlock:(void(^)(NSArray*)) block {
	PFQuery *followingQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
	followingQuery.limit = 1000;
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
	followingQuery.limit = 1000;
	[followingQuery whereKey:FOLLOW_USER_KEY equalTo:user];
	[followingQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable followObjects,
														  NSError * _Nullable error) {
		if(error) {
			[[Crashlytics sharedInstance] recordError:error];
			block (@[]);
		} else {
			NSMutableArray *channelIDs = [[NSMutableArray alloc] init];
			for (PFObject *followObject in followObjects) {
				PFObject *channelObj = followObject[FOLLOW_CHANNEL_FOLLOWED_KEY];
				[channelIDs addObject: channelObj.objectId];
			}
			PFQuery *channelsQuery = [PFQuery queryWithClassName:CHANNEL_PFCLASS_KEY];
			[channelsQuery whereKey:@"objectId" containedIn: channelIDs];
			channelsQuery.limit = 1000;
			[channelsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable channelObjects, NSError * _Nullable error) {
				if (error) {
					[[Crashlytics sharedInstance] recordError: error];
					block (@[]);
				} else {
					NSMutableArray *channels = [[NSMutableArray alloc] init];
					for (PFObject *channelObject in channelObjects) {
						NSInteger followIndex = [channelIDs indexOfObject: channelObject.objectId];
						PFObject *correspondingFollowObj = followObjects[followIndex];
						// SANITY CHECK todo: delete:
						if(![((PFObject*)correspondingFollowObj[FOLLOW_CHANNEL_FOLLOWED_KEY]).objectId isEqualToString: channelObject.objectId]) {
							NSLog(@"Wrong follow object");
						}

						Channel *channel = [[Channel alloc] initWithChannelName:[channelObject valueForKey:CHANNEL_NAME_KEY]
														  andParseChannelObject:channelObject
															  andChannelCreator:[channelObject valueForKey:CHANNEL_CREATOR_KEY]
																andFollowObject: correspondingFollowObj];
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
	followersQuery.limit = 1000;
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
