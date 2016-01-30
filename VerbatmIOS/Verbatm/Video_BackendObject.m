//
//  Video_BackendObject.m
//  Verbatm
//
//  Created by Iain Usiri on 1/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//
#import "GTLVerbatmAppVideo.h"

#import <Parse/PFUser.h>
#import "ParseBackendKeys.h"
#import "POVPublisher.h"
#import "Video_BackendObject.h"


@interface Video_BackendObject ()
@property (nonatomic) POVPublisher * mediaPublisher;
@end

@implementation Video_BackendObject



-(void)saveVideo:(NSURL *) videoUrl atVideoIndex:(NSInteger) videoIndex andPageObject:(PFObject *) pageObject;
{
    self.mediaPublisher = [[POVPublisher alloc] init];
    [self.mediaPublisher  storeVideoFromURL:videoUrl withCompletionBlock:^(GTLVerbatmAppVideo * gtlVideo) {
        //save the video to the GAE blobstore -- TODO Sierra (new)
        NSString * blobStoreUrl = gtlVideo.blobKeyString;//set this with the url from the blobstore
        //in completion block of blobstore save
        [self createAndSaveVideoWithBlobStoreUrl:blobStoreUrl videoIndex:videoIndex andPageObject:pageObject];
    }];
    
    
    
    
}


-(void)createAndSaveVideoWithBlobStoreUrl:(NSString *) blobStoreUrl videoIndex:(NSInteger) videoIndex andPageObject:(PFObject *)pageObject{
    
    PFObject * newVideoObj = [PFObject objectWithClassName:VIDEO_PFCLASS_KEY];
    [newVideoObj setObject:[NSNumber numberWithInteger:videoIndex] forKey:VIDEO_INDEX_KEY];
    [newVideoObj setObject:blobStoreUrl forKey:BLOB_STORE_URL];
    [newVideoObj setObject:pageObject forKey:VIDEO_PAGE_OBJECT_KEY];
    [newVideoObj saveInBackground];
    
}



@end
