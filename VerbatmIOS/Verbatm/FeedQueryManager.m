
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
@property (nonatomic) NSInteger postsDownloadedSoFar;//how many posts have we gotten and presented so far

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



-(void)getMoreFeedPostsWithCompletionHandler:(void(^)(NSArray *))block{
        
    
    
    
    
}


@end

