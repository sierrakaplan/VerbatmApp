
//
//  FeedQueryManager.m
//  Verbatm
//
//  Created by Iain Usiri on 2/6/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel.h"
#import <Crashlytics/Crashlytics.h>
#import "FeedQueryManager.h"
#import "ParseBackendKeys.h"
#import <Parse/PFQuery.h>
#import <PromiseKit/PromiseKit.h>

@interface FeedQueryManager ()

@property (nonatomic) NSInteger postsInFeed;
@property (nonatomic, strong) NSDate *currentFeedStart;
@property (nonatomic, strong) NSDate *currentFeedEnd;

@property (nonatomic, strong) NSMutableArray *channelsFollowed;
@property (nonatomic, strong) NSMutableArray *channelsFollowedIds;
// to stop two queries refreshing simultaneously
@property (nonatomic) BOOL followedChannelsRefreshing;
@property (nonatomic, strong) NSCondition *channelsRefreshingCondition;

@property (nonatomic) NSInteger exploreChannelsLoaded;
@property (nonatomic, strong) NSMutableArray *usersWhoHaveBlockedUser;

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
	self.currentFeedEnd = nil;
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

		PFQuery *followObjectsQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
		[followObjectsQuery whereKey:FOLLOW_USER_KEY equalTo:[PFUser currentUser]];
		[followObjectsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable followObjects, NSError * _Nullable error) {
			self.channelsFollowed = [[NSMutableArray alloc] init];
			self.channelsFollowedIds = [[NSMutableArray alloc] init];
			if (!error && followObjects) { //todo: error handling
				for(PFObject *followObj in followObjects) {
					PFObject *channelObject = [followObj objectForKey:FOLLOW_CHANNEL_FOLLOWED_KEY];
					[self.channelsFollowed addObject: channelObject];
					[self.channelsFollowedIds addObject:[channelObject objectId]];
				}
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
				self.currentFeedEnd = self.currentFeedEnd ? self.currentFeedEnd : [activities[activities.count-1] createdAt];
			}
			//todo: actually clear oldest posts
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
	[postQuery whereKey:@"createdAt" lessThan: self.currentFeedEnd];
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

	PFUser *user = [PFUser currentUser];
	[self refreshChannelsWeFollowWithCompletionHandler:^{
		//First get all the people who have blocked this user and do not include their channels
		PFQuery *blockQuery = [PFQuery queryWithClassName:BLOCK_PFCLASS_KEY];
		[blockQuery whereKey:BLOCK_USER_BLOCKED_KEY equalTo:user];
		[blockQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable blocks, NSError * _Nullable error) {
			self.usersWhoHaveBlockedUser = [[NSMutableArray alloc] init];
			for (PFObject *block in blocks) {
				[self.usersWhoHaveBlockedUser addObject:[block valueForKey:BLOCK_USER_BLOCKING_KEY]];
			}

			PFQuery *exploreChannelsQuery = [PFQuery queryWithClassName:CHANNEL_PFCLASS_KEY];
			[exploreChannelsQuery whereKey:CHANNEL_CREATOR_KEY notEqualTo: user];
			[exploreChannelsQuery whereKey:CHANNEL_CREATOR_KEY notContainedIn: self.usersWhoHaveBlockedUser];
			[exploreChannelsQuery whereKey:@"objectId" notContainedIn: self.channelsFollowedIds];
			[exploreChannelsQuery orderByDescending:CHANNEL_NUM_FOLLOWS];
			[exploreChannelsQuery setLimit:CHANNEL_DOWNLOAD_MAX_SIZE];
			[exploreChannelsQuery setSkip: 0];
			[exploreChannelsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable channels, NSError * _Nullable error) {
				NSMutableArray *finalChannels = [[NSMutableArray alloc] init];
				if(error || !channels) {
					[[Crashlytics sharedInstance] recordError:error];
					completionBlock (finalChannels);
					return;
				}

				NSMutableArray *loadChannelCreatorPromises = [[NSMutableArray alloc] init];
				for(PFObject *parseChannelObject in channels) {
					PFUser *channelCreator = [parseChannelObject valueForKey:CHANNEL_CREATOR_KEY];
					[loadChannelCreatorPromises addObject:[self fetchChannelCreator:channelCreator
														   andCheckIfPostsInChannel:parseChannelObject]];
				}
				//Make sure all creators have been loaded so their names can be displayed
				PMKWhen(loadChannelCreatorPromises).then(^(NSArray* results) {
					for (int i = 0; i < results.count; i++) {
						PFUser *channelCreator = results[i];
						if ([channelCreator isEqual:[NSNull null]]) continue;
						PFObject *channelObj = channels[i];
						NSString *channelName  = [channelObj valueForKey:CHANNEL_NAME_KEY];
						Channel *verbatmChannelObject = [[Channel alloc] initWithChannelName:channelName
																	   andParseChannelObject:channelObj
																		   andChannelCreator:channelCreator];
						[finalChannels addObject:verbatmChannelObject];
					}
					completionBlock(finalChannels);
					self.exploreChannelsLoaded = 0;
					self.exploreChannelsLoaded += results.count;
				});
			}];
		}];
	}];
}

