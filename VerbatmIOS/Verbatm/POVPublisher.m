//
//  Uploader.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/1/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//



#import "GTLDateTime.h"
#import "GTLQueryVerbatmApp.h"

#import "GTLServiceVerbatmApp.h"

#import "GTLVerbatmAppPOV.h"
#import "GTLVerbatmAppPage.h"
#import "GTLVerbatmAppImage.h"
#import "GTLVerbatmAppVideo.h"
#import "GTLVerbatmAppVerbatmUser.h"
#import "GTLVerbatmAppPageListWrapper.h"
#import "GTLVerbatmAppUploadURI.h"

#import "GTMHTTPFetcherLogging.h"

#import "Notifications.h"

#import "MediaUploader.h"

#import "POVPublisher.h"
#import "PinchView.h"

#import <PromiseKit/PromiseKit.h>


@interface POVPublisher()

@property(nonatomic, strong) GTLServiceVerbatmApp *service;

@end

@implementation POVPublisher

- (void) publishPOVFromPinchViews: (NSArray*) pinchViews andTitle: (NSString*) title andCoverPic: (UIImage*) coverPic {

	GTLVerbatmAppPOV* povObject = [[GTLVerbatmAppPOV alloc] init];
	povObject.datePublished = [GTLDateTime dateTimeWithDate:[NSDate date] timeZone:[NSTimeZone localTimeZone]];
	povObject.numUpVotes = [NSNumber numberWithInt: 0];
	povObject.title = title;
	//TODO: get user
	povObject.creatorUserId = [NSNumber numberWithLongLong:1];
	povObject.coverPicUrl = @"coverPicUrl";

	[self getImageUploadURI].then(^(NSString* uri) {

//TODO:		MediaUploader* coverPicUploader = [[MediaUploader alloc] initWithImage:coverPic andUri:uri];
//		PMKPromise* uploadCoverPic = [coverPicUploader startUpload];

		NSMutableArray *pagePromises = [NSMutableArray array];
		for (int i = 0; i < pinchViews.count; i++) {
			PinchView* pinchView = pinchViews[i];
			[pagePromises addObject: [self savePageFromPinchView:pinchView withIndex:i andImageUploadURI: uri]];
		}
		return PMKWhen(pagePromises);

	}).then(^(NSArray* results) {
		NSMutableArray* pageIds = [[NSMutableArray alloc] init];
		for (NSNumber* pageId in results) {
			[pageIds addObject: pageId];
		}
		povObject.pageIds = pageIds;
		[self insertPOV: povObject];

	}).catch(^(NSError *error){
		//This can catch at any part in the chain
		NSLog(error.description);
	});

	// batch query
	GTLBatchQuery *batchQuery = [GTLBatchQuery batchQuery];


}

// Queries for a uri from the blob store to upload images to
-(PMKPromise*) getImageUploadURI {
	PMKPromise* promise = [PMKPromise promiseWithResolverBlock:^(PMKResolver resolve) {
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
-(PMKPromise*) getVideoUploadURI {
	PMKPromise* promise = [PMKPromise promiseWithResolverBlock:^(PMKResolver resolve) {
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

// Creates a gtl page object with the given index in the POV
// Then
-(PMKPromise*) savePageFromPinchView: (PinchView*)pinchView withIndex:(NSInteger) indexInPOV andImageUploadURI:(NSString*)imageUri {

	GTLVerbatmAppPage* page = [[GTLVerbatmAppPage alloc] init];
	page.indexInPOV = [[NSNumber alloc] initWithInteger: indexInPOV];

	PMKPromise* imagesPromise;
	PMKPromise* videosPromise;

	if(pinchView.containsImage) {

		NSMutableArray *imagePromises = [NSMutableArray array];

		NSArray* pinchViewImages = [pinchView getPhotos];
		for (int i = 0; i < pinchViewImages.count; i++) {
			UIImage* uiImage = pinchViewImages[i];
			GTLVerbatmAppImage* gltImage = [[GTLVerbatmAppImage alloc] init];
			gltImage.indexInPage = [[NSNumber alloc] initWithInteger:i];
			//TODO: gltImage.userKey =
			//TODO?: gtlImage.text =

			MediaUploader* imageUploader = [[MediaUploader alloc] initWithImage:uiImage andUri: imageUri];
			PMKPromise* storeImagePromise = [imageUploader startUpload].then(^(NSString* servingURL){
				gltImage.servingUrl = servingURL;
			});
			[imagePromises addObject: storeImagePromise];
		}
		imagesPromise = PMKWhen(imagePromises).then(^(NSArray *results){
			for (NSString* servingURL in results) {

			}
		}).catch(^(NSError *error){
			//called if any search fails.
			NSLog(error.description);
		});
	} else {
		page.imageIds = nil;
	}

	if(pinchView.containsVideo) {
		//TODO:
		page.videoIds = nil;

	} else {
		page.videoIds = nil;
	}
	
	return PMKWhen(@[imagesPromise, videosPromise]).then(^(NSArray *results){
		return page;
	});
}

// Queries insert Image into the datastore.
// PMKPromise resolves with either error or the id of the image just stored.
-(PMKPromise*) insertImage: (GTLVerbatmAppImage*) image {
	GTLQuery* insertImageQuery = [GTLQueryVerbatmApp queryForImageInsertImageWithObject:image];

	PMKPromise* promise = [PMKPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self.service executeQuery:insertImageQuery completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppImage* storedImage, NSError *error) {
			if (error) {
				resolve(error);
			} else {
				resolve(storedImage.identifier);
			}
		}];
	}];

	return promise;
}

// Queries insert Video into the datastore.
// PMKPromise resolves with either error or the id of the video just stored.
-(PMKPromise*) insertVideo: (GTLVerbatmAppVideo*) video {
	GTLQuery* insertVideoQuery = [GTLQueryVerbatmApp queryForVideoInsertVideoWithObject:video];

	PMKPromise* promise = [PMKPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self.service executeQuery:insertVideoQuery completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppVideo* storedVideo, NSError *error) {
			if (error) {
				resolve(error);
			} else {
				resolve(storedVideo.identifier);
			}
		}];
	}];

	return promise;
}

// Queries insert POV into the datastore
-(void) insertPOV: (GTLVerbatmAppPOV*) povObject {
	GTLQuery* insertPOVQuery = [GTLQueryVerbatmApp queryForPovInsertPOVWithObject: povObject];

	[self.service executeQuery:insertPOVQuery
			 completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppPOV* object, NSError *error) {
				 if (error) {
					 NSLog(@"Error uploading POV: %@", error.description);
				 } else {
					 NSLog(@"Successfully uploaded POV!");
					 [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_POV_PUBLISHED
											  object:ticket];
				 }
			 }];
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
