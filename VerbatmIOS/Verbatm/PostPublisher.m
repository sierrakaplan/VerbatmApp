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
#import "GTLVerbatmAppUploadURI.h"

#import "GTMHTTPFetcherLogging.h"

#import "Notifications.h"

#import "MediaUploader.h"

#import "PostPublisher.h"
#import "PinchView.h"
#import <PromiseKit/PromiseKit.h>
#import <Parse/PFUser.h>
#import "PublishingProgressManager.h"

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


-(AnyPromise*) storeVideoFromURL: (NSURL*) url {


//	return PMKWhen(@[getVideoDataPromise, getVideoUploadURIPromise])

//	AnyPromise* getVideoDataPromise = [UtilityFunctions loadCachedVideoDataFromURL:url];
	return [self getVideoUploadURI].then(^(NSString* uri) {
//		NSData* videoData = results[0];
//		NSString* uri = results[1];
		self.videoUploader = [[MediaUploader alloc] init];
		if ([self.publishingProgress respondsToSelector:@selector(addChild:withPendingUnitCount:)]) {
			[self.publishingProgress addChild:self.videoUploader.mediaUploadProgress withPendingUnitCount: VIDEO_PROGRESS_UNITS - 1];
		}
		return [self.videoUploader uploadVideoWithUrl:url andUri:uri];
	});
}


// (get image upload uri) then (upload image to blobstore using uri) then (store gtlimage with serving url from blobstore)
// Resolves to what insertImage resolves to,
// Which should be the ID of the GTL image just stored
-(AnyPromise*) storeImage: (NSData*) imageData {
	return [self getImageUploadURI].then(^(id result) {
		if ([result isKindOfClass:[NSError class]]) {
			return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
				resolve(result);
			}];
		}
		NSString* uri = (NSString*)result;
		self.imageUploader = [[MediaUploader alloc] initWithImage: imageData andUri:uri];
		if ([self.publishingProgress respondsToSelector:@selector(addChild:withPendingUnitCount:)]) {
			[self.publishingProgress addChild:self.imageUploader.mediaUploadProgress withPendingUnitCount: IMAGE_PROGRESS_UNITS - 1];
		}
		return [self.imageUploader startUpload];
	});
}

#pragma mark - Insert entities into the Datastore NOT IN USE -

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
					[self.publishingProgress setCompletedUnitCount:self.publishingProgress.completedUnitCount + IMAGE_PROGRESS_UNITS];
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
					[self.publishingProgress setCompletedUnitCount:self.publishingProgress.completedUnitCount + VIDEO_PROGRESS_UNITS];
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

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
