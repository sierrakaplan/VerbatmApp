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

#import <Crashlytics/Crashlytics.h>

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

-(AnyPromise*) saveVideo:(NSURL *) videoUrl andPageObject:(PFObject *) pageObject {
    self.mediaPublisher = [[PostPublisher alloc] init];
    UIImage * thumbNail = [Video_BackendObject thumbnailImageForVideo:videoUrl atTime:0.f];
    return [self.mediaPublisher storeVideoFromURL:videoUrl].then(^(id result) {
		if ([result isKindOfClass:[NSError class]]) {
			return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
				resolve(result);
			}];
		} else {
			NSString * blobStoreUrl = (NSString*)result;
			return [self createAndSaveParseVideoObjectWithBlobStoreUrl:blobStoreUrl thumbnail:thumbNail andPageObject:pageObject];
		}
	});
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
       [[Crashlytics sharedInstance] recordError:igError];
    
    UIImage *thumbnailImage = thumbnailImageRef
    ? [[UIImage alloc] initWithCGImage:thumbnailImageRef]
    : nil;
    
    if(thumbnailImageRef) CGImageRelease(thumbnailImageRef);
    return thumbnailImage;
}

-(AnyPromise*) createAndSaveParseVideoObjectWithBlobStoreUrl:(NSString *) blobStoreVideoUrl
                               thumbnail:(UIImage *) thumbnail andPageObject:(PFObject *)pageObject{
    if(!self.mediaPublisher)self.mediaPublisher = [[PostPublisher alloc] init];

	//todo:get data for thumbnail in background
    return [self.mediaPublisher storeImageWithName:@"videoThumbnail.png" andData:UIImagePNGRepresentation(thumbnail)].then(^(NSString* blobstoreUrl) {
        PFObject * newVideoObj = [PFObject objectWithClassName:VIDEO_PFCLASS_KEY];
        [newVideoObj setObject:blobStoreVideoUrl forKey:BLOB_STORE_URL];
        [newVideoObj setObject:blobstoreUrl forKey:VIDEO_THUMBNAIL_KEY];
        [newVideoObj setObject:pageObject forKey:VIDEO_PAGE_OBJECT_KEY];
		return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
			[newVideoObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
				if(succeeded){
					//tell our publishing manager that a video is done saving
					[[PublishingProgressManager sharedInstance] mediaSavingProgressed:2]; //2 for thumbnail and video
					resolve(nil);
				} else {
					resolve(error);
				}
			}];
		}];
	});
}

+(void)getVideoForPage:(PFObject *) page andCompletionBlock:(void(^)(PFObject *))block {
    PFQuery *videoQuery = [PFQuery queryWithClassName:VIDEO_PFCLASS_KEY];
    [videoQuery whereKey:VIDEO_PAGE_OBJECT_KEY equalTo:page];
    [videoQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                         NSError * _Nullable error) {
		if (error) {
			NSLog(@"Error: %@", error);
			[[Crashlytics sharedInstance] recordError:error];
		} else if(objects && objects.count){
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
