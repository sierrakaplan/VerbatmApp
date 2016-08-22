
//
//  FeedQueryManager.m
//  Verbatm
//
//  Created by Iain Usiri on 2/6/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel.h"
#import "Channel_BackendObject.h"
#import <Crashlytics/Crashlytics.h>
#import "FeedQueryManager.h"
#import "ParseBackendKeys.h"
#import <Parse/PFQuery.h>
#import <PromiseKit/PromiseKit.h>
#import "UtilityFunctions.h"

#import <ParseFacebookutilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface FeedQueryManager ()

@property (nonatomic) NSInteger postsInFeed;
@property (nonatomic, strong) NSDate *currentFeedStart;

@property (nonatomic, strong) NSMutableArray *channelsFollowed;
@property (nonatomic, strong) NSMutableArray *channelsFollowedIds;
// to stop two queries refreshing simultaneously
@property (nonatomic) BOOL followedChannelsRefreshing;
@property (nonatomic, strong) NSCondition *channelsRefreshingCondition;

@property (nonatomic) NSInteger exploreChannelsLoaded;
@property (nonatomic, strong) NSMutableArray *usersWhoHaveBlockedUser;

@property (nonatomic, strong) NSArray *friendUsers;
@property (nonatomic, strong) NSArray *friendChannels;

@end

@implementation FeedQueryManager

+(instancetype) sharedInstance {
	static FeedQueryManager* sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[FeedQueryManager alloc] init];
	});
	return sharedInstance;
}

-(instancetype)init{
	self = [super init];
	if(self) {
		self.followedChannelsRefreshing = NO;
		self.channelsRefreshingCondition = [[NSCondition alloc] init];
		[self clearFeedData];
	}
	return self;
}

-(void) clearFeedData {
	self.postsInFeed = 0;
	self.currentFeedStart = nil;
}

// Waits if another thread is already refreshing followed channels,
// Otherwise refreshes followed channels and signals that refreshing is done, then
// block returns.
-(void) refreshChannelsWeFollowWithCompletionHandler:(void(^)(void))block {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self.channelsRefreshingCondition lock];

		// Someone else is refreshing channels
		if (self.followedChannelsRefreshing) {
			while (self.followedChannelsRefreshing) {
				[self.channelsRefreshingCondition wait];
			}
			[self.channelsRefreshingCondition unlock];
			block();
			return;
		}

		// Refresh followed channels
		self.followedChannelsRefreshing = YES;
		[self.channelsRefreshingCondition unlock];

		//todo: make this cloud code
		PFQuery *followObjectsQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
		[followObjectsQuery whereKey:FOLLOW_USER_KEY equalTo:[PFUser currentUser]];
		followObjectsQuery.cachePolicy = kPFCachePolicyNetworkOnly;
		followObjectsQuery.limit = 1000;
		[followObjectsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable followObjects, NSError * _Nullable error) {
			self.channelsFollowed = [[NSMutableArray alloc] init];
			self.channelsFollowedIds = [[NSMutableArray alloc] init];
			if (!error && followObjects) {
				for(PFObject *followObj in followObjects) {
					PFObject *channelObject = [followObj objectForKey:FOLLOW_CHANNEL_FOLLOWED_KEY];
					[self.channelsFollowed addObject: channelObject];
					[self.channelsFollowedIds addObject:[channelObject objectId]];
				}
			} else {
				[[Crashlytics sharedInstance] recordError:error];
			}
			[self.channelsRefreshingCondition lock];
			self.followedChannelsRefreshing = NO;
			[self.channelsRefreshingCondition signal];
			[self.channelsRefreshingCondition unlock];
			block();
		}];
	});
}

-(void)refreshFeedWithCompletionHandler:(void(^)(NSArray *))block {
	[self refreshChannelsWeFollowWithCompletionHandler:^{
		// Get POST_DOWNLOAD_MAX_SIZE of posts associated with these channels sorted from newest to oldest
		PFQuery *postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
		[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO containedIn:self.channelsFollowed];
		[postQuery orderByDescending:@"createdAt"];
		[postQuery setSkip: 0];
		//Only load newer posts
		if (self.currentFeedStart) {
			[postQuery whereKey:@"createdAt" greaterThan:self.currentFeedStart];
		} else {
			[postQuery setLimit: POST_DOWNLOAD_MAX_SIZE];
		}
		[postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable activities, NSError * _Nullable error) {
			NSMutableArray * finalPostObjects = [[NSMutableArray alloc] init];
			for(PFObject *postChannelActivity in activities) {
				PFObject *post = [postChannelActivity objectForKey:POST_CHANNEL_ACTIVITY_POST];
				[post fetchIfNeededInBackground];
				[finalPostObjects addObject:postChannelActivity];
			}

			// Reset cursor to start
			if (activities.count > 0) {
				self.currentFeedStart = [activities[0] createdAt];
			}
			self.postsInFeed += finalPostObjects.count;
			block(finalPostObjects);
		}];
	}];
}

