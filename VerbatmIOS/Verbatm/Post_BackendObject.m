
//
//  Post.m
//  Verbatm
//
//  Created by Iain Usiri on 1/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.


#import "Post_BackendObject.h"
#import "PinchView.h"
#import "ParseBackendKeys.h"

#import <Parse/PFObject.h>
#import <Parse/PFUser.h>
#import <Parse/PFQuery.h>

#import "Page_BackendObject.h"
#import "CollectionPinchView.h"
#import "VideoPinchView.h"

@interface Post_BackendObject ()
@property (nonatomic) NSMutableArray * pageArray;
@end

@implementation Post_BackendObject


-(instancetype)init{
    self = [super init];
    if(self){
        self.pageArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(PFObject * ) createPostFromPinchViews: (NSArray*) pinchViews toChannel: (Channel *) channel{
    PFObject * newPostObject = [PFObject objectWithClassName:POST_PFCLASS_KEY];
    [newPostObject setObject:channel.parseChannelObject forKey:POST_CHANNEL_KEY];
    [newPostObject setObject:[NSNumber numberWithInt:0] forKey:POST_LIKES_NUM_KEY];
    [newPostObject setObject:[NSNumber numberWithInt:0] forKey:POST_NUM_SHARES_KEY];
    [newPostObject setObject:[PFUser currentUser] forKey:POST_ORIGINAL_CREATOR_KEY];
    [newPostObject setObject:[NSNumber numberWithInteger:pinchViews.count] forKey:POST_SIZE_KEY];
    [newPostObject setObject:[NSNumber numberWithBool:false] forKey:POST_COMPLETED_SAVING];//mark as not done saving yet
    
    [newPostObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){//now we save the pinchview to a page
            for (int i = 0; i< pinchViews.count; i++) {
                PinchView * pv = pinchViews[i];
                Page_BackendObject * newPage = [[Page_BackendObject alloc] init];
                [self.pageArray addObject:newPage];
                [newPage savePageWithIndex:i andPinchView:pv andPost:newPostObject];
            }
        }
    }];
    
    return newPostObject;
}


+(void) getPostsInChannel:(Channel *) channel withCompletionBlock:(void(^)(NSArray *))block{
    
    if(channel){
        PFQuery * postQuery = [PFQuery queryWithClassName:POST_PFCLASS_KEY];
        [postQuery whereKey:POST_CHANNEL_KEY equalTo:channel.parseChannelObject];
        //make sure the posts have been fully published
        [postQuery whereKey:POST_COMPLETED_SAVING equalTo:[NSNumber numberWithBool:true]];
        [postQuery orderByDescending:@"createdAt"];
        [postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                             NSError * _Nullable error) {
            if(objects && !error){
                block(objects);
            }
        }];
    }
}



@end
