
//
//  Post_Channel_RelationshipManger.m
//  Verbatm
//
//  Created by Iain Usiri on 3/20/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "Follow_BackendManager.h"
#import "Post_Channel_RelationshipManager.h"
#import "ParseBackendKeys.h"
#import <Parse/PFQuery.h>
#import <Parse/PFUser.h>
#import <PromiseKit/PromiseKit.h>


@implementation Post_Channel_RelationshipManager

+(void)savePost:(PFObject *) postParseObject toChannels: (NSMutableArray *) channels withCompletionBlock:(void(^)())block{

	NSMutableArray *postToChannelPromises = [[NSMutableArray alloc] init];

	for(Channel * channel in channels){
		AnyPromise * promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
			PFObject *newPostChannelRelationship = [PFObject objectWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
			[newPostChannelRelationship setObject:postParseObject forKey:POST_CHANNEL_ACTIVITY_POST];
			[newPostChannelRelationship setObject:channel.parseChannelObject forKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO ];
			//we store the person creating the relationship -- either reposter or original owner
			[newPostChannelRelationship setObject:[PFUser currentUser] forKey:RELATIONSHIP_OWNER];
			[newPostChannelRelationship saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
				if (error) {
					[[Crashlytics sharedInstance] recordError:error];
				}
				[channel updateLatestPostDate:postParseObject.createdAt];
				resolve(nil);
			}];
		}];
		[postToChannelPromises addObject:promise];
	}

	PMKWhen(postToChannelPromises).then(^(id data){
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
			if (block) block(YES);
		} else if(block) block(NO);
	}];
}

//todo: clean this up make faster
+(void)getChannelObjectFromParsePCRelationship:(PFObject *) pcr withCompletionBlock:(void(^)(Channel * ))block{
	PFObject * parsePostObject = [pcr valueForKey:POST_CHANNEL_ACTIVITY_POST];
	[parsePostObject fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
		if (error) {
			[[Crashlytics sharedInstance] recordError:error];
			block(nil);
			return;
		}
		PFObject* postOriginalChannel = [parsePostObject valueForKey:POST_CHANNEL_KEY];
		[postOriginalChannel fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable postChannel, NSError * _Nullable channelError) {
			[[postChannel valueForKey:CHANNEL_CREATOR_KEY] fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable user, NSError * _Nullable userError) {
				if (!user) {
					NSError *error = channelError ? channelError : userError;
					[[Crashlytics sharedInstance] recordError: error];
					block (nil);
					return;
				}
				PFUser *channelCreator = (PFUser *)user;
				NSString *channelName  = [postChannel valueForKey:CHANNEL_NAME_KEY];
				Channel *verbatmChannelObject = [[Channel alloc] initWithChannelName:channelName
															   andParseChannelObject:postChannel
																   andChannelCreator:channelCreator
																	 andFollowObject:nil];
				block(verbatmChannelObject);
			}];
		}];
	}];
}

+(void)isPost:(PFObject *) postParseObject partOfChannel: (Channel *) channel withCompletionBlock:(void(^)(bool ))block{

}


@end