-(void) loadMorePostsWithCompletionHandler:(void(^)(NSArray *))block {
	//Needs to call refresh first
	if (!self.channelsFollowed || !self.channelsFollowed.count || !self.currentFeedStart) {
		block (@[]);
		return;
	}

	// Get POST_DOWNLOAD_MAX_SIZE more posts older than the ones returned so far
	PFQuery *postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
	[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO containedIn:self.channelsFollowed];
	[postQuery orderByDescending:@"createdAt"];
	[postQuery setLimit: POST_DOWNLOAD_MAX_SIZE];
	[postQuery setSkip: self.postsInFeed];
	[postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable activities, NSError * _Nullable error) {
		if (error) {
			[[Crashlytics sharedInstance] recordError:error];
			block (@[]);
			return;
		}
		NSMutableArray * finalPostObjects = [[NSMutableArray alloc] init];
		for(PFObject *postChannelActivity in activities) {
			PFObject *post = [postChannelActivity objectForKey:POST_CHANNEL_ACTIVITY_POST];
			[post fetchIfNeededInBackground];
			[finalPostObjects addObject:postChannelActivity];
		}

		self.postsInFeed += finalPostObjects.count;
		block(finalPostObjects);
	}];
}

//Gets all the channels on Verbatm except the provided user and channels owned by people who have blocked user.
//Often this will be the current user
-(void) refreshExploreChannelsWithCompletionHandler:(void(^)(NSArray *))completionBlock {
	self.exploreChannelsLoaded = 0;
	[self loadExploreChannelsWithSkip:0 andCompletionHandler:^(NSArray *channels) {
		completionBlock(channels);
	}];
}

-(void) loadMoreExploreChannelsWithCompletionHandler:(void(^)(NSArray *))completionBlock {
 	[self loadExploreChannelsWithSkip:self.exploreChannelsLoaded andCompletionHandler:^(NSArray *channels) {
		completionBlock(channels);
	}];
}

-(void) loadExploreChannelsWithSkip:(NSInteger)skip andCompletionHandler:(void(^)(NSArray *))completionBlock {

	PFUser *user = [PFUser currentUser];
	// make this better
	[self refreshChannelsWeFollowWithCompletionHandler:^{
		//First get all the people who have blocked this user and do not include their channels
		PFQuery *blockQuery = [PFQuery queryWithClassName:BLOCK_PFCLASS_KEY];
		[blockQuery whereKey:BLOCK_USER_BLOCKED_KEY equalTo:user];
		[blockQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable blocks, NSError * _Nullable error) {
			self.usersWhoHaveBlockedUser = [[NSMutableArray alloc] init];
			for (PFObject *block in blocks) {
				[self.usersWhoHaveBlockedUser addObject:[block valueForKey:BLOCK_USER_BLOCKING_KEY]];
			}
			[self.usersWhoHaveBlockedUser addObject:[PFUser currentUser]];

			[self loadFriendsChannelsWithCompletionHandler:^(NSArray *friendChannelObjects, NSArray *friendObjects) {
				NSArray *friendChannels = [Channel_BackendObject channelsFromParseChannelObjects: friendChannelObjects];

				// add other channels
				// skip > 0 indicates loading more channels, should not show friend's channels
				if (friendChannels.count < CHANNEL_DOWNLOAD_MAX_SIZE || skip > 0) {
					PFQuery *exploreChannelsQuery = [PFQuery queryWithClassName:CHANNEL_PFCLASS_KEY];
					NSMutableArray *usersNotInclude = [NSMutableArray arrayWithArray: self.usersWhoHaveBlockedUser];
					[usersNotInclude addObjectsFromArray: friendObjects];
					[exploreChannelsQuery whereKey:CHANNEL_CREATOR_KEY notContainedIn: usersNotInclude];
					[exploreChannelsQuery whereKey:@"objectId" notContainedIn: self.channelsFollowedIds];
					[exploreChannelsQuery whereKeyExists:CHANNEL_LATEST_POST_DATE];
					[exploreChannelsQuery orderByDescending:@"createdAt"];
					[exploreChannelsQuery setLimit:CHANNEL_DOWNLOAD_MAX_SIZE];
					[exploreChannelsQuery setSkip: skip];
					[exploreChannelsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable channels, NSError * _Nullable error) {

						if(error || !channels) {
							[[Crashlytics sharedInstance] recordError:error];
							completionBlock (@[]);
							return;
						}
						NSArray *exploreChannels = [Channel_BackendObject channelsFromParseChannelObjects: channels];
						exploreChannels = [UtilityFunctions shuffleArray: exploreChannels];
						NSMutableArray *finalChannels = [NSMutableArray arrayWithArray:exploreChannels];
						if (skip == 0) {
							[finalChannels insertObjects:friendChannels atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, friendChannels.count)]];
						}
						self.exploreChannelsLoaded += finalChannels.count;
						completionBlock(finalChannels);
					}];
				} else {
					self.exploreChannelsLoaded += friendChannels.count;
					completionBlock(friendChannels);
				}
			}];
		}];
	}];
}

