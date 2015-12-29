//
//  Channel.m
//  Verbatm
//
//  Created by Iain Usiri on 12/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "Channel.h"

@interface Channel ()
@property (nonatomic, readwrite) NSString * name;
@property (nonatomic, readwrite) NSNumber * numberOfFollowers;
@property (nonatomic, readwrite) NSString * userName;//name of user that owns the channel


@end

@implementation Channel
-(instancetype) initWithChannelName:(NSString *) channelName numberOfFollowers:(NSNumber *) numberOfFollowers andUserName:(NSString *) username{
    
    self = [super init];
    if(self){
        self.name = channelName;
        self.numberOfFollowers = numberOfFollowers;
        self.userName = username;
    }
    return self;
}

@end
