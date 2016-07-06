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

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *blogDescription;
@property (nonatomic, readonly) PFObject *parseChannelObject;
@property (nonatomic, readonly) PFUser *channelCreator;
@property (nonatomic, readonly) NSMutableArray *usersFollowingChannel;
@property (nonatomic, readonly) NSMutableArray *channelsUserFollowing;


-(instancetype) initWithChannelName:(NSString *) channelName
			  andParseChannelObject:(PFObject *) parseChannelObject
				  andChannelCreator:(PFUser *) channelCreator;

-(void) changeTitle:(NSString*)title andDescription:(NSString*)description;

-(void) currentUserFollowsChannel:(BOOL) follows;

-(void) getChannelOwnerNameWithCompletionBlock:(void(^)(NSString *))block;

// Returns when both usersFollowingChannel and channelsUserFollowing are filled in
-(void) getFollowersAndFollowingWithCompletionBlock:(void(^)(void))block;

-(BOOL)channelBelongsToCurrentUser;

-(void)addParseChannelObject:(PFObject *)object andChannelCreator:(PFUser *)channelCreator;


+(void)getChannelsForUserList:(NSMutableArray *) userList andCompletionBlock:(void(^)(NSMutableArray *))block;


-(void)storeCoverPhoto:(UIImage *) coverPhoto;

-(void)loadCoverPhotoWithCompletionBlock: (void(^)(UIImage*))block;

-(BOOL)checkIfList:(NSArray *) list ContainsObject:(PFObject *) object;

@end