// resolves to channels of friends (as pfobjects), friend ids
-(void) loadFriendsChannelsWithCompletionHandler:(void(^)(NSArray *, NSArray *))completionBlock {
	if (self.friendChannels) {
		completionBlock(self.friendChannels, self.friendUsers);
		return;
	}
	BOOL isLinkedToFacebook = [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]];
	// Logged in with phone number
	if (!isLinkedToFacebook) {
		completionBlock(@[], @[]);
		//todo: get phone contacts
		return;
	}
	if (![[FBSDKAccessToken currentAccessToken] hasGranted:@"user_friends"]) {
		completionBlock(@[], @[]);
		return;
	}

	FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
	FBSDKGraphRequest *requestMe = [[FBSDKGraphRequest alloc]
									initWithGraphPath:@"me/friends" parameters:@{@"fields": @"id, name"}];
	[connection addRequest:requestMe
		 completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
			 if (error) {
				 completionBlock(@[], @[]);
			 } else {
				 NSArray *friendObjects = [result objectForKey:@"data"];
				 NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
				 // Create a list of friends' Facebook IDs
				 for (NSDictionary *friendObject in friendObjects) {
					 [friendIds addObject:[friendObject objectForKey:@"id"]];
					 //						 NSString *userName = [friendObject objectForKey:@"name"];
					 //						 NSLog(@"friend: %@", userName);
				 }
				 PFQuery *friendQuery = [PFUser query];
				 [friendQuery whereKey:USER_FB_ID containedIn:friendIds];

				 // findObjects will return a list of PFUsers that are friends
				 // with the current user
				 [friendQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable friendUsers, NSError * _Nullable error) {
					 if (error || !friendUsers.count) {
						 completionBlock(@[], @[]);
					 } else {
						 self.friendUsers = friendUsers;
						 PFQuery *channelsForFriends = [PFQuery queryWithClassName:CHANNEL_PFCLASS_KEY];
						 [channelsForFriends whereKey:CHANNEL_CREATOR_KEY containedIn:friendUsers];
						 [channelsForFriends whereKey:CHANNEL_CREATOR_KEY notContainedIn: self.usersWhoHaveBlockedUser];
						 //todo: comment out this line for testing
//						 [channelsForFriends whereKey:@"objectId" notContainedIn: self.channelsFollowedIds];
						 [channelsForFriends whereKeyExists:CHANNEL_LATEST_POST_DATE];
						 [channelsForFriends orderByDescending:@"createdAt"];
						 channelsForFriends.limit = 1000;
						 [channelsForFriends findObjectsInBackgroundWithBlock:^(NSArray * _Nullable channels, NSError * _Nullable error) {
							 if (error) {
								 completionBlock(@[], friendUsers);
							 } else {
								 self.friendChannels = channels;
								 completionBlock(channels, friendUsers);
							 }
						 }];
					 }
				 }];
			 }
		 }];
	[connection start];

}

-(void) loadFeaturedChannelsWithCompletionHandler:(void(^)(NSArray *))completionBlock {
	PFUser *user = [PFUser currentUser];
	//First get all the people who have blocked this user and do not include their channels
	PFQuery *blockQuery = [PFQuery queryWithClassName:BLOCK_PFCLASS_KEY];
	[blockQuery whereKey:BLOCK_USER_BLOCKED_KEY equalTo:user];
	[blockQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable blocks, NSError * _Nullable error) {
		self.usersWhoHaveBlockedUser = [[NSMutableArray alloc] init];
		for (PFObject *block in blocks) {
			[self.usersWhoHaveBlockedUser addObject:[block valueForKey:BLOCK_USER_BLOCKING_KEY]];
		}

		PFQuery *featuredChannelsQuery = [PFQuery queryWithClassName:CHANNEL_PFCLASS_KEY];
		[featuredChannelsQuery whereKey:CHANNEL_CREATOR_KEY notContainedIn: self.usersWhoHaveBlockedUser];
		[featuredChannelsQuery whereKey:CHANNEL_FEATURED_BOOL equalTo:[NSNumber numberWithBool:YES]];
		[featuredChannelsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable channels, NSError * _Nullable error) {
			NSMutableArray *finalChannels = [[NSMutableArray alloc] init];
			if(error || !channels) {
				[[Crashlytics sharedInstance] recordError:error];
				completionBlock (finalChannels);
				return;
			}
			for(PFObject *parseChannelObject in channels) {
				PFUser *channelCreator = [parseChannelObject valueForKey:CHANNEL_CREATOR_KEY];
				[channelCreator fetchIfNeededInBackground];
				NSString *channelName  = [parseChannelObject valueForKey:CHANNEL_NAME_KEY];
				//todo: when someone navigates to a channel from search or a list they need the follow object
				Channel *verbatmChannelObject = [[Channel alloc] initWithChannelName:channelName
															   andParseChannelObject:parseChannelObject
																   andChannelCreator:channelCreator andFollowObject:nil];
				[finalChannels addObject:verbatmChannelObject];
			}
			completionBlock([UtilityFunctions shuffleArray: finalChannels]);
		}];
	}];
}

@end

