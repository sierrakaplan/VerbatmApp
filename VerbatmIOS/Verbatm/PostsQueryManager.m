//
//  PostsQueryManager.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/24/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel.h"
#import "PostsQueryManager.h"
#import <Parse/PFQuery.h>
#import "ParseBackendKeys.h"
#import "UserInfoCache.h"

@interface PostsQueryManager()

@property (strong, nonatomic) NSDate *latestDate;
@property (strong, nonatomic) NSDate *oldestDate;
@property (nonatomic) BOOL smallMode;

#define POSTS_DOWNLOAD_SIZE 20

@end

@implementation PostsQueryManager

-(instancetype) initInSmallMode:(BOOL)smallMode {
	self = [super init];
	if (self) {
		self.latestDate = nil;
		self.oldestDate = nil;
		self.smallMode = smallMode;
	}
	return self;
}

/* Loads posts in channel newer or equal to latest date
   If less than 3 posts are found, loads 3 older posts too
  (If latest date is nil, just loads oldest posts)
*/
-(void) loadPostsInChannel:(Channel*)channel withLatestDate:(NSDate*)date
	 withCompletionBlock:(void(^)(NSArray *))block {

	PFQuery * postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
	[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:channel.parseChannelObject];
	[postQuery orderByAscending:@"createdAt"];
	if (date) {
		[postQuery whereKey:@"createdAt" greaterThanOrEqualTo:date];
		//todo: decide whether to load older posts based on channel's latest post date
	}
	[postQuery setLimit: POSTS_DOWNLOAD_SIZE];
	[postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable activities,
												  NSError * _Nullable error) {
		if(activities && !error) {
			NSMutableArray * finalPostObjects = [[NSMutableArray alloc] init];
			for(PFObject * pc_activity in activities){
				PFObject * post = [pc_activity objectForKey:POST_CHANNEL_ACTIVITY_POST];
				[post fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
				}];
				[finalPostObjects addObject:pc_activity];
			}
			if (activities.count > 0) {
				self.oldestDate = [(PFObject*)(activities[0]) createdAt];
				self.latestDate = [(PFObject*)(activities[activities.count-1]) createdAt];
			}

			// Load older posts if less than 3 are found
			if (activities.count < 3) {
				[self loadOlderPostsInChannel:channel withCompletionBlock:^(NSArray *posts) {
					NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, posts.count)];
					[finalPostObjects insertObjects:posts atIndexes:indexSet];
					block(finalPostObjects);
				}];
			} else {
				block(finalPostObjects);
			}
		} else {
			block(@[]);
		}
	}];
}

// Finds all posts newer than latest date (if there are any) or if latest date is nil
// just finds newest posts
-(void) loadNewerPostsInChannel:(Channel *)channel withCompletionBlock:(void(^)(NSArray *))block {
	PFQuery * postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
	[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:channel.parseChannelObject];
	[postQuery orderByDescending:@"createdAt"];
	if (self.latestDate) {
		[postQuery whereKey:@"createdAt" greaterThan:self.latestDate];
	}
	[postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable activities,
												  NSError * _Nullable error) {
		if(activities && !error) {
			NSMutableArray * finalPostObjects = [[NSMutableArray alloc] init];
			for(PFObject * pc_activity in activities){
				PFObject * post = [pc_activity objectForKey:POST_CHANNEL_ACTIVITY_POST];
				[post fetchIfNeededInBackground];
				[finalPostObjects addObject:pc_activity];
			}
			if (activities.count > 0) {
				// Posts are in reverse chronological order
				self.latestDate = [(PFObject*)(activities[0]) createdAt];
				if (!self.oldestDate) self.oldestDate = [(PFObject*)(activities[activities.count-1]) createdAt];
			}
			block([[[finalPostObjects reverseObjectEnumerator] allObjects] mutableCopy]);
		}
	}];
}

// Loads posts older than the current oldest date 
-(void) loadOlderPostsInChannel:(Channel*)channel withCompletionBlock:(void(^)(NSArray *))block {
	PFQuery * postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
	[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:channel.parseChannelObject];
	[postQuery orderByDescending:@"createdAt"];
	if (self.oldestDate) {
		[postQuery whereKey:@"createdAt" lessThan:self.oldestDate];
	}
	[postQuery setLimit: POSTS_DOWNLOAD_SIZE];
	[postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable activities,
												  NSError * _Nullable error) {
		if(activities && !error) {
			NSMutableArray * finalPostObjects = [[NSMutableArray alloc] init];

			for(PFObject * pc_activity in activities){
				PFObject * post = [pc_activity objectForKey:POST_CHANNEL_ACTIVITY_POST];
				[post fetchIfNeededInBackground];
				[finalPostObjects addObject:pc_activity];
			}

			if (activities.count > 0) {
				// Posts are in reverse chronological order
				self.oldestDate = [(PFObject*)(activities[activities.count-1]) createdAt];
				if (!self.latestDate) {
					self.latestDate = [(PFObject*)(activities[0]) createdAt];
				}
			}
			block([[[finalPostObjects reverseObjectEnumerator] allObjects] mutableCopy]);
		}
	}];
}

// Loads newest posts in channel up to the given limit
+(void) getPostsInChannel:(Channel*)channel withLimit:(NSInteger)limit withCompletionBlock:(void(^)(NSArray *))block {
	if(!channel) {
		block (@[]);
		return;
	}
	PFQuery * postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
	[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:channel.parseChannelObject];
	[postQuery orderByDescending:@"createdAt"];
	[postQuery setLimit: limit];
	[postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable activities,
												  NSError * _Nullable error) {
		if(activities && !error) {
			NSMutableArray * finalPostObjects = [[NSMutableArray alloc] init];
			for(PFObject * pc_activity in activities){
				PFObject * post = [pc_activity objectForKey:POST_CHANNEL_ACTIVITY_POST];
				[post fetchIfNeededInBackground];
				[finalPostObjects addObject:pc_activity];
			}
			block([[[finalPostObjects reverseObjectEnumerator] allObjects] mutableCopy]);
		}
	}];
}

@end