//
//  Video_BackendObject.m
//  Verbatm
//
//  Created by Iain Usiri on 1/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#import "GTLVerbatmAppVideo.h"

#import "Notifications.h"

#import <Parse/PFUser.h>
#import <Parse/PFQuery.h>
#import "ParseBackendKeys.h"
#import "PostPublisher.h"


#import "Video_BackendObject.h"


@interface Video_BackendObject ()

@property (nonatomic) PostPublisher * mediaPublisher;

@end

@implementation Video_BackendObject

-(void)saveVideo:(NSURL *) videoUrl atVideoIndex:(NSInteger) videoIndex andPageObject:(PFObject *) pageObject {
    self.mediaPublisher = [[PostPublisher alloc] init];
    UIImage * thumbNail = [Video_BackendObject thumbnailImageForVideo:videoUrl atTime:0.f];
    [self.mediaPublisher storeVideoFromURL:videoUrl withCompletionBlock:^(GTLVerbatmAppVideo * gtlVideo) {
        NSString * blobStoreUrl = gtlVideo.blobKeyString;//set this with the url from the blobstore
        //in completion block of blobstore save
        [self createAndSaveParseVideoObjectWithBlobStoreUrl:blobStoreUrl videoIndex:videoIndex thumbnail:thumbNail andPageObject:pageObject];
    }];
}

//should be moved to another file-- TODO
+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL
                             atTime:(NSTimeInterval)time
{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetIG =
    [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetIG.appliesPreferredTrackTransform = YES;
    assetIG.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *igError = nil;
    thumbnailImageRef =
    [assetIG copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)
                    actualTime:NULL
                         error:&igError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", igError );
    
    UIImage *thumbnailImage = thumbnailImageRef
    ? [[UIImage alloc] initWithCGImage:thumbnailImageRef]
    : nil;
    
    if(thumbnailImageRef) CGImageRelease(thumbnailImageRef);
    return thumbnailImage;
}

-(void)createAndSaveParseVideoObjectWithBlobStoreUrl:(NSString *) blobStoreVideoUrl
                               videoIndex:(NSInteger) videoIndex thumbnail:(UIImage *) thumbnail andPageObject:(PFObject *)pageObject{
    if(!self.mediaPublisher)self.mediaPublisher = [[PostPublisher alloc] init];
    
    [self.mediaPublisher storeImage:thumbnail withCompletionBlock:^(GTLVerbatmAppImage * gtlImage) {
        NSString * blobStoreImageUrl = gtlImage.servingUrl;
        NSLog(@"Saving video parse object with url");
        PFObject * newVideoObj = [PFObject objectWithClassName:VIDEO_PFCLASS_KEY];
        [newVideoObj setObject:[NSNumber numberWithInteger:videoIndex] forKey:VIDEO_INDEX_KEY];
        [newVideoObj setObject:blobStoreVideoUrl forKey:BLOB_STORE_URL];
        [newVideoObj setObject:blobStoreImageUrl forKey:VIDEO_THUMBNAIL_KEY];
        [newVideoObj setObject:pageObject forKey:VIDEO_PAGE_OBJECT_KEY];
        [newVideoObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded){
                //tell our publishing manager that a video is done saving
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MEDIA_SAVING_SUCCEEDED object:nil];
            }
        }];
    }];
}




+(void)getVideosForPage:(PFObject *) page andCompletionBlock:(void(^)(NSArray *))block {
    PFQuery * video = [PFQuery queryWithClassName:VIDEO_PFCLASS_KEY];
    [video whereKey:VIDEO_PAGE_OBJECT_KEY equalTo:page];
    
    [video findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                         NSError * _Nullable error) {
        if(objects && !error){
            
            [objects sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                PFObject * videoA = obj1;
                PFObject * videoB = obj2;
                
                NSNumber * videoAnum = [videoA valueForKey:VIDEO_INDEX_KEY];
                NSNumber * videoBnum = [videoB valueForKey:VIDEO_INDEX_KEY];
                
                if([videoAnum integerValue] > [videoBnum integerValue]){
                    return NSOrderedDescending;
                }else if ([videoAnum integerValue] < [videoBnum integerValue]){
                    return NSOrderedAscending;
                }
                return NSOrderedSame;
            }];
            
            block(objects);
        }
        
    }];
    
}


@end
