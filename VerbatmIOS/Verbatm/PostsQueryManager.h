//
//  PostsQueryManager.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/24/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//
//	Manages downloading the posts in a channel, maintaining a cursor.

#import <Foundation/Foundation.h>

@interface PostsQueryManager : NSObject

-(void) refreshPostsInChannel:(Channel *)channel startingAt:(NSDate*)date withCompletionBlock:(void(^)(NSArray *))block;

-(void) loadMorePostsInChannel:(Channel*)channel withCompletionBlock:(void(^)(NSArray *))block;

+(void) getPostsInChannel:(Channel*)channel withLimit:(NSInteger)limit withCompletionBlock:(void(^)(NSArray *))block;

@end