-(AnyPromise*) fetchChannelCreator:(PFUser*)channelCreator andCheckIfPostsInChannel:(PFObject*)channel {
	AnyPromise *promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
		[channelCreator fetchInBackgroundWithBlock:^(PFObject * _Nullable creator, NSError * _Nullable error) {
			if (error || !creator) {
				resolve(nil);
				return;
			}
			//Make sure channel has one post
			PFQuery * postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
			[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:channel];
			[postQuery setLimit:1];
			[postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
				if (!objects || !objects.count) {
					resolve(nil);
					return;
				} else {
					resolve(creator);
				}
			}];
		}];
	}];
	return promise;
}

-(void) loadMoreExploreChannelsWithCompletionHandler:(void(^)(NSArray *))completionBlock {

	//Needs to call refresh first
	if (!self.channelsFollowed || !self.usersWhoHaveBlockedUser) {
		completionBlock (@[]);
		return;
	}

	PFUser *user = [PFUser currentUser];
	PFQuery *exploreChannelsQuery = [PFQuery queryWithClassName:CHANNEL_PFCLASS_KEY];
	[exploreChannelsQuery whereKey:CHANNEL_CREATOR_KEY notEqualTo: user];
	[exploreChannelsQuery whereKey:CHANNEL_CREATOR_KEY notContainedIn: self.usersWhoHaveBlockedUser];
	[exploreChannelsQuery whereKey:@"objectId" notContainedIn: self.channelsFollowedIds];
	[exploreChannelsQuery orderByDescending:CHANNEL_NUM_FOLLOWS];
	[exploreChannelsQuery setLimit:CHANNEL_DOWNLOAD_MAX_SIZE];
	[exploreChannelsQuery setSkip: self.exploreChannelsLoaded];
	[exploreChannelsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable channels, NSError * _Nullable error) {
		NSMutableArray *finalChannels = [[NSMutableArray alloc] init];
		if(error || !channels) {
			[[Crashlytics sharedInstance] recordError:error];
			completionBlock (finalChannels);
			return;
		}

		NSMutableArray *loadChannelCreatorPromises = [[NSMutableArray alloc] init];
		for(PFObject *parseChannelObject in channels) {
			PFUser *channelCreator = [parseChannelObject valueForKey:CHANNEL_CREATOR_KEY];
			[loadChannelCreatorPromises addObject:[self fetchChannelCreator:channelCreator
												   andCheckIfPostsInChannel:parseChannelObject]];
		}
		//Make sure all creators have been loaded so their names can be displayed
		PMKWhen(loadChannelCreatorPromises).then(^(NSArray* results) {
			for (int i = 0; i < results.count; i++) {
				PFUser *channelCreator = results[i];
				if ([channelCreator isEqual:[NSNull null]]) continue;
				PFObject *channelObj = channels[i];
				NSString *channelName  = [channelObj valueForKey:CHANNEL_NAME_KEY];
				Channel *verbatmChannelObject = [[Channel alloc] initWithChannelName:channelName
															   andParseChannelObject:channelObj
																   andChannelCreator:channelCreator];
				[finalChannels addObject:verbatmChannelObject];
			}
			completionBlock(finalChannels);
			self.exploreChannelsLoaded += results.count;
		});
	}];
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
		//			[exploreChannelsQuery whereKey:CHANNEL_CREATOR_KEY notEqualTo: user];
		[featuredChannelsQuery whereKey:CHANNEL_CREATOR_KEY notContainedIn: self.usersWhoHaveBlockedUser];
		[featuredChannelsQuery whereKey:CHANNEL_FEATURED_BOOL equalTo:[NSNumber numberWithBool:YES]];

		//NOTE: if this is uncommented followed channels needs to be refreshed before all of this code
		//			[exploreChannelsQuery whereKey:@"objectId" notContainedIn: self.channelsFollowedIds];
		[featuredChannelsQuery orderByAscending:CHANNEL_NUM_FOLLOWS]; // just to change things up since they're all featured
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
				Channel *verbatmChannelObject = [[Channel alloc] initWithChannelName:channelName
															   andParseChannelObject:parseChannelObject
																   andChannelCreator:channelCreator];
				[finalChannels addObject:verbatmChannelObject];
			}
			completionBlock(finalChannels);
		}];
	}];
}

@end

