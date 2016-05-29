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

-(void) refreshPostsInChannel:(Channel *)channel withCompletionBlock:(void(^)(NSArray *))block {
	if(!channel) {
		block (@[]);
		return;
	}
	PFQuery * postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
	[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:channel.parseChannelObject];
	[postQuery orderByAscending:@"createdAt"];
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
			self.postsDownloaded = 0;
			self.postsDownloaded += finalPostObjects.count;
			block(finalPostObjects);
		}
	}];
}

-(void) loadMorePostsInChannel:(Channel*)channel withCompletionBlock:(void(^)(NSArray *))block {
	PFQuery * postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
	[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:channel.parseChannelObject];
	[postQuery orderByAscending:@"createdAt"];
	[postQuery setLimit: POSTS_DOWNLOAD_SIZE];
	[postQuery setSkip: self.postsDownloaded];
	[postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable activities,
												  NSError * _Nullable error) {
		if(activities && !error) {
			NSMutableArray * finalPostObjects = [[NSMutableArray alloc] init];

			for(PFObject * pc_activity in activities){

				PFObject * post = [pc_activity objectForKey:POST_CHANNEL_ACTIVITY_POST];
				[post fetchIfNeededInBackground];
				[finalPostObjects addObject:pc_activity];
			}

			self.postsDownloaded += finalPostObjects.count;
			block(finalPostObjects);
		}
	}];
}

+(void) getPostsInChannel:(Channel*)channel withLimit:(NSInteger)limit withCompletionBlock:(void(^)(NSArray *))block {
	if(!channel) {
		block (@[]);
		return;
	}
	PFQuery * postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
	[postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:channel.parseChannelObject];
	[postQuery orderByAscending:@"createdAt"];
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