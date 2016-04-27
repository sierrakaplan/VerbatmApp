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
#import "PublishingProgressManager.h"

#import "Video_BackendObject.h"


@interface Video_BackendObject ()

@property (nonatomic) PostPublisher * mediaPublisher;

@end

@implementation Video_BackendObject

-(void)saveVideo:(NSURL *) videoUrl andPageObject:(PFObject *) pageObject {
    self.mediaPublisher = [[PostPublisher alloc] init];
    UIImage * thumbNail = [Video_BackendObject thumbnailImageForVideo:videoUrl atTime:0.f];
    [self.mediaPublisher storeVideoFromURL:videoUrl withCompletionBlock:^(GTLVerbatmAppVideo * gtlVideo) {
        NSString * blobStoreUrl = gtlVideo.blobKeyString;//set this with the url from the blobstore
        //in completion block of blobstore save
        [self createAndSaveParseVideoObjectWithBlobStoreUrl:blobStoreUrl thumbnail:thumbNail andPageObject:pageObject];
    }];
}

+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL
                             atTime:(NSTimeInterval)time {
    
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
                               thumbnail:(UIImage *) thumbnail andPageObject:(PFObject *)pageObject{
    if(!self.mediaPublisher)self.mediaPublisher = [[PostPublisher alloc] init];

	//todo:get data for thumbnail in background
    [self.mediaPublisher storeImage:UIImagePNGRepresentation(thumbnail)].then(^(NSString* blobstoreUrl) {
		NSLog(@"Now saving parse video object...");
        PFObject * newVideoObj = [PFObject objectWithClassName:VIDEO_PFCLASS_KEY];
        [newVideoObj setObject:blobStoreVideoUrl forKey:BLOB_STORE_URL];
        [newVideoObj setObject:blobstoreUrl forKey:VIDEO_THUMBNAIL_KEY];
        [newVideoObj setObject:pageObject forKey:VIDEO_PAGE_OBJECT_KEY];
        [newVideoObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded){
                //tell our publishing manager that a video is done saving
				[[PublishingProgressManager sharedInstance] mediaSavingProgressed:2]; //2 for thumbnail and video
            } else {
				[[PublishingProgressManager sharedInstance] savingMediaFailed];
			}
        }];
	});
}

+(void)getVideoForPage:(PFObject *) page andCompletionBlock:(void(^)(PFObject *))block {
    PFQuery * video = [PFQuery queryWithClassName:VIDEO_PFCLASS_KEY];
    [video whereKey:VIDEO_PAGE_OBJECT_KEY equalTo:page];
    
    [video findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                         NSError * _Nullable error) {
        if(objects && objects.count && !error){
            block(objects[0]);
        } else {
			block(nil);
		}
    }];
}

+(void)deleteVideosInPage:(PFObject *)page withCompeletionBlock:(void(^)(BOOL))block {
	PFQuery *videosQuery = [PFQuery queryWithClassName:VIDEO_PFCLASS_KEY];
	[videosQuery whereKey:VIDEO_PAGE_OBJECT_KEY equalTo:page];
	[videosQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
													NSError * _Nullable error) {
		if(objects && !error){
			for (PFObject *videoObj in objects) {
				[videoObj deleteInBackground];
			}
			block(YES);
			return;
		}
		block (NO);
	}];
}


@end
