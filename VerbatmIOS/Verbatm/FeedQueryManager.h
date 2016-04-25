//
//  FeedQueryManager.h
//  Verbatm
//
//  Created by Iain Usiri on 2/6/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//
// 	Manages downloading posts for our feed.

#import <Foundation/Foundation.h>
#import <Parse/PFUser.h>
#import <Parse/PFObject.h>


@interface FeedQueryManager : NSObject

#define POST_DOWNLOAD_MAX_SIZE 10
#define CHANNEL_DOWNLOAD_MAX_SIZE 10

+(instancetype) sharedInstance;

/* Reloads the channels that the user follows and then POST_DOWNLOAD_MAX_SIZE of 
   the posts associated with those channels, from newest to oldest. */
-(void) refreshFeedWithCompletionHandler:(void(^)(NSArray *))block;

/* Loads POST_DOWNLOAD_MAX_SIZE more posts from the place we left off, loading only
   older posts than those returned so far. Refresh must be called first. */
-(void) loadMorePostsWithCompletionHandler:(void(^)(NSArray *))block;

/* Reloads channels for current user's explore section, obviously excluding channels owned by the user
   or channels they already follow. Returns up to CHANNEL_DOWNLOAD_MAX_SIZE channels */
-(void) refreshExploreChannelsWithCompletionHandler:(void(^)(NSArray *))completionBlock;

/* Loads more channels for current user's explore section, up to CHANNEL_DOWNLOAD_MAX_SIZE */
-(void) loadMoreExploreChannelsWithCompletionHandler:(void(^)(NSArray *))completionBlock;

/* Returns featured channels for current user (including their own channels and channels they follow).
   Since there will not be too many at a given time there is no cursor for these */
-(void) loadFeaturedChannelsWithCompletionHandler:(void(^)(NSArray *))completionBlock;




@end
