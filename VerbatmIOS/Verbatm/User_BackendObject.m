
//
//  User_BackendObject.m
//  Verbatm
//
//  Created by Iain Usiri on 3/24/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel_BackendObject.h"
#import <Crashlytics/Crashlytics.h>
#import "Follow_BackendManager.h"
#import "User_BackendObject.h"
#import <Parse/PFUser.h>
#import <Parse/PFQuery.h>
#import "ParseBackendKeys.h"
#import "Notifications.h"

#import <PromiseKit/PromiseKit.h>

@implementation User_BackendObject


+ (void)updateUserNameOfCurrentUserTo:(NSString *) newName{
	if(newName && [User_BackendObject stringHasCharacters:newName] &&
	   ![newName isEqualToString:[[PFUser currentUser] valueForKey:VERBATM_USER_NAME_KEY]]) {

		[[PFUser currentUser] setValue:newName forKey:VERBATM_USER_NAME_KEY];
		[[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
			if(succeeded) {
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USERNAME_CHANGED_SUCCESFULLY object:nil];
			} else {
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USERNAME_CHANGE_FAILED object:nil];
			}
		}];
	}
}

+ (void)userIsBlockedByCurrentUser:(PFUser *)user withCompletionBlock:(void(^)(BOOL))block {
	PFQuery *blockQuery = [PFQuery queryWithClassName:BLOCK_PFCLASS_KEY];
	[blockQuery whereKey:BLOCK_USER_BLOCKING_KEY equalTo:[PFUser currentUser]];
	[blockQuery whereKey:BLOCK_USER_BLOCKED_KEY equalTo:user];
	[blockQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
		if (objects && objects.count) block(YES);
		else block(NO);
	}];
}

+ (void)blockUser:(PFUser *)user {
	PFObject *newBlockObject = [PFObject objectWithClassName:BLOCK_PFCLASS_KEY];
	[newBlockObject setObject:[PFUser currentUser] forKey:BLOCK_USER_BLOCKING_KEY];
	[newBlockObject setObject:user forKey:BLOCK_USER_BLOCKED_KEY];
	[newBlockObject saveInBackground];

	//Make sure blocked user unfollows all of current user's channels
	[Channel_BackendObject getChannelsForUser:[PFUser currentUser] withCompletionBlock:^(NSMutableArray *channels) {
		for (Channel *channel in channels) {
			[Follow_BackendManager user:user stopFollowingChannel:channel];
		}
	}];

	//Unfollow all of blocked user's channels
	[Channel_BackendObject getChannelsForUser:user withCompletionBlock:^(NSMutableArray *channels) {
		for (Channel *channel in channels) {
			[Follow_BackendManager user:[PFUser currentUser] stopFollowingChannel:channel];
		}
	}];
}

+ (void)unblockUser:(PFUser *)user {
	PFQuery *blockQuery = [PFQuery queryWithClassName:BLOCK_PFCLASS_KEY];
	[blockQuery whereKey:BLOCK_USER_BLOCKING_KEY equalTo:[PFUser currentUser]];
	[blockQuery whereKey:BLOCK_USER_BLOCKED_KEY equalTo:user];
	[blockQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
		if (objects) {
			for (PFObject *block in objects) {
				[block deleteInBackground]; //should only be one
			}
		} else {
			[[Crashlytics sharedInstance] recordError:error];
		}
	}];
}

//Move all posts to one channel, move all follow relationships to one channel, and delete all other channels
+ (void) migrateUserToOneChannelWithCompletionBlock:(void(^)(BOOL))block {
	PFUser *user = [PFUser currentUser];

	PFQuery *userChannelQuery = [PFQuery queryWithClassName:CHANNEL_PFCLASS_KEY];
	[userChannelQuery whereKey:CHANNEL_CREATOR_KEY equalTo:user];
	[userChannelQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable channels,
														 NSError * _Nullable error) {
		if (error) {
			[[Crashlytics sharedInstance] recordError:error];
			block(NO);
			return;
		}

		if (channels.count < 2) {
			block(YES);
			return;
		}

		PFObject *oneChannel = channels[0];
		NSMutableArray *otherChannels = [[NSMutableArray alloc] initWithArray:channels];
		[otherChannels removeObjectAtIndex:0];

		[self changeOriginalPostsToOriginalChannel: oneChannel].then(^(NSNumber *changePostsSuccess) {
			if (!changePostsSuccess.boolValue) {
				block(NO);
				return;
			}

			[self moveAllPostsToOneChannel:oneChannel fromChannels:otherChannels].then(^(NSNumber *movePostsSuccess) {
				if (!movePostsSuccess.boolValue) {
					block(NO);
					return;
				}

				NSLog(@"All posts moved to one channel");

				[self moveAllFollowRelationshipsToOneChannel:oneChannel fromChannels:otherChannels].then(^(NSNumber *moveFollowsSuccess) {
					if (!moveFollowsSuccess.boolValue) {
						block(NO);
						return;
					}

					NSLog(@"All follows moved to one channel");

					[self deleteAllOtherChannels:otherChannels].then(^(NSArray *errors) {
						for (NSError *error in errors) {
							if (error && ![error isEqual:[NSNull null]]) {
								[[Crashlytics sharedInstance] recordError:error];
								block(NO);
								return;
							}
						}

						NSLog(@"All other channels deleted");
						block(YES);
					});
				});
			});
		});
	}];
}


