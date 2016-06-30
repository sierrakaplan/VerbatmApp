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

@property (nonatomic) NSInteger postsDownloaded;
@property (strong, nonatomic) NSDate *latestDate;
@property (strong, nonatomic) NSDate *oldestDate;

#define POSTS_DOWNLOAD_SIZE 5

@end

@implementation PostsQueryManager

-(instancetype) init {
	self = [super init];
	if (self) {
		self.postsDownloaded = 0;
	}
	return self;
}

// Loads oldest posts in channel starting at date
-(void) refreshPostsInChannel:(Channel *)channel startingAt:(NSDate*)date withCompletionBlock:(void(^)(NSArray *))block {
	if(!channel) {
		block (@[]);
		return;
	}
	PFQuery * postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
	[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:channel.parseChannelObject];
	[postQuery orderByAscending:@"createdAt"];
	if (date) [postQuery whereKey:@"createdAt" greaterThan:date];
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
				self.oldestDate = [(PFObject*)(activities[0]) createdAt];
				self.latestDate = [(PFObject*)(activities[activities.count-1]) createdAt];
			}
			self.postsDownloaded = finalPostObjects.count;
			block(finalPostObjects);
		}
	}];
}

//todo: change to make consistent
-(void) refreshPostsInUserChannel:(Channel*)channel withCompletionBlock:(void(^)(NSArray *))block {
	PFQuery * postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
	[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:channel.parseChannelObject];
	[postQuery orderByDescending:@"createdAt"];
	[postQuery setLimit: 1];
	[postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable activities,
												  NSError * _Nullable error) {
		if(activities && !error) {
            @autoreleasepool {
                NSMutableArray * finalPostObjects = [[NSMutableArray alloc] init];
                for(PFObject * pc_activity in activities){
                    PFObject * post = [pc_activity objectForKey:POST_CHANNEL_ACTIVITY_POST];
                    [post fetchIfNeededInBackground];
                    [finalPostObjects addObject:pc_activity];
                }
                if (activities.count > 0) {
                    // reversed because we ordered by descending
                    self.oldestDate = [(PFObject*)(activities[activities.count-1]) createdAt];
                    self.latestDate = [(PFObject*)(activities[0]) createdAt];
                }
                
                self.postsDownloaded = finalPostObjects.count;
                block([[[finalPostObjects reverseObjectEnumerator] allObjects] mutableCopy]);
            }
		}
	}];
}

// Loads newer posts in channel from date that left off
-(void) loadMorePostsInChannel:(Channel*)channel withCompletionBlock:(void(^)(NSArray *))block {
	PFQuery * postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
	[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:channel.parseChannelObject];
	[postQuery orderByAscending:@"createdAt"];
	if (self.latestDate) [postQuery whereKey:@"createdAt" greaterThan:self.latestDate];
	[postQuery setLimit: POSTS_DOWNLOAD_SIZE];
	//	[postQuery setSkip: self.postsDownloaded]; //todo: delete?
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
				self.latestDate = [(PFObject*)(activities[activities.count-1]) createdAt];
			}
			self.postsDownloaded += finalPostObjects.count;
			block(finalPostObjects);
		}
	}];
}

-(void) loadOlderPostsInChannel:(Channel*)channel withCompletionBlock:(void(^)(NSArray *))block {
	PFQuery * postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
	[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:channel.parseChannelObject];
	[postQuery orderByAscending:@"createdAt"];
	if (self.oldestDate) [postQuery whereKey:@"createdAt" lessThan:self.oldestDate];
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
				self.oldestDate = [(PFObject*)(activities[0]) createdAt];
			}
			self.postsDownloaded += finalPostObjects.count;
			block(finalPostObjects);
		}
	}];
}

// Loads newest posts in channel
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
			block(finalPostObjects);
		}
	}];
}

@end