//
//  Channel_BackendObject.m
//  Verbatm
//
//  Created by Iain Usiri on 1/27/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

/*
 Manges creating channel objects and saving them as well as saving posts to channels
 */

#import "Channel_BackendObject.h"
#import "Channel.h"
#import "Post_BackendObject.h"
#import "ParseBackendKeys.h"
#import <Parse/PFQuery.h>
#import "UserManager.h"
#import "UserInfoCache.h"

@interface Channel_BackendObject ()
@property (nonatomic) NSMutableArray * ourPosts;
@end

@implementation Channel_BackendObject

-(instancetype)init{
	self = [super init];
	if(self){
		self.ourPosts = [[NSMutableArray alloc] init];
	}
	return self;
}

+(void)createChannelWithName:(NSString *)channelName andCompletionBlock:(void(^)(PFObject *))block {
	PFUser * ourUser = [PFUser currentUser];
	if(ourUser){
		PFObject * newChannelObject = [PFObject objectWithClassName:CHANNEL_PFCLASS_KEY];
		[newChannelObject setObject:channelName forKey:CHANNEL_NAME_KEY];
		[newChannelObject setObject:[NSNumber numberWithInteger:0] forKey:CHANNEL_NUM_FOLLOWS];
		[newChannelObject setObject:[PFUser currentUser] forKey:CHANNEL_CREATOR_KEY];
		[newChannelObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
			if(succeeded){
				block(newChannelObject);
			} else {
				block(nil);
			}
		}];
	} else {
		block (nil);
	}
}

//returns channel when we create a new one
-(void) createPostFromPinchViews: (NSArray*) pinchViews toChannel: (Channel *) channel
				  withCompletionBlock:(void(^)(PFObject *))block {
	if(channel.parseChannelObject){
		block ([self createPostFromPinchViews:pinchViews andChannel:channel]);
	} else {
		[Channel_BackendObject createChannelWithName:channel.name andCompletionBlock:^(PFObject* channelObject){
			[channel addParseChannelObject:channelObject andChannelCreator:[PFUser currentUser]];
			block ([self createPostFromPinchViews:pinchViews andChannel:channel]);
		}];
	}
}

-(PFObject *) createPostFromPinchViews:(NSArray*)pinchViews andChannel:(Channel*)channel {
	Post_BackendObject * newPost = [[Post_BackendObject alloc]init];
	[self.ourPosts addObject:newPost];
	return [newPost createPostFromPinchViews:pinchViews toChannel:channel];
}

+ (void) getChannelsForUser:(PFUser *) user withCompletionBlock:(void(^)(NSMutableArray *))completionBlock{
	if(user) {
		PFQuery * userChannelQuery = [PFQuery queryWithClassName:CHANNEL_PFCLASS_KEY];
		[userChannelQuery whereKey:CHANNEL_CREATOR_KEY equalTo:user];
		[userChannelQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
															 NSError * _Nullable error) {
			NSMutableArray * finalChannelObjects = [[NSMutableArray alloc] init];
			if(objects && !error){
				for(PFObject * parseChannelObject in objects){

					NSString * channelName  = [parseChannelObject valueForKey:CHANNEL_NAME_KEY];
					// get number of follows from follow objects
					Channel * verbatmChannelObject = [[Channel alloc] initWithChannelName:channelName
																	andParseChannelObject:parseChannelObject
																		andChannelCreator:user];
					[finalChannelObjects addObject:verbatmChannelObject];
				}
			}
			completionBlock(finalChannelObjects);
		}];
	} else {
		completionBlock([[NSMutableArray alloc] init]);
	}
}

//gets all the channels on V except the provided user.
//often this will be the current user
+(void) getAllChannelsButNoneForUser:(PFUser *) user withCompletionBlock:(void(^)(NSMutableArray *))completionBlock {
	//First get all the people who have blocked this user and do not include their channels
	PFQuery *blockQuery = [PFQuery queryWithClassName:BLOCK_PFCLASS_KEY];
	[blockQuery whereKey:BLOCK_USER_BLOCKED_KEY equalTo:user];
	[blockQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable blocks, NSError * _Nullable error) {
		NSMutableArray *usersWhoHaveBlockedUser = [[NSMutableArray alloc] init];
		for (PFObject *block in blocks) {
			[usersWhoHaveBlockedUser addObject:[block valueForKey:BLOCK_USER_BLOCKING_KEY]];
		}

		PFQuery *allChannelsQuery = [PFQuery queryWithClassName:CHANNEL_PFCLASS_KEY];
		[allChannelsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable channels, NSError * _Nullable error) {
			NSMutableArray * finalChannels = [[NSMutableArray alloc] init];
			if(channels && channels.count){
				for(PFObject * parseChannelObject in channels){
					PFUser *channelCreator = [parseChannelObject valueForKey:CHANNEL_CREATOR_KEY];
					if(channelCreator != [PFUser currentUser] && ![usersWhoHaveBlockedUser containsObject:channelCreator]){
						NSString * channelName  = [parseChannelObject valueForKey:CHANNEL_NAME_KEY];
						Channel * verbatmChannelObject = [[Channel alloc] initWithChannelName:channelName
																		andParseChannelObject:parseChannelObject
																			andChannelCreator:channelCreator];
						[finalChannels addObject:verbatmChannelObject];
					}
				}
			}
			completionBlock(finalChannels);
		}];
	}];
}

@end
