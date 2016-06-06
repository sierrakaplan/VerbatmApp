//
//  UserInfoCache.h
//  Verbatm
//
//  Created by Iain Usiri on 3/21/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel.h"
#import <Foundation/Foundation.h>

@interface UserInfoCache : NSObject

+(instancetype)sharedInstance;

-(void)loadUserChannelsWithCompletionBlock:(void(^)())block;
-(Channel *) getUserChannel;

@end

