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
#import "Post_BackendObject.h"
#import "ParseBackendKeys.h"

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
    
    PFObject * newChannelObject = [PFObject objectWithClassName:CHANNEL_PFCLASS_KEY];
    [newChannelObject setObject:channelName forKey:CHANNEL_NAME_KEY];
    [newChannelObject setObject:[NSNumber numberWithInt:0] forKey:CHANNEL_NUM_FOLLOWERS_KEY];
    [newChannelObject setObject:[NSNumber numberWithInt:0] forKey:CHANNEL_NUM_POSTS_KEY];
    
    Channel * channel = [[Channel alloc] initWithChannelName:channelName
                                                    numberOfFollowers:[NSNumber numberWithInt:0]
                                                          andUserName:[PFUser currentUser].username andParseChannelObject:newChannelObject];
    //set the pfobject_channel for this nwe channel object
    
    
    if(block){//just in case the block doesn't exist so we create a new one
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













@end
