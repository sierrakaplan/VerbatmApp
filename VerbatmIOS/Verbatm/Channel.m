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
@property (nonatomic, readwrite) PFObject * parseChannelObject;//name of user that owns the channel TODO--SET THIS OBJECT


@end

@implementation Channel
-(instancetype) initWithChannelName:(NSString *) channelName numberOfFollowers:(NSNumber *) numberOfFollowers
              andParseChannelObject:(PFObject *) parseChannelObject{
    
    self = [super init];
    if(self){
        self.name = channelName;
        self.numberOfFollowers = numberOfFollowers;
        self.parseChannelObject = (parseChannelObject) ? parseChannelObject : NULL;
    }
    return self;
}

@end
