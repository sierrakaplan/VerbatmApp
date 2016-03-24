//
//  Channel.m
//  Verbatm
//
//  Created by Iain Usiri on 12/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "Channel.h"
#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>
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

-(NSString *)getChannelOwnerUserName{
    PFObject * user = [[self.parseChannelObject valueForKey:CHANNEL_CREATOR_KEY] fetchIfNeeded];
    NSString * userName = [user valueForKey:USER_USER_NAME_KEY];
    return userName;
}

-(BOOL)channelBelongsToCurrentUser{
    PFObject * user = [[self.parseChannelObject valueForKey:CHANNEL_CREATOR_KEY] fetchIfNeeded];
    return ([[PFUser currentUser].objectId isEqualToString:user.objectId]);
}

@end
