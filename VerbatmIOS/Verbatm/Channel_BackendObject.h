//
//  Channel_BackendObject.h
//  Verbatm
//
//  Created by Iain Usiri on 1/27/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/PFUser.h>
#import "Channel.h"
@interface Channel_BackendObject : NSObject
+(Channel *) createChannelWithName:(NSString *) channelName;

//this will return null of the channel already exists
//will return the newly created channel otherwise
+(Channel *) createPostFromPinchViews: (NSArray*) pinchViews toChannel: (Channel *) channel;


+(NSMutableArray *) getChannelsForUser:(PFUser *) user;
@end
