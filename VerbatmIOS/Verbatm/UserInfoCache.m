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
			[self.userChannel.parseChannelObject setObject:[PFUser currentUser][VERBATM_USER_NAME_KEY] forKey:CHANNEL_CREATOR_NAME_KEY];
			[self.userChannel.parseChannelObject saveInBackground];
			block();
		} else {
			// First time logging in - create a new channel
			[Channel_BackendObject createChannelWithName:@"" andCompletionBlock:^(PFObject *channelObj) {
				self.userChannel = [[Channel alloc] initWithChannelName:@"" andParseChannelObject:channelObj
																					   andChannelCreator:[PFUser currentUser]];
				block();
			}];
		}
    }];
}

-(Channel *) getUserChannel {
    return self.userChannel;
}

-(void)reloadUserChannels{
    [Channel_BackendObject getChannelsForUser:[PFUser currentUser] withCompletionBlock:^(NSMutableArray * channels) {
        if (channels.count > 0) self.userChannel = channels[0];
    }];

}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
