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
@property (nonatomic, readwrite) PFUser *channelCreator;


@end

@implementation Channel
-(instancetype) initWithChannelName:(NSString *) channelName
              andParseChannelObject:(PFObject *) parseChannelObject
				  andChannelCreator:(PFUser *) channelCreator {
    
    self = [super init];
    if(self){
        self.name = channelName;
		if (parseChannelObject) {
			[self addParseChannelObject:parseChannelObject andChannelCreator:channelCreator];
		}
    }
    return self;
}

-(void)getChannelOwnerNameWithCompletionBlock:(void(^)(NSString *))block {
	if (!self.parseChannelObject) {
		block(@"");
		return;
	}
	if (!self.channelCreator) {
		[[self.parseChannelObject valueForKey:CHANNEL_CREATOR_KEY] fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
			self.channelCreator = (PFUser*)object;
			[self.channelCreator fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
				NSString * userName = [self.channelCreator valueForKey:VERBATM_USER_NAME_KEY];
				block(userName);
			}];
		}];
	} else {
		[self.channelCreator fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
			NSString * userName = [self.channelCreator valueForKey:VERBATM_USER_NAME_KEY];
			block(userName);
		}];
	}
}

-(BOOL)channelBelongsToCurrentUser {
	if (!self.parseChannelObject) return false;
	if (!self.channelCreator) self.channelCreator = [[self.parseChannelObject valueForKey:CHANNEL_CREATOR_KEY] fetchIfNeeded];
	[self.channelCreator fetchIfNeeded];
    return ([[PFUser currentUser].objectId isEqualToString:self.channelCreator.objectId]);
}

-(void)addParseChannelObject:(PFObject *)object andChannelCreator:(PFUser *)channelCreator{
	self.parseChannelObject = object;
	self.channelCreator = channelCreator;
}

@end
