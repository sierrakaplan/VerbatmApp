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
//this definition must match the name of the lower NSDate value
#define CHANNEL_MOST_RECENT_POST_DATE_NAME @"dateOfMostRecentChannelPost"
@property (nonatomic, readonly) NSDate * dateOfMostRecentChannelPost;
@property (nonatomic, readonly) NSString *channelName;
@property (nonatomic, readonly) NSString *userName;
@property (nonatomic, readonly) NSString *blogDescription;
@property (nonatomic, readonly) PFObject *parseChannelObject;
@property (nonatomic, readonly) PFUser *channelCreator;
@property (nonatomic) PFObject *followObject;
@property (nonatomic, readonly) NSMutableArray *usersFollowingChannel;
@property (nonatomic, readonly) NSMutableArray *channelsUserFollowing;
// The follow objects corresponding with channelsUserFollowing

// The follow object represents the current user's follow relationship with this channel
// Pass nil if current user's channel or if none exists (not following)
-(instancetype) initWithChannelName:(NSString *) channelName
			  andParseChannelObject:(PFObject *) parseChannelObject
				  andChannelCreator:(PFUser *) channelCreator
					andFollowObject:(PFObject*) followObject;

-(void) changeTitle:(NSString*)title;
 
-(void) changeTitle:(NSString*)title andDescription:(NSString*)description;

// Updates if the current user follows this channel
-(void) currentUserFollowChannel:(BOOL) follows;

-(void) updateLatestPostDate:(NSDate*)date;

-(void) changeChannelOwnerName:(NSString*)newName;

-(void) getChannelOwnerNameWithCompletionBlock:(void(^)(NSString *))block;

-(void) getFollowersWithCompletionBlock:(void(^)(void))block;

-(void) getChannelsFollowingWithCompletionBlock:(void(^)(void))block;

-(BOOL) channelBelongsToCurrentUser;

-(void) addParseChannelObject:(PFObject *)object andChannelCreator:(PFUser *)channelCreator;

+(void) getChannelsForUserList:(NSArray *) userList andCompletionBlock:(void(^)(NSMutableArray *))block;

-(void) storeCoverPhoto:(UIImage *) coverPhoto;

-(void) loadCoverPhotoWithCompletionBlock: (void(^)(UIImage*, NSData*))block;

-(NSString *)getCoverPhotoUrl;

-(void)registerFollowingNewChannel:(Channel *)channel;

-(void)registerStopedFollowingChannel:(Channel *)channel;

-(void) updatePostDeleted:(PFObject*)post;
-(void) resetLatestPostInfo;
@end
