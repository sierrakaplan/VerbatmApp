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

/*
 think recursive:

 when (stored cover pic + stored page ids) upload pov

 branch 1: (get Image upload uri) then (store cover pic)

 branch 2: when (stored every page) save page ids

 when (stored image ids + stored video ids) store page

 branch a: when(stored every image) save image ids

 (get image upload uri) then (store image)

 branch b: when(stored every video) save video ids

 (get video upload uri) then (store video)
 */

- (void) publishPOVFromPinchViews: (NSArray*) pinchViews andTitle: (NSString*) title andCoverPic: (UIImage*) coverPic {

	GTLVerbatmAppPOV* povObject = [[GTLVerbatmAppPOV alloc] init];
	povObject.datePublished = [GTLDateTime dateTimeWithDate:[NSDate date] timeZone:[NSTimeZone localTimeZone]];
	povObject.numUpVotes = [NSNumber numberWithInt: 0];
	povObject.title = title;
	//TODO: get user
	povObject.creatorUserId = [NSNumber numberWithLongLong:1];

	// when (stored cover pic + stored page ids) upload pov
	PMKPromise* storeCoverPicPromise = [self storeCoverPicture: coverPic];
	PMKPromise* storePagesPromise = [self storePagesFromPinchViews: pinchViews];
	PMKWhen(@[storeCoverPicPromise, storePagesPromise]).then(^(NSArray* results) {
		// storeCoverPicPromise should resolve to the serving url of the cover pic
		povObject.coverPicUrl = results[0];
		// storePagesPromise should resolve to an array of page ids
		povObject.pageIds = results[1];
		[self insertPOV: povObject];

	}).catch(^(NSError *error){
		//This can catch at any part in the chain
		NSLog(@"Error uploading POV: %@", error.description);
	});

}

// (get Image upload uri) then (store cover pic)
// Resolves to what [coverPicUploader startUpload] resolves to,
// The serving url of the image in the blobstore from Images Service
-(PMKPromise*) storeCoverPicture: (UIImage*) coverPic {
	return [self getImageUploadURI].then(^(NSString* uri) {

		MediaUploader* coverPicUploader = [[MediaUploader alloc] initWithImage:coverPic andUri:uri];
		return [coverPicUploader startUpload];
	});
}

//when (stored every page) save page ids
//each store page promise should resolve to the GTL page's id,
//So this promise should resolve to an array of page ids
-(PMKPromise*) storePagesFromPinchViews: (NSArray*) pinchViews {
	NSMutableArray *storePagePromises = [NSMutableArray array];
	for (int i = 0; i < pinchViews.count; i++) {
		PinchView* pinchView = pinchViews[i];
		[storePagePromises addObject: [self savePageFromPinchView:pinchView withIndex:i]];
	}
	return PMKWhen(storePagePromises);
}

// when (stored image ids + stored video ids) store page
// Should resolve to the GTL page's id (that was just stored)
-(PMKPromise*) savePageFromPinchView: (PinchView*)pinchView withIndex:(NSInteger) indexInPOV {

	GTLVerbatmAppPage* page = [[GTLVerbatmAppPage alloc] init];
	page.indexInPOV = [[NSNumber alloc] initWithInteger: indexInPOV];

	PMKPromise* imageIdsPromise;
	PMKPromise* videoIdsPromise;

	if(pinchView.containsImage) {

		NSMutableArray *imagePromises = [NSMutableArray array];

		NSArray* pinchViewImages = [pinchView getPhotos];
		for (int i = 0; i < pinchViewImages.count; i++) {
			UIImage* uiImage = pinchViewImages[i];
			GTLVerbatmAppImage* gtlImage = [[GTLVerbatmAppImage alloc] init];
			gtlImage.indexInPage = [[NSNumber alloc] initWithInteger:i];
			//TODO: gltImage.userKey =
			//TODO?: gtlImage.text =

			MediaUploader* imageUploader = [[MediaUploader alloc] initWithImage:uiImage andUri: imageUri];
			PMKPromise* storeImagePromise = [imageUploader startUpload].then(^(NSString* servingURL) {
				gtlImage.servingUrl = servingURL;
				return [self insertImage: gtlImage];
			}).catch(^(NSError *error){
				//called if any search fails.
				NSLog(error.description);
			});
			[imagePromises addObject: storeImagePromise];
		}
		imageIdsPromise = PMKWhen(imagePromises).then(^(NSArray *results){
			// each result should be the image id resolved by the promise
			page.imageIds = results;
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

	// after page.imageIds and page.videoIds have been stored, upload the page
	return PMKWhen(@[imageIdsPromise, videoIdsPromise]).then(^(NSArray *results){
		return [self insertPage: page];
	});
}

// when(stored every image) save image ids
// Each store image promise should resolve to the id of the GTL Image just stored
// So this promise should resolve to an array of id's
-(PMKPromise*) storeImagesFromPinchView: (PinchView*) pinchView {
	NSMutableArray *storeImagesPromise = [NSMutableArray array];

	if(pinchView.containsImage) {
		NSArray* pinchViewImages = [pinchView getPhotos];

		for (int i = 0; i < pinchViewImages.count; i++) {
			UIImage* uiImage = pinchViewImages[i];
			GTLVerbatmAppImage* gtlImage = [[GTLVerbatmAppImage alloc] init];
			gtlImage.indexInPage = [[NSNumber alloc] initWithInteger:i];
		}
	}
	return PMKWhen(storeImagesPromise);
}

// when(stored every video) save video ids
// Each store video promise should resolve to the id of the GTL Video just stored
// So this promise should resolve to an array of id's
-(PMKPromise*) storeVideosFromPinchView: (PinchView*) pinchView {

}

// (get image upload uri) then (store image to blobstore) then (store gtlimage)
// Resolves to what insertImage resolves to,
// Which should be the ID of the GTL image just stored
-(PMKPromise*) storeImage: (UIImage*) image {
	return [self getImageUploadURI].then(^(NSString* uri) {
		MediaUploader* imageUploader = [[MediaUploader alloc] initWithImage: image andUri:uri];
		return [imageUploader startUpload];
	});
}

// (get video upload uri) then (store video to blobstore) then (store gtlvideo)
// Resolves to what insertVideo resolves to,
// Which should be the ID of the GTL video just stored
-(PMKPromise*) storeVideo: (NSData*) videoData {
	return [self getVideoUploadURI].then(^(NSString* uri) {
		MediaUploader* videoUploader = [[MediaUploader alloc] initWithVideoData:videoData andUri: uri];
		return [videoUploader startUpload];
	});
}


#pragma mark - Insert entities into the Datastore -

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

// Queries insert Page into the datastore.
// PMKPromise resolves with either error or the id of the page just stored.
-(PMKPromise*) insertPage: (GTLVerbatmAppPage*) page {
	GTLQuery* insertPageQuery = [GTLQueryVerbatmApp queryForPageInsertPageWithObject: page];

	PMKPromise* promise = [PMKPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self.service executeQuery:insertPageQuery completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppPage* storedPage, NSError *error) {
			if (error) {
				resolve(error);
			} else {
				resolve(storedPage.identifier);
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

#pragma mark - Get upload URIS -

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
