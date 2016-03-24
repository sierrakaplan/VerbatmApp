//
//  UserInfoCache.h
//  Verbatm
//
//  Created by Iain Usiri on 3/21/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoCache : NSObject
+(instancetype)sharedInstance;
-(void)loadUserChannelsWithCompletionBlock:(void(^)())block;
-(void)storeUserChannels:(NSMutableArray *) channels;
-(NSMutableArray *) getUserChannels;

//the index of the current channel selected by the user
//set on tab selection in the profile
-(NSUInteger) currentChannelViewedIndex;
-(void) setCurrentChannelIndex:(NSUInteger)index;
@end
