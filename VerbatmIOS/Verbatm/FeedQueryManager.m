
//
//  FeedQueryManager.m
//  Verbatm
//
//  Created by Iain Usiri on 2/6/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "FeedQueryManager.h"
#import "ParseBackendKeys.h"
#import <Parse/PFQuery.h>
#import <Parse/PFUser.h>
#import <Parse/PFObject.h>


@interface FeedQueryManager ()
//how many posts have we gotten and presented so far
@property (nonatomic) NSInteger postsDownloadedSoFar;
#define POST_DOWNLOAD_MAX_SIZE 5

@end

@implementation FeedQueryManager

-(instancetype)init{
    self = [super init];
    if(self){
        self.postsDownloadedSoFar = 0;
    }
    return self;
}


//resets our cursor to zero and starts downloading from scratch
-(void)getFeedPostsFromStartWithCompletionHandler:(void(^)(NSArray *))block{
    self.postsDownloadedSoFar = 0;
    [self getMoreFeedPostsWithCompletionHandler:block];
}

-(void)getMoreFeedPostsWithCompletionHandler:(void(^)(NSArray *))block{
    PFQuery * userChannelQuery = [PFQuery queryWithClassName:FOLLOW_PFCLASS_KEY];
    [userChannelQuery whereKey:FOLLOW_USER_KEY equalTo:[PFUser currentUser]];
    [userChannelQuery findObjectsInBackgroundWithBlock:^
     (NSArray * _Nullable objects, NSError * _Nullable error) {
         
         if(objects.count > 1){
         
             PFQuery * postQuery = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
             
             NSMutableArray * channelsWeFollow = [[NSMutableArray alloc] init];
             for(int i = 0; i < objects.count; i++){
                 [channelsWeFollow addObject:[objects[i]objectForKey:FOLLOW_CHANNEL_FOLLOWED_KEY]];
             }
             
             
             [postQuery whereKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO containedIn:channelsWeFollow];
             [postQuery orderByDescending:@"createdAt"];
             
             [postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable activities, NSError * _Nullable error) {
                 
                 
                 NSMutableArray * finalPostObjects = [[NSMutableArray alloc] init];
                 
                 
                 for(NSInteger i = self.postsDownloadedSoFar;
                     (i < activities.count && i < self.postsDownloadedSoFar+POST_DOWNLOAD_MAX_SIZE); i ++){
                     
                     PFObject * pc_activity = activities[i];
                     PFObject * post = [pc_activity objectForKey:POST_CHANNEL_ACTIVITY_POST];
                     [post fetchIfNeededInBackground];
                     
                     [finalPostObjects addObject:pc_activity];
                     
                 }
                 
                 
//                 for(PFObject * pc_activity in activities){
//                     
//                     //we do this to make sure the info is downloaded and cached early
//                     PFObject * post = [pc_activity objectForKey:POST_CHANNEL_ACTIVITY_POST];
//                     [post fetchIfNeededInBackground];
//                     
//                     [finalPostObjects addObject:pc_activity];
//                 }
//
                 self.postsDownloadedSoFar += finalPostObjects.count;
                 block(finalPostObjects);
             }];
         }else{
             block(@[]);//no results so we send an empty list
         }
         
    }];
    
}















@end

