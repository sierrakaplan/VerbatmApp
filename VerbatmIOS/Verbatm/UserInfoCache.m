//
//  UserInfoCache.m
//  Verbatm
//
//  Created by Iain Usiri on 3/21/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "UserInfoCache.h"
#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>
#import "Channel_BackendObject.h"
#import "Notifications.h"
/*
 Shared instance that simplifies fetching ubiquitous user information. 
 For example we use it now to cache the users channels - but can be used 
 to store preferences etc.
 
 */

@interface UserInfoCache ()

@property (nonatomic) Channel *userChannel;

@end

@implementation UserInfoCache

+(instancetype)sharedInstance{
    static UserInfoCache *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UserInfoCache alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance
                                                 selector:@selector(reloadUserChannels)
                                                     name:NOTIFICATION_POST_PUBLISHED
                                                   object:nil];
    });
    return sharedInstance;
}

-(void)loadUserChannelsWithCompletionBlock:(void(^)())block {
    [Channel_BackendObject getChannelsForUser:[PFUser currentUser] withCompletionBlock:^(NSMutableArray * channels) {
        if (channels.count > 0) {
			self.userChannel = channels[0];
			if (!self.userChannel.name.length) {
				[self.userChannel changeTitle:[self getDefaultBlogName]];
				self.userChannel.defaultBlogName = YES;
			}
			//todo:
			if (!self.userChannel.parseChannelObject[CHANNEL_CREATOR_NAME_KEY]) {
				[self.userChannel.parseChannelObject setObject:[PFUser currentUser][VERBATM_USER_NAME_KEY] forKey:CHANNEL_CREATOR_NAME_KEY];
				[self.userChannel.parseChannelObject saveInBackground];
			}
			block();
		} else {
			// First time logging in - create a new channel
			NSString *defaultBlogName = [self getDefaultBlogName];
			[Channel_BackendObject createChannelWithName:defaultBlogName andCompletionBlock:^(PFObject *channelObj) {
				self.userChannel = [[Channel alloc] initWithChannelName:defaultBlogName andParseChannelObject:channelObj
																					   andChannelCreator:[PFUser currentUser]];
				self.userChannel.defaultBlogName = YES;
				[self.userChannel getChannelsFollowingWithCompletionBlock:^{
					block();
				}];
			}];
		}
    }];
}

-(NSString*) getDefaultBlogName {
	NSString *userName = [PFUser currentUser][VERBATM_USER_NAME_KEY];
	return [userName stringByAppendingString:@"'s Blog"];
}

-(Channel *) getUserChannel {
    return self.userChannel;
}

-(BOOL) userFollowsChannel:(Channel*)channel {
	return [self.userChannel checkIfList:self.userChannel.channelsUserFollowing ContainsObject:channel.parseChannelObject];
}

-(void)reloadUserChannels {
    [Channel_BackendObject getChannelsForUser:[PFUser currentUser] withCompletionBlock:^(NSMutableArray * channels) {
        if (channels.count > 0) self.userChannel = channels[0];
    }];

}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
