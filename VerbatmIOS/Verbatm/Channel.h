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

@property (nonatomic, readonly) NSString * name;
@property (nonatomic, readonly) PFObject * parseChannelObject;
@property (nonatomic, readonly) PFUser *channelCreator;


-(instancetype) initWithChannelName:(NSString *) channelName
			  andParseChannelObject:(PFObject *) parseChannelObject
				  andChannelCreator:(PFUser *) channelCreator;

-(void)getChannelOwnerNameWithCompletionBlock:(void(^)(NSString *))block;

-(BOOL)channelBelongsToCurrentUser;

-(void)addParseChannelObject:(PFObject *)object andChannelCreator:(PFUser *)channelCreator;
@end
