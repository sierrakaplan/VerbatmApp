//
//  Channel.h
//  Verbatm
//
//  Created by Iain Usiri on 12/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Channel : NSObject
@property (nonatomic) id userId;//identifier for user that owns this channel
@property (nonatomic, readonly) NSString * name;
@property (nonatomic, readonly) NSNumber * numberOfFollowers;
@property (nonatomic, readonly) NSString * userName;//name of user that owns the channel
-(instancetype) initWithChannelName:(NSString *) channelName numberOfFollowers:(NSNumber *) numberOfFollowers andUserName:(NSString *) username;
@end
