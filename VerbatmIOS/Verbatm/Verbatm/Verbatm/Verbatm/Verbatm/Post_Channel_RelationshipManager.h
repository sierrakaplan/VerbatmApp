//
//  Post_Channel_RelationshipManger.h
//  Verbatm
//
//  Created by Iain Usiri on 3/20/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/PFObject.h>
#import "Channel.h"
/*
 How we maintain relationships between posts and channels.
 This allows us to efficiently implement reposting -- it's simply
 another relationship.
 
 */


@interface Post_Channel_RelationshipManager : NSObject
//used when an object is being created for the first time
+(void)savePost:(PFObject *) postParseObject toChannels: (NSMutableArray *) channels
                                                    withCompletionBlock:(void(^)())block;

+(void)deleteChannelRelationshipsForPost:(PFObject *) postParseObject withCompletionBlock:(void(^)(bool))block;

+(void)isPost:(PFObject *) postParseObject partOfChannel: (Channel *) channel
                                                    withCompletionBlock:(void(^)(bool))block;
+(void)getChannelObjectFromParsePCRelationship:(PFObject *) pcr
                                                    withCompletionBlock:(void(^)(Channel * ))block;
@end
