
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
#define POST_DOWNLOAD_MAX_SIZE 20

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
         
             PFQuery * postQuery = [PFQuery queryWithClassName:POST_PFCLASS_KEY];
             for(PFObject * channel in objects){
                 [postQuery whereKey:POST_CHANNEL_KEY equalTo:channel];
             }
             
             [postQuery orderByDescending:@"createdAt"];
             
             [postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                 NSMutableArray * finalPostResults = [[NSMutableArray alloc] init];
                 for(NSInteger i = self.postsDownloadedSoFar;
                     (i < objects.count && i < (self.postsDownloadedSoFar + POST_DOWNLOAD_MAX_SIZE));
                     i++){
                        [finalPostResults addObject:objects[i]];
                 }
                 self.postsDownloadedSoFar += finalPostResults.count;
                 block(finalPostResults);
             }];
         }else{
             block(@[]);//no results so we send an empty list
         }
         
    }];
    
}















@end