+(AnyPromise*) changeOriginalPostsToOriginalChannel:(PFObject*)channel {
	return [self getOriginalPostsForUser:[PFUser currentUser]].then(^(NSArray* originalPosts) {
		NSMutableArray *originalPostPromises = [[NSMutableArray alloc] initWithCapacity:originalPosts.count];
		for (PFObject *post in originalPosts) {
			[originalPostPromises addObject:[self changePost:post toOriginalChannel:channel]];
		}

		return PMKWhen(originalPostPromises).then(^(NSArray *errors) {
			for (NSError *error in errors) {
				if (error && ![error isEqual:[NSNull null]]) {
					[[Crashlytics sharedInstance] recordError:error];
					return [NSNumber numberWithBool:NO];
				}
			}
			return [NSNumber numberWithBool:YES];
		});
	});
}

+(AnyPromise*) getOriginalPostsForUser:(PFUser*)user {
	return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
		PFQuery *userPostsQuery = [PFQuery queryWithClassName:POST_PFCLASS_KEY];
		[userPostsQuery whereKey:POST_ORIGINAL_CREATOR_KEY equalTo:[PFUser currentUser]];
		[userPostsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable originalPosts, NSError * _Nullable error) {
			if (error) {
				[[Crashlytics sharedInstance] recordError:error];
			}
			resolve(originalPosts);
		}];
	}];
}


+(AnyPromise*) changePost:(PFObject*)post toOriginalChannel:(PFObject*)channel {
	return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
		[post setObject:channel forKey:POST_CHANNEL_KEY];
		[post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
			resolve(error);
		}];
	}];
}

// Resolves to a BOOL (YES if no errors, NO otherwise)
+(AnyPromise*) moveAllPostsToOneChannel:(PFObject*)oneChannel fromChannels:(NSArray*)otherChannels {

	return [self getAllPostRelationshipsFromChannels:otherChannels].then(^(NSArray* postChannelRelationships) {
		if (!postChannelRelationships) {
			return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
				resolve([NSNumber numberWithBool:NO]);
			}];
		} else if (postChannelRelationships.count < 1) {
			return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
				resolve([NSNumber numberWithBool:YES]);
			}];
		}

		NSMutableArray *newPostRelationshipsPromises = [[NSMutableArray alloc] initWithCapacity:postChannelRelationships.count];
		NSMutableArray *postsInChannel = [[NSMutableArray alloc] init];
		for (PFObject *postChannelRelationship in postChannelRelationships) {
			PFObject *post = [postChannelRelationship objectForKey:POST_CHANNEL_ACTIVITY_POST];
			if ([postsInChannel containsObject:post]) continue;
			[postsInChannel addObject:post];
			[newPostRelationshipsPromises addObject:[self saveNewPostRelationshipFromRelationship:postChannelRelationship andChannel:oneChannel]];
		}
		return PMKWhen(newPostRelationshipsPromises).then(^(NSArray *errors) {
			for (NSError *error in errors) {
				if (error && ![error isEqual:[NSNull null]]) {
					[[Crashlytics sharedInstance] recordError:error];
					return [NSNumber numberWithBool:NO];
				}
			}
			return [NSNumber numberWithBool:YES];
		});
	});
}

+(AnyPromise*) moveAllFollowRelationshipsToOneChannel:(PFObject*)oneChannel fromChannels:(NSArray*)otherChannels {
	return [self getAllFollowRelationshipsFromChannels:otherChannels].then(^(NSArray* followRelationships) {
		if (!followRelationships) {
			return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
				resolve([NSNumber numberWithBool:NO]);
			}];
		}

		NSMutableArray *newFollowRelationshipsPromises = [[NSMutableArray alloc] initWithCapacity:followRelationships.count];
		NSMutableArray *usersFollowing = [[NSMutableArray alloc] init];
		for (PFObject *followRelationship in followRelationships) {
			PFUser *user = [followRelationship objectForKey:FOLLOW_USER_KEY];
			if ([usersFollowing containsObject: user]) continue;
			[usersFollowing addObject: user];
			[newFollowRelationshipsPromises addObject:[self saveNewFollowRelationshipFromRelationship:followRelationship andChannel:oneChannel]];
		}
		return PMKWhen(newFollowRelationshipsPromises).then(^(NSArray *errors) {
			for (NSError *error in errors) {
				if (error && ![error isEqual:[NSNull null]]) {
					[[Crashlytics sharedInstance] recordError:error];
					return [NSNumber numberWithBool:NO];
				}
			}
			return [NSNumber numberWithBool:YES];
		});
	});
}

