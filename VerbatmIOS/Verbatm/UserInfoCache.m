//
//  UserInfoCache.m
//  Verbatm
//
//  Created by Iain Usiri on 3/21/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "UserInfoCache.h"
#import <Parse/PFUser.h>
#import "Channel_BackendObject.h"
#import "Notifications.h"
/*
 Shared instance that simplifies fetching ubiquitous user information. 
 For example we use it now to cache the users channels - but can be used 
 to store preferences etc.
 
 */

@interface UserInfoCache ()
@property (nonatomic) NSMutableArray * userChannels;
@property (nonatomic) NSUInteger currentChannelIndex;
@property (nonatomic) NSInteger attemptedIndex; //if user sets index before channels are reloaded
@end

@implementation UserInfoCache

+(instancetype)sharedInstance{
    static UserInfoCache *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UserInfoCache alloc] init];
        [sharedInstance setCurrentChannelIndex:0];
		sharedInstance.attemptedIndex = -1;
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance
                                                 selector:@selector(reloadUserChannels)
                                                     name:NOTIFICATION_POST_PUBLISHED
                                                   object:nil];
    });
    return sharedInstance;
}

-(void)loadUserChannelsWithCompletionBlock:(void(^)())block {
    [Channel_BackendObject getChannelsForUser:[PFUser currentUser] withCompletionBlock:^(NSMutableArray * channels) {
        self.userChannels = channels;
		if (self.attemptedIndex < self.userChannels.count && self.attemptedIndex >= 0) {
			self.currentChannelIndex = self.attemptedIndex;
			self.attemptedIndex = -1;
		}
        block();
    }];
}

-(void)storeUserChannels:(NSMutableArray *) channels{
    self.userChannels = channels;
}

-(NSMutableArray *) getUserChannels{
    return self.userChannels;
}

-(NSUInteger) currentChannelViewedIndex{
    return self.currentChannelIndex;
}
-(void) setCurrentChannelIndex:(NSUInteger)index{
    if(index < self.userChannels.count){
        _currentChannelIndex = index;
    } else {
		self.attemptedIndex = index;
	}
}

-(void)reloadUserChannels{
    [Channel_BackendObject getChannelsForUser:[PFUser currentUser] withCompletionBlock:^(NSMutableArray * channels) {
        self.userChannels = channels;
    }];

}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
