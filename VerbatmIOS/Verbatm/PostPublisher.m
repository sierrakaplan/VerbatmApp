//
//  Uploader.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/1/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//


#import "CollectionPinchView.h"

#import "GTLDateTime.h"
#import "GTLQueryVerbatmApp.h"

#import "GTLServiceVerbatmApp.h"

#import "GTLVerbatmAppPage.h"
#import "GTLVerbatmAppImage.h"
#import "GTLVerbatmAppVideo.h"
#import "GTLVerbatmAppVerbatmUser.h"
#import "GTLVerbatmAppPageListWrapper.h"

#import "GTMHTTPFetcherLogging.h"

#import "Notifications.h"

#import "MediaUploader.h"

#import "PostPublisher.h"
#import "PinchView.h"

#import <PromiseKit/PromiseKit.h>
#import <Parse/PFUser.h>

#import "VideoPinchView.h"

#import "UserManager.h"
#import "UtilityFunctions.h"

@interface PostPublisher()

@property(nonatomic, strong) NSArray* pinchViews;
@property(nonatomic, strong) NSString* title;
// the total number of progress units it takes to publish,
// based on the number of photos and videos in a story
@property(nonatomic) NSInteger totalProgressUnits;

@property(nonatomic, strong) GTLServiceVerbatmApp *service;

@property(nonatomic, strong) MediaUploader* imageUploader;
@property(nonatomic, strong) MediaUploader* videoUploader;

@end

@implementation PostPublisher


-(void) storeVideoFromURL: (NSURL*) url withCompletionBlock:(void(^)(GTLVerbatmAppVideo *))block {

	AnyPromise* getVideoDataPromise = [UtilityFunctions loadCachedVideoDataFromURL:url];
	AnyPromise* getVideoUploadURIPromise = [self getVideoUploadURI];

	PMKWhen(@[getVideoDataPromise, getVideoUploadURIPromise]).then(^(NSArray * results){
		NSData* videoData = results[0];
        if(![videoData isKindOfClass:[NSNull class]]){
            NSString* uri = results[1];
            self.videoUploader = [[MediaUploader alloc] initWithVideoData:videoData andUri: uri];
            if ([self.publishingProgress respondsToSelector:@selector(addChild:withPendingUnitCount:)]) {
                [self.publishingProgress addChild:self.videoUploader.mediaUploadProgress withPendingUnitCount: PROGRESS_UNITS_FOR_VIDEO];
            }
            NSLog(@"Starting video upload");
        } else {
            NSLog(@"Video upload failed");
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MEDIA_SAVING_FAILED object:nil];
        }

		return [self.videoUploader startUpload];
        
	}).then(^(NSString* blobStoreKeyString) {
        NSLog(@"saved video to GAE");
        if(blobStoreKeyString && ![blobStoreKeyString isEqualToString:@""]){
            GTLVerbatmAppVideo* gtlVideo = [[GTLVerbatmAppVideo alloc] init];
            gtlVideo.blobKeyString = blobStoreKeyString;
            block(gtlVideo);
        }else{
            NSLog(@"Video upload failed");
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MEDIA_SAVING_FAILED object:nil];
        }
	});
}


// (get image upload uri) then (upload image to blobstore using uri) then (store gtlimage with serving url from blobstore)
// Resolves to what insertImage resolves to,
// Which should be the ID of the GTL image just stored
-(void) storeImage: (UIImage*) image withCompletionBlock:(void(^)(GTLVerbatmAppImage *))block {
    [self getImageUploadURI].then(^(NSString* uri) {
        NSLog(@"saving photo to GAE");

		self.imageUploader = [[MediaUploader alloc] initWithImage: image andUri:uri];
		if ([self.publishingProgress respondsToSelector:@selector(addChild:withPendingUnitCount:)]) {
			[self.publishingProgress addChild:self.imageUploader.mediaUploadProgress withPendingUnitCount: PROGRESS_UNITS_FOR_PHOTO];
		}
        return [self.imageUploader startUpload];
	}).then(^(NSString* servingURL) {
		GTLVerbatmAppImage* gtlImage = [[GTLVerbatmAppImage alloc] init];
		gtlImage.servingUrl = servingURL;
        
        block(gtlImage);
    });
}

#pragma mark - Insert entities into the Datastore -

//TODO: see if batch queries speed things up

// Queries insert Image into the datastore.
// PMKPromise resolves with either error or the id of the image just stored.
-(AnyPromise*) insertImage: (GTLVerbatmAppImage*) image {
	GTLQuery* insertImageQuery = [GTLQueryVerbatmApp queryForImageInsertImageWithObject:image];

	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self.service executeQuery:insertImageQuery completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppImage* storedImage, NSError *error) {
			if (error) {
				resolve(error);
			} else {
				if (![self.publishingProgress respondsToSelector:@selector(addChild:withPendingUnitCount:)]) {
					[self.publishingProgress setCompletedUnitCount:self.publishingProgress.completedUnitCount + PROGRESS_UNITS_FOR_PHOTO];
				}
				resolve(storedImage.identifier);
			}
		}];
	}];

	return promise;
}

// Queries insert Video into the datastore.
// PMKPromise resolves with either error or the id of the video just stored.
-(AnyPromise*) insertVideo: (GTLVerbatmAppVideo*) video {
	GTLQuery* insertVideoQuery = [GTLQueryVerbatmApp queryForVideoInsertVideoWithObject:video];
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self.service executeQuery:insertVideoQuery completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppVideo* storedVideo, NSError *error) {
			if (error) {
				resolve(error);
			} else {
				if (![self.publishingProgress respondsToSelector:@selector(addChild:withPendingUnitCount:)]) {
					[self.publishingProgress setCompletedUnitCount:self.publishingProgress.completedUnitCount + PROGRESS_UNITS_FOR_VIDEO];
				}
				NSLog(@"Publishing progress updated to %ld out of %ld", (long)self.publishingProgress.completedUnitCount, (long)self.totalProgressUnits);
				resolve(storedVideo.identifier);
			}
		}];
	}];

	return promise;
}

#pragma mark - Get upload URIS -

// Queries for a uri from the blob store to upload images to
-(AnyPromise*) getImageUploadURI {
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self.service executeQuery:[GTLQueryVerbatmApp queryForImageGetUploadURI]
				 completionHandler:^(GTLServiceTicket *ticket,
									 GTLVerbatmAppUploadURI* uploadURI,
									 NSError *error) {
					 if (error) {
						 resolve(error);
					 } else {
						 resolve(uploadURI.uploadURIString);
					 }
				 }];
	}];
	return promise;
}

// Queries for a uri from the blob store to upload videos to
-(AnyPromise*) getVideoUploadURI {
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self.service executeQuery:[GTLQueryVerbatmApp queryForVideoGetUploadURI]
				 completionHandler:^(GTLServiceTicket *ticket,
									 GTLVerbatmAppUploadURI* uploadURI,
									 NSError *error) {
					 if (error) {
						 resolve(error);
					 } else {
						 resolve(uploadURI.uploadURIString);
					 }
				 }];
	}];
	return promise;
}

#pragma mark - Lazy Instantiation -

- (GTLServiceVerbatmApp *)service {
	if (!_service) {
		_service = [[GTLServiceVerbatmApp alloc] init];

		_service.retryEnabled = YES;

		// Development only
		[GTMHTTPFetcher setLoggingEnabled:YES];
	}

	return _service;
}

@end
