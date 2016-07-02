//
//  Channel_BackendObject.m
//  Verbatm
//
//  Created by Iain Usiri on 1/27/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

/*
 Manges creating channel objects and saving them as well as saving posts to channels
 */

#import "Channel_BackendObject.h"
#import "Channel.h"

#import "PostPublisher.h"
#import "Post_BackendObject.h"
#import "ParseBackendKeys.h"
#import <Parse/PFQuery.h>

#import "UserInfoCache.h"

@interface Channel_BackendObject ()
@property (nonatomic) NSMutableArray * ourPosts;
@end

@implementation Channel_BackendObject

-(instancetype)init{
	self = [super init];
	if(self){
		self.ourPosts = [[NSMutableArray alloc] init];
	}
	return self;
}

+(void)createChannelWithName:(NSString *)channelName andCompletionBlock:(void(^)(PFObject *))block {
	PFUser * ourUser = [PFUser currentUser];
	if(ourUser){
		PFObject * newChannelObject = [PFObject objectWithClassName:CHANNEL_PFCLASS_KEY];
		[newChannelObject setObject:channelName forKey:CHANNEL_NAME_KEY];
		[newChannelObject setObject:[NSNumber numberWithInteger:0] forKey:CHANNEL_NUM_FOLLOWS];
		[newChannelObject setObject:[PFUser currentUser] forKey:CHANNEL_CREATOR_KEY];
		[newChannelObject setObject:[PFUser currentUser][VERBATM_USER_NAME_KEY] forKey:CHANNEL_CREATOR_NAME_KEY];
		[newChannelObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
			if(succeeded){
				block(newChannelObject);
			} else {
				block(nil);
			}
		}];
	} else {
		block (nil);
	}
}

//returns channel when we create a new one
-(void) createPostFromPinchViews: (NSArray*) pinchViews toChannel: (Channel *) channel
			 withCompletionBlock:(void(^)(PFObject *)) block {
	if(channel.parseChannelObject){
		block ([self createPostFromPinchViews:pinchViews andChannel:channel]);
	} else {
		[Channel_BackendObject createChannelWithName:channel.name andCompletionBlock:^(PFObject* channelObject){
			if (!channelObject) {
				block (nil);
			} else {
				[channel addParseChannelObject:channelObject andChannelCreator:[PFUser currentUser]];
				block ([self createPostFromPinchViews:pinchViews andChannel:channel]);
			}
		}];
	}
}

-(PFObject *) createPostFromPinchViews:(NSArray*)pinchViews andChannel:(Channel*)channel {
	Post_BackendObject * newPost = [[Post_BackendObject alloc]init];
	[self.ourPosts addObject:newPost];
	return [newPost createPostFromPinchViews:pinchViews toChannel:channel];
}

+ (void) getChannelsForUser:(PFUser *) user withCompletionBlock:(void(^)(NSMutableArray *))completionBlock {
	if (!user) {
		completionBlock (nil);
		return;
	}

    [user fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFQuery * userChannelQuery = [PFQuery queryWithClassName:CHANNEL_PFCLASS_KEY];
        [userChannelQuery whereKey:CHANNEL_CREATOR_KEY equalTo:user];
        [userChannelQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                             NSError * _Nullable error) {
            NSMutableArray * finalChannelObjects = [[NSMutableArray alloc] init];
            if(objects && !error) {
                for(PFObject *parseChannelObject in objects){
                    NSString * channelName  = [parseChannelObject valueForKey:CHANNEL_NAME_KEY];
                    // get number of follows from follow objects
                    Channel * verbatmChannelObject = [[Channel alloc] initWithChannelName:channelName
                                                                    andParseChannelObject:parseChannelObject
                                                                        andChannelCreator:user];
                    [finalChannelObjects addObject:verbatmChannelObject];
                }
            }
            completionBlock(finalChannelObjects);
        }];
    }];
}

+ (void)storeCoverPhoto:(UIImage *) coverPhoto withParseChannelObject:(PFObject *) channel{
    PostPublisher * __block mediaPublisher = [[PostPublisher alloc] init];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self getImageDataFromImage:coverPhoto withCompletionBlock:^(NSData * imageData) {
			//todo: get actual file name for cover photo? 
            [mediaPublisher storeImageWithName:@"CoverPhoto.png" andData:imageData].then(^(id result) {
                if(result){
                    NSString *blobstoreUrl = (NSString*) result;
                    if (![blobstoreUrl hasSuffix:@"=s0"]) {
                        blobstoreUrl = [blobstoreUrl stringByAppendingString:@"=s0"];
                    }
                    [channel setValue:blobstoreUrl forKey:CHANNEL_COVER_PHOTO_URL];
                    [channel saveInBackground];
                }
            });
        }];
    });
}

+(void)getImageDataFromImage:(UIImage *) profileImage withCompletionBlock:(void(^)(NSData*))block{
    NSData* imageData = UIImagePNGRepresentation(profileImage);
    block(imageData);
}


+ (void) getAllChannelsWithCompletionBlock:(void(^)(NSMutableArray *))completionBlock {
    
    PFQuery * userChannelQuery = [PFQuery queryWithClassName:CHANNEL_PFCLASS_KEY];
    [userChannelQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                         NSError * _Nullable error) {
        NSMutableArray * finalChannelObjects = [[NSMutableArray alloc] init];
        if(objects && !error) {
            for(PFObject * parseChannelObject in objects){
                NSString * channelName  = [parseChannelObject valueForKey:CHANNEL_NAME_KEY];
                // get number of follows from follow objects
                    Channel * verbatmChannelObject = [[Channel alloc] initWithChannelName:channelName
                                                                    andParseChannelObject:parseChannelObject
                                                                        andChannelCreator:[PFUser currentUser]];
                    [finalChannelObjects addObject:verbatmChannelObject];
            }
        }
        completionBlock(finalChannelObjects);
    }];
}

@end
