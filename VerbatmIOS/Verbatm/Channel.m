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
@property (nonatomic) PFObject *channelCreator;


@end

@implementation Channel
-(instancetype) initWithChannelName:(NSString *) channelName
              andParseChannelObject:(PFObject *) parseChannelObject{
    
    self = [super init];
    if(self){
        self.name = channelName;
        self.parseChannelObject = (parseChannelObject) ? parseChannelObject : NULL;
		if (self.parseChannelObject) {
			[[self.parseChannelObject valueForKey:CHANNEL_CREATOR_KEY] fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
				self.channelCreator = object;
			}];
		}
    }
    return self;
}

-(NSString *)getChannelOwnerUserName {
	if (!self.parseChannelObject) return nil;
	if (!self.channelCreator) self.channelCreator = [[self.parseChannelObject valueForKey:CHANNEL_CREATOR_KEY] fetchIfNeeded];
    NSString * userName = [self.channelCreator valueForKey:VERBATM_USER_NAME_KEY];
    return userName;
}

-(BOOL)channelBelongsToCurrentUser {
	if (!self.parseChannelObject) return nil;
	if (!self.channelCreator) self.channelCreator = [[self.parseChannelObject valueForKey:CHANNEL_CREATOR_KEY] fetchIfNeeded];
    return ([[PFUser currentUser].objectId isEqualToString:self.channelCreator.objectId]);
}

-(void)addParseChannelObject:(PFObject *)object {
	self.parseChannelObject = object;
}

@end
