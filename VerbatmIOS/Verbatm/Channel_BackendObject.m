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
        
        if(block){
            [newChannelObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded){
                    if(block)block(channel);
                }
            }];
        }else{
            [newChannelObject saveInBackground];
        }
        return channel;
    }
    
    [[UserManager sharedInstance] logOutUser];
    
    return nil;
    
}

//returns channel when we create a new one
-(Channel *) createPostFromPinchViews: (NSArray*) pinchViews toChannel: (Channel *) channel{
    
    if(channel.parseChannelObject){
        
        Post_BackendObject * newPost = [[Post_BackendObject alloc]init];
        [self.ourPosts addObject:newPost];
        [newPost createPostFromPinchViews:pinchViews toChannel:channel];
        return NULL;
    }else{
       return  [self createChannelWithName:channel.name andCompletionBlock:^(Channel * channelObject){
           Post_BackendObject * newPost = [[Post_BackendObject alloc]init];
           [self.ourPosts addObject:newPost];
                    [newPost createPostFromPinchViews:pinchViews toChannel:channelObject];
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
        completionBlock(@[]);
    }
}









@end
