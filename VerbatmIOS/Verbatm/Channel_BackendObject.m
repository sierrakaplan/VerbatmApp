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
#import "Post_BackendObject.h"
#import "ParseBackendKeys.h"
#import <Parse/PFQuery.h>
#import "UserManager.h"
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

-(Channel *) createChannelWithName:(NSString *) channelName {
    
   return [self createChannelWithName:channelName andCompletionBlock:NULL];
    
}

//private create channel function
-(Channel *)createChannelWithName:(NSString *)channelName andCompletionBlock:(void(^)(Channel *))block {
    PFUser * ourUser = [PFUser currentUser];
    if(ourUser){
    
        PFObject * newChannelObject = [PFObject objectWithClassName:CHANNEL_PFCLASS_KEY];
        [newChannelObject setObject:channelName forKey:CHANNEL_NAME_KEY];
        [newChannelObject setObject:[NSNumber numberWithInt:0] forKey:CHANNEL_NUM_FOLLOWERS_KEY];
        [newChannelObject setObject:[NSNumber numberWithInt:0] forKey:CHANNEL_NUM_POSTS_KEY];
        [newChannelObject setObject:[PFUser currentUser] forKey:CHANNEL_CREATOR_KEY];

        
        Channel * channel = [[Channel alloc] initWithChannelName:channelName
                                                        numberOfFollowers:[NSNumber numberWithInt:0]
                                                              andParseChannelObject:newChannelObject];
        
        [newChannelObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded){
                
                [[UserInfoCache sharedInstance] loadUserChannelsWithCompletionBlock:nil];
                
                if(block)block(channel);
            }
        }];
 
        return channel;
    }
    return nil;
    
}

//returns channel when we create a new one
-(Channel *) createPostFromPinchViews: (NSArray*) pinchViews toChannel: (Channel *) channel
                   withCompletionBlock:(void(^)(PFObject *))block {
    
    if(channel.parseChannelObject){
        Post_BackendObject * newPost = [[Post_BackendObject alloc]init];
        [self.ourPosts addObject:newPost];
       PFObject * parsePostObject = [newPost createPostFromPinchViews:pinchViews toChannel:channel];
         block(parsePostObject);
        return NULL;
    }else{
       return  [self createChannelWithName:channel.name andCompletionBlock:^(Channel * channelObject){
                    Post_BackendObject * newPost = [[Post_BackendObject alloc]init];
                    [self.ourPosts addObject:newPost];
               PFObject * parsePostObject = [newPost createPostFromPinchViews:pinchViews toChannel:channelObject];
           block(parsePostObject);
        }];
    }
}



+(void) getChannelsForUser:(PFUser *) user withCompletionBlock:(void(^)(NSMutableArray *))completionBlock{
    
    if(user){
        PFQuery * userChannelQuery = [PFQuery queryWithClassName:CHANNEL_PFCLASS_KEY];
        [userChannelQuery whereKey:CHANNEL_CREATOR_KEY equalTo:user];
        
        [userChannelQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                             NSError * _Nullable error) {
            NSMutableArray * finalChannelObjects = [[NSMutableArray alloc] init];
            if(objects && !error){
                for(PFObject * parseChannelObject in objects){
                    
                    NSString * channelName  = [parseChannelObject valueForKey:CHANNEL_NAME_KEY];
                    NSNumber * numberOfFollowers = [parseChannelObject valueForKey:CHANNEL_NUM_FOLLOWERS_KEY];
                    Channel * verbatmChannelObject = [[Channel alloc] initWithChannelName:channelName numberOfFollowers:numberOfFollowers andParseChannelObject:parseChannelObject];
                    [finalChannelObjects addObject:verbatmChannelObject];
                }
            }
            completionBlock(finalChannelObjects);
        }];
    }else{
        completionBlock([[NSMutableArray alloc] init]);
    }
}

//gets all the channels on V except the provided user.
//often this will be the current user
+(void) getAllChannelsButNoneForUser:(PFUser *) user withCompletionBlock:(void(^)(NSMutableArray *))completionBlock{
    PFQuery * userChannelQuery = [PFQuery queryWithClassName:CHANNEL_PFCLASS_KEY];
    [userChannelQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(objects.count){
            NSMutableArray * finalObjects = [[NSMutableArray alloc] init];
            for(PFObject * parseChannelObject in objects){
                if([parseChannelObject valueForKey:CHANNEL_CREATOR_KEY] !=
                   [PFUser currentUser]){
                    NSString * channelName  = [parseChannelObject valueForKey:CHANNEL_NAME_KEY];
                    NSNumber * numberOfFollowers = [parseChannelObject valueForKey:CHANNEL_NUM_FOLLOWERS_KEY];
                    //making sure we have info on the owner of the channel for our list
                    [[parseChannelObject valueForKey:CHANNEL_CREATOR_KEY] fetchIfNeededInBackground];
                    Channel * verbatmChannelObject = [[Channel alloc] initWithChannelName:channelName numberOfFollowers:numberOfFollowers andParseChannelObject:parseChannelObject];
                    [finalObjects addObject:verbatmChannelObject];
                }
            }
            completionBlock(finalObjects);
        }
    }];
}


//gets all channels on Verbatm including the current user
+(void) getAllChannelsWithCompletionBlock:(void(^)(NSMutableArray *))completionBlock{
    
}







@end
