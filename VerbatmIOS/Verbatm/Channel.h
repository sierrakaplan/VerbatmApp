//
//  Channel.h
//  Verbatm
//
//  Created by Iain Usiri on 12/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/PFObject.h>
@interface Channel : NSObject
@property (nonatomic) id userId;//identifier for user that owns this channel
@property (nonatomic, readonly) NSString * name;
@property (nonatomic, readonly) NSNumber * numberOfFollowers;
@property (nonatomic, readonly) NSString * userName;//name of user that owns the channel
@property (nonatomic, readonly) PFObject * parseChannelObject;//name of user that owns the channel TODO--SET THIS OBJECT


/*Channels should not be created by anything but the Channel_BackendObject class.*/

-(instancetype) initWithChannelName:(NSString *) channelName numberOfFollowers:(NSNumber *) numberOfFollowers andUserName:(NSString *) username andParseChannelObject:(PFObject *) parseChannelObject;
@end
