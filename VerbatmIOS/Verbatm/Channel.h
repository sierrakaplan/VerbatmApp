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

// Set to true if the user hasn't added their own blog yet
@property (nonatomic) BOOL defaultBlogName;
@property (nonatomic) NSDate *latestPostDate;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *blogDescription;
@property (nonatomic, readonly) PFObject *parseChannelObject;
@property (nonatomic, readonly) PFUser *channelCreator;
@property (nonatomic, readonly) NSMutableArray *usersFollowingChannel;
@property (nonatomic, readonly) NSMutableArray *channelsUserFollowing;


-(instancetype) initWithChannelName:(NSString *) channelName
			  andParseChannelObject:(PFObject *) parseChannelObject
				  andChannelCreator:(PFUser *) channelCreator;

-(void) changeTitle:(NSString*)title;
 
-(void) changeTitle:(NSString*)title andDescription:(NSString*)description;

-(void) currentUserFollowsChannel:(BOOL) follows;

-(void) updateLatestPostDate:(NSDate*)date;

-(void) getChannelOwnerNameWithCompletionBlock:(void(^)(NSString *))block;

-(void) getFollowersWithCompletionBlock:(void(^)(void))block;

-(void) getChannelsFollowingWithCompletionBlock:(void(^)(void))block;

-(BOOL)channelBelongsToCurrentUser;

-(void) addParseChannelObject:(PFObject *)object andChannelCreator:(PFUser *)channelCreator;


+(void) getChannelsForUserList:(NSArray *) userList andCompletionBlock:(void(^)(NSMutableArray *))block;


-(void) storeCoverPhoto:(UIImage *) coverPhoto;

-(void)loadCoverPhotoWithCompletionBlock: (void(^)(UIImage*, NSData*))block;

-(NSString *)getCoverPhotoUrl;

-(void)registerFollowingNewChannel:(Channel *)channel;

-(void)registerStopedFollowingChannel:(Channel *)channel;

-(void) updatePostDeleted:(PFObject*)post;

@end
