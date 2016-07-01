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

@interface PostsQueryManager()

@property (strong, nonatomic) NSDate *latestDate;
@property (strong, nonatomic) NSDate *oldestDate;

#define POSTS_DOWNLOAD_SIZE 5

@end

@implementation PostsQueryManager

-(instancetype) init {
	self = [super init];
	if (self) {
		self.latestDate = nil;
		self.oldestDate = nil;
	}
	return self;
}

/* Loads newest posts in channel older than latest date (if date is nil, just loads newest
   posts).
 */
-(void) loadPostsInChannel:(Channel*)channel withLatestDate:(NSDate*)date
	 withCompletionBlock:(void(^)(NSArray *))block {

	PFQuery * postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
	[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:channel.parseChannelObject];
	[postQuery orderByDescending:@"createdAt"];
	if (date) [postQuery whereKey:@"createdAt" lessThanOrEqualTo:date];
	self.latestDate = date;
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
				self.latestDate = [(PFObject*)(activities[0]) createdAt];
			}
			block([[[finalPostObjects reverseObjectEnumerator] allObjects] mutableCopy]);
		}
	}];
}

// Finds all posts newer than latest date (if there are any) or if latest date is nil
// just finds newest posts
-(void) refreshNewestPostsInChannel:(Channel *)channel withCompletionBlock:(void(^)(NSArray *))block {

	PFQuery * postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
	[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:channel.parseChannelObject];
	[postQuery orderByDescending:@"createdAt"];
	if (self.latestDate) [postQuery whereKey:@"createdAt" greaterThan:self.latestDate];
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
			}
			block([[[finalPostObjects reverseObjectEnumerator] allObjects] mutableCopy]);
		}
	}];
}

//todo: change to make consistent
//-(void) refreshPostsInUserChannel:(Channel*)channel withCompletionBlock:(void(^)(NSArray *))block {
//	PFQuery * postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
//	[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:channel.parseChannelObject];
//	[postQuery orderByDescending:@"createdAt"];
//	[postQuery setLimit: 1];
//	[postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable activities,
//												  NSError * _Nullable error) {
//		if(activities && !error) {
//            @autoreleasepool {
//                NSMutableArray * finalPostObjects = [[NSMutableArray alloc] init];
//                for(PFObject * pc_activity in activities){
//                    PFObject * post = [pc_activity objectForKey:POST_CHANNEL_ACTIVITY_POST];
//                    [post fetchIfNeededInBackground];
//                    [finalPostObjects addObject:pc_activity];
//                }
//                if (activities.count > 0) {
//                    // reversed because we ordered by descending
//                    self.oldestDate = [(PFObject*)(activities[activities.count-1]) createdAt];
//                    self.latestDate = [(PFObject*)(activities[0]) createdAt];
//                }
//                
//                self.postsDownloaded = finalPostObjects.count;
//                block([[[finalPostObjects reverseObjectEnumerator] allObjects] mutableCopy]);
//            }
//		}
//	}];
//}

//// Loads newer posts in channel from date that left off
//-(void) loadMorePostsInChannel:(Channel*)channel withCompletionBlock:(void(^)(NSArray *))block {
//	PFQuery * postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
//	[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:channel.parseChannelObject];
//	[postQuery orderByAscending:@"createdAt"];
//	if (self.latestDate) [postQuery whereKey:@"createdAt" greaterThan:self.latestDate];
//	[postQuery setLimit: POSTS_DOWNLOAD_SIZE];
//	//	[postQuery setSkip: self.postsDownloaded]; //todo: delete?
//	[postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable activities,
//												  NSError * _Nullable error) {
//		if(activities && !error) {
//			NSMutableArray * finalPostObjects = [[NSMutableArray alloc] init];
//
//			for(PFObject * pc_activity in activities){
//				PFObject * post = [pc_activity objectForKey:POST_CHANNEL_ACTIVITY_POST];
//				[post fetchIfNeededInBackground];
//				[finalPostObjects addObject:pc_activity];
//			}
//
//			if (activities.count > 0) {
//				self.latestDate = [(PFObject*)(activities[activities.count-1]) createdAt];
//			}
//			self.postsDownloaded += finalPostObjects.count;
//			block(finalPostObjects);
//		}
//	}];
//}

// Loads posts older than the current oldest date 
-(void) loadOlderPostsInChannel:(Channel*)channel withCompletionBlock:(void(^)(NSArray *))block {
	// If oldest date has not been set then no posts have been loaded previously
	// or there are no posts
	if (!self.oldestDate) block (@[]);
	PFQuery * postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
	[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:channel.parseChannelObject];
	[postQuery orderByDescending:@"createdAt"];
	[postQuery whereKey:@"createdAt" lessThan:self.oldestDate];
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