+(AnyPromise*) deleteAllOtherChannels:(NSArray*)otherChannels {
	NSMutableArray *deleteChannelsPromises = [[NSMutableArray alloc] initWithCapacity:otherChannels.count];
	for (PFObject *channel in otherChannels) {
		[deleteChannelsPromises addObject: [self deleteChannel:channel]];
	}

	return PMKWhen(deleteChannelsPromises);
}

+(AnyPromise*) getAllPostRelationshipsFromChannels:(NSArray*)otherChannels {
	return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
		PFQuery *postChannelRelationshipQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
		[postChannelRelationshipQuery orderByAscending:@"createdAt"];
		[postChannelRelationshipQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO containedIn:otherChannels];
		[postChannelRelationshipQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable postChannelRelationships, NSError * _Nullable error) {
			if (error) [[Crashlytics sharedInstance] recordError:error];
			resolve(postChannelRelationships);
		}];
	}];
}

+(AnyPromise*) getAllFollowRelationshipsFromChannels:(NSArray*)otherChannels {
	return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
		PFQuery *followRelationshipQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
		[followRelationshipQuery whereKey:FOLLOW_CHANNEL_FOLLOWED_KEY containedIn:otherChannels];
		[followRelationshipQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable followRelationships, NSError * _Nullable error) {
			if (error) [[Crashlytics sharedInstance] recordError:error];
			resolve(followRelationships);
		}];
	}];
}

+ (AnyPromise*) saveNewPostRelationshipFromRelationship:(PFObject*)relationship andChannel:(PFObject*)channel {
	return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {

		PFObject *postObject = [relationship objectForKey:POST_CHANNEL_ACTIVITY_POST];
		PFQuery *relationshipExistsQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
		[relationshipExistsQuery whereKey:POST_CHANNEL_ACTIVITY_POST equalTo:postObject];
		[relationshipExistsQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:channel];

		[relationshipExistsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
			if (error) {
				resolve(error);
				return;
			}

			//Only save a post channel relationship if one doesn't already exist (because of reposting)
			if (objects.count == 0) {
				PFObject *newPostChannelRelationship = [PFObject objectWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
				[newPostChannelRelationship setObject:postObject forKey:POST_CHANNEL_ACTIVITY_POST];
				[newPostChannelRelationship setObject:channel forKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO];
				//we store the person creating the relationship -- either reposter or original owner
				[newPostChannelRelationship setObject:[PFUser currentUser] forKey:RELATIONSHIP_OWNER];
				[newPostChannelRelationship saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
					[relationship deleteInBackground];
					resolve (error);
				}];
			} else {
				[relationship deleteInBackground];
				resolve (nil);
			}
		}];

	}];
}

+ (AnyPromise*) saveNewFollowRelationshipFromRelationship:(PFObject*)relationship andChannel:(PFObject*)channel {
	return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
		PFUser *userFollowing = [relationship objectForKey:FOLLOW_USER_KEY];

		PFQuery *relationshipExistsQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
		[relationshipExistsQuery whereKey:FOLLOW_USER_KEY equalTo:userFollowing];
		[relationshipExistsQuery whereKey:FOLLOW_CHANNEL_FOLLOWED_KEY equalTo:channel];

		[relationshipExistsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
			if (error) {
				resolve(error);
				return;
			}

			//Only save a follow relationship if one doesn't already exist
			if (!objects || objects.count == 0) {
				PFObject *newFollowRelationship = [PFObject objectWithClassName:FOLLOW_PFCLASS_KEY];
				[newFollowRelationship setObject:userFollowing forKey:FOLLOW_USER_KEY];
				[newFollowRelationship setObject:channel forKey:FOLLOW_CHANNEL_FOLLOWED_KEY];
				[newFollowRelationship saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
					[relationship deleteInBackground];
					resolve (error);
				}];
			} else {
				[relationship deleteInBackground];
				resolve (nil);
			}
		}];
	}];
}

+ (AnyPromise*) deleteChannel:(PFObject*)channel {
	return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
		[channel deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
			resolve(error);
		}];
	}];
}

+ (BOOL)stringHasCharacters:(NSString *) text{
	NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
	return ![[text stringByTrimmingCharactersInSet:alphaSet] isEqualToString:text];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
