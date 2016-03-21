
//
//  Post_Channel_RelationshipManger.m
//  Verbatm
//
//  Created by Iain Usiri on 3/20/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Post_Channel_RelationshipManger.h"
#import "ParseBackendKeys.h"
#import <Parse/PFQuery.h>
#import <PromiseKit/PromiseKit.h>


@implementation Post_Channel_RelationshipManger


+(void)savePost:(PFObject *) postParseObject toChannels: (NSMutableArray *) channels withCompletionBlock:(void(^)())block{
   
    NSMutableArray * pageLoadPromises = [[NSMutableArray alloc] init];

    for(Channel * channel in channels){
         AnyPromise * promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
             PFObject * newFollowObject = [PFObject objectWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
             [newFollowObject setObject:postParseObject forKey:POST_CHANNEL_ACTIVITY_POST];
             [newFollowObject setObject:channel.parseChannelObject forKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO ];
             [newFollowObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                 resolve(nil);
             }];
         
         }];
        
        [pageLoadPromises addObject:promise];
    }
    
    
    PMKWhen(pageLoadPromises).then(^(id data){
        if(block)block();
    });
    
}

+(void)deletePost:(PFObject *) postParseObject fromChannel: (Channel *) channel withCompletionBlock:(void(^)(bool))block{
    PFQuery * userChannelQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
    [userChannelQuery whereKey:FOLLOW_CHANNEL_FOLLOWED_KEY equalTo:channel.parseChannelObject];
    [userChannelQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO equalTo:postParseObject];
    
    [userChannelQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                         NSError * _Nullable error) {
        if(objects && !error) {
            if(objects.count){
                PFObject * followObj = [objects firstObject];
                [followObj deleteInBackground];
            }
        }
    }];
}

+(void)isPost:(PFObject *) postParseObject partOfChannel: (Channel *) channel withCompletionBlock:(void(^)(bool ))block{
    
}


@end
