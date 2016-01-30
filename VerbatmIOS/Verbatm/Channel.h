//
//  Channel.h
//  Verbatm
//
//  Created by Iain Usiri on 12/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/PFObject.h>


/*Channels should not be created by anything but the Channel_BackendObject class.*/

@interface Channel : NSObject
@property (nonatomic) id userId;//identifier for user that owns this channel
@property (nonatomic, readonly) NSString * name;
@property (nonatomic, readonly) NSNumber * numberOfFollowers;
@property (nonatomic, readonly) PFObject * parseChannelObject;


-(instancetype) initWithChannelName:(NSString *) channelName numberOfFollowers:(NSNumber *) numberOfFollowers andParseChannelObject:(PFObject *) parseChannelObject;
@end