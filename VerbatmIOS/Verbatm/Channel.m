//
//  Channel.m
//  Verbatm
//
//  Created by Iain Usiri on 12/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "Channel.h"
#import "Channel_BackendObject.h"
#import "Follow_BackendManager.h"
#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>
#import <PromiseKit/PromiseKit.h>
#import "PostPublisher.h"
#import <PromiseKit/PromiseKit.h>
#import "SizesAndPositions.h"
#import "UtilityFunctions.h"

@interface Channel ()

@property (nonatomic, readwrite) NSString * name;
@property (nonatomic, readwrite) NSString *blogDescription;
@property (nonatomic, readwrite) PFObject * parseChannelObject;
@property (nonatomic, readwrite) PFUser *channelCreator;

// Array of PFUsers
@property (nonatomic, readwrite) NSMutableArray *usersFollowingChannel;

// Array of Channel* objects
@property (nonatomic, readwrite) NSMutableArray *channelsUserFollowing;

@property (nonatomic) PostPublisher * mediaPublisher;

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
            self.blogDescription = parseChannelObject[CHANNEL_DESCRIPTION_KEY];
        }
        if (self.blogDescription == nil) {
            self.blogDescription = @"";
        }
    }
    return self;
}


-(NSString *)getCoverPhotoUrl{
    NSString * url = [self.parseChannelObject valueForKey:CHANNEL_COVER_PHOTO_URL];
    return url;
}

-(void)storeCoverPhoto:(UIImage *) coverPhoto{
    [Channel_BackendObject storeCoverPhoto:coverPhoto withParseChannelObject:self.parseChannelObject];
}

-(void)getImageDataFromImage:(UIImage *) profileImage withCompletionBlock:(void(^)(NSData*))block{
    NSData* imageData = UIImagePNGRepresentation(profileImage);
    block(imageData);
}

-(void)loadCoverPhotoWithCompletionBlock: (void(^)(UIImage*, NSData*))block{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString * url = [self.parseChannelObject valueForKey:CHANNEL_COVER_PHOTO_URL];
            if(url) {
                NSString *smallImageUrl = [UtilityFunctions addSuffixToPhotoUrl:url forSize: HALFSCREEN_IMAGE_SIZE];
                [[UtilityFunctions sharedInstance] loadCachedPhotoDataFromURL: [NSURL URLWithString: smallImageUrl]].then(^(NSData* data) {
                    if(data){
                        UIImage * photo = [UIImage imageWithData:data];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(photo, data);
                        });
                    } else {
                        block(nil, nil);
                    }
                });
            } else {
                block(nil, nil);
            }
    });
}

-(void) changeTitle:(NSString*)title {
	if (!title.length) return;
	self.name = title;
	self.parseChannelObject[CHANNEL_NAME_KEY] = title;
	[self.parseChannelObject saveInBackground];
}

-(void) changeTitle:(NSString*)title andDescription:(NSString*)description {
	if (!title.length) return;
	self.defaultBlogName = NO;
    self.name = title;
    self.blogDescription = description;
    self.parseChannelObject[CHANNEL_NAME_KEY] = title;
    self.parseChannelObject[CHANNEL_DESCRIPTION_KEY] = description;
    [self.parseChannelObject saveInBackground];
}

-(void) currentUserFollowsChannel:(BOOL) follows {
    PFUser *currentUser = [PFUser currentUser];
    if (follows) {
        if (![self.usersFollowingChannel containsObject:currentUser]) {
			NSMutableArray *newUsers = [NSMutableArray arrayWithArray: self.usersFollowingChannel];
			[newUsers addObject:currentUser];
			self.usersFollowingChannel = newUsers;
		}
    } else {
        if ([self.usersFollowingChannel containsObject:currentUser]) {
			NSMutableArray *newUsers = [NSMutableArray arrayWithArray: self.usersFollowingChannel];
			[newUsers removeObject:currentUser];
			self.usersFollowingChannel = newUsers;
		}
    }
}

-(void) updateLatestPostDate:(NSDate*)date {
	self.parseChannelObject[CHANNEL_LATEST_POST_DATE] = date;
	[self.parseChannelObject saveInBackground];
}

-(void)getChannelOwnerNameWithCompletionBlock:(void(^)(NSString *))block {
    if (!self.parseChannelObject) {
        block(@"");
        return;
    }
	NSString *name = self.parseChannelObject[CHANNEL_CREATOR_NAME_KEY];
	if (name && name.length > 0) {
		block (name);
		return;
	}
    [[self.parseChannelObject valueForKey:CHANNEL_CREATOR_KEY] fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        self.channelCreator = (PFUser*)object;
        [self.channelCreator fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            NSString * userName = [self.channelCreator valueForKey:VERBATM_USER_NAME_KEY];
            block(userName);
        }];
    }];
}

+(void)getChannelsForUserList:(NSArray *) userList andCompletionBlock:(void(^)(NSMutableArray *))block{
    NSMutableArray * userChannelPromises = [[NSMutableArray alloc] init];
    NSMutableArray * userChannelList = [[NSMutableArray alloc] init];
    for (PFUser * user in userList) {
        [userChannelPromises addObject:[AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
            [Channel_BackendObject getChannelsForUser:user withCompletionBlock:^(NSMutableArray * userChannels) {
                [userChannelList addObjectsFromArray:userChannels];
                resolve(nil);
            }];
        }]];
    }
    PMKWhen(userChannelPromises).then(^(id nothing) {
        block(userChannelList);
    });
}

-(void) getFollowersWithCompletionBlock:(void(^)(void))block {
	[Follow_BackendManager usersFollowingChannel:self withCompletionBlock:^(NSArray *users) {
		self.usersFollowingChannel = [[NSMutableArray alloc] initWithArray:users];
		self.parseChannelObject[CHANNEL_NUM_FOLLOWS] = [NSNumber numberWithInteger:users.count];
		[self.parseChannelObject saveInBackground];
		if(block) block();
	}];
}

-(void) getChannelsFollowingWithCompletionBlock:(void(^)(void))block {
	[Follow_BackendManager channelsUserFollowing: self.channelCreator withCompletionBlock:^(NSArray *channels) {
		self.channelsUserFollowing = [[NSMutableArray alloc] initWithArray: channels];
		self.parseChannelObject[CHANNEL_NUM_FOLLOWING] = [NSNumber numberWithInteger:channels.count];
		[self.parseChannelObject saveInBackground];
		if(block) block();
	}];
}

-(BOOL)channelBelongsToCurrentUser {
    if (!self.parseChannelObject) return false;
    return ([[PFUser currentUser].objectId isEqualToString:self.channelCreator.objectId]);
}

-(void)addParseChannelObject:(PFObject *)object andChannelCreator:(PFUser *)channelCreator{
    self.parseChannelObject = object;
    self.channelCreator = channelCreator;
    self.blogDescription = object[CHANNEL_DESCRIPTION_KEY];
}


-(void)registerFollowingNewChannel:(Channel *)channel{
    if(channel){
		Channel* listChannel = [UtilityFunctions checkIfChannelList:self.channelsUserFollowing containsChannel:channel];
        if(!listChannel){
            [self.channelsUserFollowing addObject:channel];
        }
    }
}

-(void)registerStopedFollowingChannel:(Channel *)channel{

    if(channel){
        Channel* listChannel = [UtilityFunctions checkIfChannelList:self.channelsUserFollowing containsChannel:channel];
        if(listChannel){
            [self.channelsUserFollowing removeObject:listChannel];
        }
    }
}




@end
