
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
#import "Notifications.h"
#import "ParseBackendKeys.h"
#import <Parse/PFQuery.h>
#import <PromiseKit/PromiseKit.h>
#import "UtilityFunctions.h"

#import <ParseFacebookutilsV4/PFFacebookUtils.h>
#import <Parse/PFCloud.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@import Contacts;

@interface FeedQueryManager ()

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
		[self clearFeedData];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(userHasSignedOut)
													 name:NOTIFICATION_USER_SIGNED_OUT
												   object:nil];
	}
	return self;
}

-(void) userHasSignedOut {
	[self clearFeedData];
}

-(void) clearFeedData {
	self.channelsFollowed = nil;
	self.channelsFollowedIds = nil;
	self.followedChannelsRefreshing = NO;
	self.channelsRefreshingCondition = [[NSCondition alloc] init];
	self.exploreChannelsLoaded = 0;
	self.usersWhoHaveBlockedUser = nil;
	self.friendUsers = nil;
	self.friendChannels = nil;
}

//todo: cloud code
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

		//todo: cloud code
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

//Gets all the channels on Verbatm except the provided user and channels owned by people who have blocked user.
//Often this will be the current user
-(void) refreshExploreChannelsWithCompletionHandler:(void(^)(NSArray *))completionBlock {
	self.exploreChannelsLoaded = 0;
	self.friendChannels = nil;
	self.friendUsers = nil;
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
		//todo: cloud code
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
					[exploreChannelsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable channels,
																			 NSError * _Nullable error) {
						if(error || !channels) {
							[[Crashlytics sharedInstance] recordError:error];
							completionBlock ([NSMutableArray array]);
							return;
						}
						NSArray *exploreChannels = [Channel_BackendObject channelsFromParseChannelObjects: channels];
						exploreChannels = [UtilityFunctions shuffleArray: exploreChannels];
						NSMutableArray *finalChannels = [NSMutableArray arrayWithArray:exploreChannels];
						if (skip == 0 && friendChannels.count > 0) {
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

// resolves to channels of friends (as pfobjects), friend users
-(void) loadFriendsChannelsWithCompletionHandler:(void(^)(NSArray *, NSArray *))completionBlock {
	if (self.friendChannels) {
		completionBlock(self.friendChannels, self.friendUsers);
		return;
	}
	[self getPhoneContactsWithCompletionHandler:^(NSArray *contactChannels, NSArray *contactUsers) {
		BOOL isLinkedToFacebook = [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]];
		// Logged in with phone number
		if (!isLinkedToFacebook) {
			completionBlock(contactChannels, contactUsers);
			return;
		} else if (![[FBSDKAccessToken currentAccessToken] hasGranted:@"user_friends"]) {
			completionBlock(contactChannels, contactUsers);
			return;
		} else {
			NSDictionary *params = @{@"userId": [PFUser currentUser].objectId};
			[PFCloud callFunctionInBackground:@"getFacebookFriends" withParameters:params
										block:^(id  _Nullable friendUsers, NSError * _Nullable error) {

											for (PFUser *user in friendUsers) {
												NSLog(@"friend: %@", user[VERBATM_USER_NAME_KEY]);
											}
											[self getChannelsForFriends:friendUsers withCompletionHandler:^(NSArray *channels) {
												NSMutableArray *combinedChannels = [NSMutableArray arrayWithArray: contactChannels];
												[combinedChannels addObjectsFromArray: channels];
												NSMutableArray *combinedUsers = [NSMutableArray arrayWithArray: contactUsers];
												[combinedUsers addObjectsFromArray: friendUsers];
												self.friendUsers = combinedUsers;
												self.friendChannels = combinedChannels;
												completionBlock(combinedChannels, combinedUsers);
											}];
										}];
		}
	}];
}

-(void) getChannelsForAllFriendsWithCompletionHandler:(void(^)(NSArray *))completionBlock {
	[self loadFriendsChannelsWithCompletionHandler:^(NSArray *channelObjects, NSArray *users) {
		NSArray *friendChannels = [Channel_BackendObject channelsFromParseChannelObjects: channelObjects];
		completionBlock(friendChannels);
	}];
}

-(void) getChannelsForPhoneContactsWithCompletionHandler:(void(^)(NSArray *))completionBlock {
	[self getPhoneContactsWithCompletionHandler:^(NSArray *channelObjects, NSArray *users) {
		NSArray *friendChannels = [Channel_BackendObject channelsFromParseChannelObjects: channelObjects];
		completionBlock(friendChannels);
	}];
}

-(void) getPhoneContactsWithCompletionHandler:(void(^)(NSArray *, NSArray *))completionBlock {
	CNContactStore *contactStore = [[CNContactStore alloc] init];
	CNEntityType entityType = CNEntityTypeContacts;
	if([CNContactStore authorizationStatusForEntityType:entityType] == CNAuthorizationStatusNotDetermined) {
		// Request access for entity type returns on arbitrary queue
		[contactStore requestAccessForEntityType:entityType completionHandler:^(BOOL granted, NSError * _Nullable error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (granted && error == nil) {
					[self getAllContactsWithStore:contactStore andCompletionHandler:^(NSArray *friendChannels, NSArray *friendUsers) {
						completionBlock(friendChannels, friendUsers);
					}];
				} else {
					completionBlock([NSMutableArray array], [NSMutableArray array]);
				}
			});
		}];
	} else if([CNContactStore authorizationStatusForEntityType:entityType]== CNAuthorizationStatusAuthorized) {
		[self getAllContactsWithStore:contactStore andCompletionHandler:^(NSArray *friendChannels, NSArray *friendUsers) {
			completionBlock(friendChannels, friendUsers);
		}];
	} else {
		completionBlock([NSMutableArray array], [NSMutableArray array]);
	}
}

