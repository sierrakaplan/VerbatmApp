//
//  FeedQueryManager.h
//  Verbatm
//
//  Created by Iain Usiri on 2/6/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 This manages the downloading of posts for our feed.
 */




@interface FeedQueryManager : NSObject
//the class maintains a cursor that knows from which point it should
//return content.
//Will return at most 20 results at any time
//If there are no more posts then the argument will be NULL.
-(void)getMoreFeedPostsWithCompletionHandler:(void(^)(NSArray *))block;
@end
