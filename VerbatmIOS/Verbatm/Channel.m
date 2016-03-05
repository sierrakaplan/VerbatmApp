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
@property (nonatomic, readwrite) PFObject * parseChannelObject;


@end

@implementation Channel
-(instancetype) initWithChannelName:(NSString *) channelName
              andParseChannelObject:(PFObject *) parseChannelObject{
    
    self = [super init];
    if(self){
        self.name = channelName;
        self.parseChannelObject = (parseChannelObject) ? parseChannelObject : NULL;
    }
    return self;
}

@end