-(void) getAllContactsWithStore:(CNContactStore*)store andCompletionHandler:(void(^)(NSArray *, NSArray *))completionBlock {
	//keys with fetching properties
	NSArray *keys = @[CNContactPhoneNumbersKey];
	NSString *containerId = store.defaultContainerIdentifier;
	NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
	NSError *error;
	NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
	if (error) {
		NSLog(@"error fetching contacts %@", error);
		[[Crashlytics sharedInstance] recordError: error];
		completionBlock([NSMutableArray array], [NSMutableArray array]);
	} else {
		NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
		for (CNContact *contact in cnContacts) {
			// copy data to my custom Contacts class.
			for (CNLabeledValue *phoneNumberKey in contact.phoneNumbers) {
				CNPhoneNumber *phoneNumber = phoneNumberKey.value;
				NSString *plainPhoneNumber = [[phoneNumber.stringValue componentsSeparatedByCharactersInSet:
											   [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
											  componentsJoinedByString:@""];
				if (![plainPhoneNumber isEqualToString:[PFUser currentUser].username]) {
					[phoneNumbers addObject: plainPhoneNumber];
				}
			}
		}
		PFQuery *friendQuery = [PFUser query];
		[friendQuery whereKey:@"username" containedIn: phoneNumbers];
		// findObjects will return a list of PFUsers that are friends with the current user
		[friendQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable friendUsers, NSError * _Nullable error) {
			if (error || !friendUsers.count) {
				completionBlock([NSMutableArray array], [NSMutableArray array]);
			} else {
				[self getChannelsForFriends:friendUsers withCompletionHandler:^(NSArray *friendChannels) {
					completionBlock(friendChannels, friendUsers);
				}];
			}
		}];
	}
}

//Returns the channels that the current user is not following associated with their friends
-(void) getChannelsForFriends:(NSArray*)friendUsers withCompletionHandler:(void(^)(NSArray *))completionBlock {
	PFQuery *channelsForFriends = [PFQuery queryWithClassName:CHANNEL_PFCLASS_KEY];
	[channelsForFriends whereKey:CHANNEL_CREATOR_KEY containedIn:friendUsers];
	[channelsForFriends whereKey:CHANNEL_CREATOR_KEY notContainedIn: self.usersWhoHaveBlockedUser];
	//todo: comment out this line for testing
	[channelsForFriends whereKey:@"objectId" notContainedIn: self.channelsFollowedIds];
	[channelsForFriends whereKeyExists:CHANNEL_LATEST_POST_DATE];
	[channelsForFriends orderByDescending:@"createdAt"];
	channelsForFriends.limit = 1000;
	[channelsForFriends findObjectsInBackgroundWithBlock:^(NSArray * _Nullable channels, NSError * _Nullable error) {
		if (error) {
			completionBlock([NSMutableArray array]);
		} else {
			completionBlock(channels);
		}
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

-(NSMutableArray*) usersWhoHaveBlockedUser {
	if (!_usersWhoHaveBlockedUser) {
		_usersWhoHaveBlockedUser = [[NSMutableArray alloc] init];
	}
	return _usersWhoHaveBlockedUser;
}

-(NSMutableArray*) channelsFollowed {
	if (!_channelsFollowed) {
		_channelsFollowed = [[NSMutableArray alloc] init];
	}
	return _channelsFollowed;
}

-(NSMutableArray*) channelsFollowedIds {
	if (!_channelsFollowedIds) {
		_channelsFollowedIds = [[NSMutableArray alloc] init];
	}
	return _channelsFollowedIds;
}

@end

