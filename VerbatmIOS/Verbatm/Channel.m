//
//  Channel.m
//  Verbatm
//
//  Created by Iain Usiri on 12/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "Channel.h"
#import "Follow_BackendManager.h"
#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>
#import "PostPublisher.h"
#import <PromiseKit/PromiseKit.h>
#import "UtilityFunctions.h"

@interface Channel ()

@property (nonatomic, readwrite) NSString * name;
@property (nonatomic, readwrite) NSString *blogDescription;
@property (nonatomic, readwrite) PFObject * parseChannelObject;
@property (nonatomic, readwrite) PFUser *channelCreator;
@property (nonatomic, readwrite) NSMutableArray *usersFollowingChannel;
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

-(void) changeTitle:(NSString*)title andDescription:(NSString*)description {
	self.name = title;
	self.blogDescription = description;
	self.parseChannelObject[CHANNEL_NAME_KEY] = title;
	self.parseChannelObject[CHANNEL_DESCRIPTION_KEY] = description;
	[self.parseChannelObject saveInBackground];
}

-(void) currentUserFollowsChannel:(BOOL) follows {
	PFUser *currentUser = [PFUser currentUser];
	if (follows) {
		if (![self.usersFollowingChannel containsObject:currentUser]) [self.usersFollowingChannel addObject:currentUser];
	} else {
		if ([self.usersFollowingChannel containsObject:currentUser]) [self.usersFollowingChannel removeObject:currentUser];
	}
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

-(void) getFollowersAndFollowingWithCompletionBlock:(void(^)(void))block {
	self.usersFollowingChannel = nil;
	self.channelsUserFollowing = nil;
	[Follow_BackendManager usersFollowingChannel:self withCompletionBlock:^(NSArray *users) {
		self.usersFollowingChannel = [[NSMutableArray alloc] initWithArray:users];
		if (self.channelsUserFollowing) block();
	}];

	[Follow_BackendManager channelsUserFollowing:self.channelCreator withCompletionBlock:^(NSArray *channels) {
		self.channelsUserFollowing = [[NSMutableArray alloc] initWithArray: channels];
		if (self.usersFollowingChannel) block();
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



-(void)storeCoverPhoto:(UIImage *) coverPhoto{
    self.mediaPublisher = [[PostPublisher alloc] init];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self getImageDataFromImage:coverPhoto withCompletionBlock:^(NSData * imageData) {
            [self.mediaPublisher storeImage:imageData].then(^(id result) {
                if(result){
                    NSString *blobstoreUrl = (NSString*) result;
                    if (![blobstoreUrl hasSuffix:@"=s0"]) {
                        blobstoreUrl = [blobstoreUrl stringByAppendingString:@"=s0"];
                    }
                    [self.parseChannelObject setValue:blobstoreUrl forKey:CHANNEL_COVER_PHOTO_URL];
                    [self.parseChannelObject saveInBackground];
                }
            });
        }];
    });
}
                                                           
-(void)getImageDataFromImage:(UIImage *) profileImage withCompletionBlock:(void(^)(NSData*))block{
    NSData* imageData = UIImagePNGRepresentation(profileImage);
    block(imageData);
}
                                                           

-(void)loadCoverPhotoWithCompletionBlock: (void(^)(UIImage*))block{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString * url = [self.parseChannelObject valueForKey:CHANNEL_COVER_PHOTO_URL];
            if(url){
                
           [UtilityFunctions loadCachedPhotoDataFromURL: [NSURL URLWithString: url]].then(^(NSData* data) {
                    if(data){
                        UIImage * photo = [UIImage imageWithData:data];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(photo);
                        });
                    }else{
                        block(nil);
                    }
                });
                
                
            } else {
                
                block(nil);
            
            }
    });
}

@end
