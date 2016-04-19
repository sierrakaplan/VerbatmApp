
//
//  Post_Channel_RelationshipManger.m
//  Verbatm
//
//  Created by Iain Usiri on 3/20/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Follow_BackendManager.h"
#import "Post_Channel_RelationshipManager.h"
#import "ParseBackendKeys.h"
#import <Parse/PFQuery.h>
#import <Parse/PFUser.h>
#import <PromiseKit/PromiseKit.h>


@implementation Post_Channel_RelationshipManager


+(void)savePost:(PFObject *) postParseObject toChannels: (NSMutableArray *) channels withCompletionBlock:(void(^)())block{
   
    NSMutableArray * pageLoadPromises = [[NSMutableArray alloc] init];

    for(Channel * channel in channels){
         AnyPromise * promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
             PFObject * newFollowObject = [PFObject objectWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
             [newFollowObject setObject:postParseObject forKey:POST_CHANNEL_ACTIVITY_POST];
             [newFollowObject setObject:channel.parseChannelObject forKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO ];
             //we store the person creating the relationship -- either reposter or original owner
             [newFollowObject setObject:[PFUser currentUser] forKey:FOLLOW_CHANNEL_RELATIONSHIP_OWNER];
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


+(void)deleteChannelRelationshipsForPost:(PFObject *) postParseObject withCompletionBlock:(void(^)(bool))block{
    PFQuery * postChannelRelationshipQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
    [postChannelRelationshipQuery whereKey:POST_CHANNEL_ACTIVITY_POST equalTo:postParseObject];
    [postChannelRelationshipQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                         NSError * _Nullable error) {
        if(objects && !error) {
			for (PFObject *obj in objects) {
				[obj deleteInBackground];
			}
        }
    }];
}

+(void)getChannelObjectFromParsePCRelationship:(PFObject *) pcr withCompletionBlock:(void(^)(Channel * ))block{
    PFObject * parsePostObject = [pcr valueForKey:POST_CHANNEL_ACTIVITY_POST];
    [parsePostObject fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFObject* postOriginalChannel = [parsePostObject valueForKey:POST_CHANNEL_KEY];
        [postOriginalChannel fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable channelError) {
			[[postOriginalChannel valueForKey:CHANNEL_CREATOR_KEY] fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable user, NSError * _Nullable userError) {
				if (!object || !user) {
					NSError *error = channelError ? channelError : userError;
					NSLog(@"Error: %@", error.description);
					block (nil);
					return;
				}
				PFUser *channelCreator = (PFUser *)user;
				NSString *channelName  = [postOriginalChannel valueForKey:CHANNEL_NAME_KEY];
				Channel *verbatmChannelObject = [[Channel alloc] initWithChannelName:channelName
															   andParseChannelObject:postOriginalChannel
																   andChannelCreator:channelCreator];
				block(verbatmChannelObject);
			}];
        }];
    }];
}

+(void)isPost:(PFObject *) postParseObject partOfChannel: (Channel *) channel withCompletionBlock:(void(^)(bool ))block{
    
}


@end
