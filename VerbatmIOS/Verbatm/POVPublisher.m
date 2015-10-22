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
#import "POVLoadManager.h"
#import "PinchView.h"

#import <PromiseKit/PromiseKit.h>
#import <Parse/PFUser.h>

#import "VideoPinchView.h"

#import "UserManager.h"
#import "UtilityFunctions.h"

@interface POVPublisher()

@property(nonatomic, strong) NSArray* pinchViews;
@property(nonatomic, strong) NSString* title;
@property(nonatomic, strong) UIImage* coverPic;
// the total number of progress units it takes to publish,
// based on the number of photos and videos in a story
@property(nonatomic) NSInteger totalProgressUnits;

@property(nonatomic, strong) GTLServiceVerbatmApp *service;

//retains reference to media uploaders since their tasks are performed async
//TODO instead should have an image media uploader and a video media uploader and make each thing wait
@property(nonatomic, strong) NSMutableArray* mediaUploaders;

@end

@implementation POVPublisher


-(instancetype) initWithPinchViews: (NSArray*) pinchViews andTitle: (NSString*) title andCoverPic: (UIImage*) coverPic {
	self = [super init];
	if (self) {
		self.pinchViews = pinchViews;
		self.title = title;
		self.coverPic = coverPic;

		self.totalProgressUnits = PROGRESS_UNITS_FOR_INITIAL_PROGRESS + PROGRESS_UNITS_FOR_PHOTO + PROGRESS_UNITS_FOR_FINAL_PUBLISH;
		for (PinchView* pinchView in self.pinchViews) {
			NSArray* photos = [pinchView getPhotosWithText];
			NSArray* videos = [pinchView getVideosWithText];
			if (photos) {
				self.totalProgressUnits += photos.count*PROGRESS_UNITS_FOR_PHOTO;
			}
			if (videos) {
				self.totalProgressUnits += videos.count*PROGRESS_UNITS_FOR_VIDEO;
			}
		}
		NSLog(@"Total progress units: %ld", (long)self.totalProgressUnits);
	}
	return self;
}

/*
 think recursive:

 when (got current user id +  saved cover pic serving url + saved page ids) upload pov

 branch coverPic: (get Image upload uri) then (upload cover pic to blobstore using uri) resolves to blobstore serving url

 branch savePageIds: when (stored every page) resolves to page ids

 when (saved image ids + saved video ids) then (store page) resolves to page id

 branch savedImageIDs: when(stored every image) resolves to image ids

 (get image upload uri) then (upload image to blobstore using uri) then (store gtlimage with serving url from blobstore) resolves to image id

 branch savedVideoIDs: when(stored every video) resolves to video ids

 (get video upload uri) then (upload video to blobstore using uri) then (store gtlvideo with blob key string) resolves to video id
 */

- (void) publish {
	NSLog(@"Attempting to publish POV...");
	self.publishingProgress = [NSProgress progressWithTotalUnitCount: self.totalProgressUnits];
	[self.publishingProgress setCompletedUnitCount:PROGRESS_UNITS_FOR_INITIAL_PROGRESS];

	GTLVerbatmAppPOV* povObject = [[GTLVerbatmAppPOV alloc] init];
	povObject.datePublished = [GTLDateTime dateTimeWithDate:[NSDate date] timeZone:[NSTimeZone localTimeZone]];
	povObject.numUpVotes = [NSNumber numberWithLongLong: 0];
	povObject.title = self.title;
	UserManager* userManager = [UserManager sharedInstance];
	povObject.creatorUserId = [userManager getCurrentUser].identifier;

	// save cover pic serving url then saved page ids then upload pov
	[self storeCoverPicture: self.coverPic].then(^(NSString* coverPicServingUrl) {
		povObject.coverPicUrl = coverPicServingUrl;
		return [self storePagesFromPinchViews: self.pinchViews];
	}).then(^(NSArray* pageIds) {
		povObject.pageIds = pageIds;
		[self insertPOV: povObject];
	}).catch(^(NSError *error){
		//This can catch at any part in the chain
		NSLog(@"Error publishing POV: %@", error.description);
		[self.publishingProgress cancel];
		self.mediaUploaders = nil;
	});
}

// (get Image upload uri) then (upload cover pic to blobstore using uri)
// Resolves to what [coverPicUploader startUpload] resolves to,
// The serving url of the image in the blobstore from Images Service
-(AnyPromise*) storeCoverPicture: (UIImage*) coverPic {
	NSLog(@"Publishing cover picture");
	return [self getImageUploadURI].then(^(NSString* uri) {

		MediaUploader* coverPicUploader = [[MediaUploader alloc] initWithImage:coverPic andUri:uri];
		[self.publishingProgress addChild:coverPicUploader.mediaUploadProgress withPendingUnitCount: PROGRESS_UNITS_FOR_PHOTO];
		[self.mediaUploaders addObject: coverPicUploader];
		return [coverPicUploader startUpload];
	});
}

// when (stored every page)
// each store page promise should resolve to the GTL page's id,
// So this promise should resolve to an array of page ids
-(AnyPromise*) storePagesFromPinchViews: (NSArray*) pinchViews {
	//Publishing pages sequentially
	NSMutableArray* pageIds = [[NSMutableArray alloc] initWithCapacity: pinchViews.count];
	AnyPromise* promise = [self storePageFromPinchView:pinchViews[0] withIndex:0];
	for (int i = 1; i < pinchViews.count; i++){
		promise = promise.then(^(NSNumber* pageID){
			NSLog(@"successfully published page at index %ld", (long)(i-1));
			[pageIds addObject:pageID];
			return [self storePageFromPinchView:pinchViews[i] withIndex:i];
		});
	}
	return promise.then(^(NSNumber* pageID){
		[pageIds addObject:pageID];
		return pageIds;
	});
}

// when (saved image ids + saved video ids) then (store page)
// Resolves to the GTL page's id that was just stored
-(AnyPromise*) storePageFromPinchView: (PinchView*)pinchView withIndex:(NSInteger) indexInPOV {
	NSLog(@"publishing page at index %ld", (long)indexInPOV);

	GTLVerbatmAppPage* page = [[GTLVerbatmAppPage alloc] init];
	page.indexInPOV = [[NSNumber alloc] initWithInteger: indexInPOV];

	AnyPromise* imageIdsPromise = [self storeImagesFromPinchView: pinchView];
	AnyPromise* videoIdsPromise = [self storeVideosFromPinchView: pinchView];

	// after page.imageIds and page.videoIds have been stored, upload the page
	return PMKWhen(@[imageIdsPromise, videoIdsPromise]).then(^(NSArray *results){
		page.imageIds = results[0];
		page.videoIds = results[1];
		return [self insertPage: page];
	});
}

// when(stored every image)
// Each storeimage promise should resolve to the id of the GTL Image just stored
// So this promise should resolve to an array of gtl image id's
-(AnyPromise*) storeImagesFromPinchView: (PinchView*) pinchView {
	if (pinchView.containsImage) {
		//Publishing images sequentially
		NSArray* pinchViewPhotosWithText = [pinchView getPhotosWithText];
		NSMutableArray* imageIds = [[NSMutableArray alloc] initWithCapacity: pinchViewPhotosWithText.count];
		AnyPromise* promise = [self storeImage:pinchViewPhotosWithText[0][0]
									 withIndex:0
									   andText:pinchViewPhotosWithText[0][1]
								  andYPosition:pinchViewPhotosWithText[0][2]];
		for (int i = 1; i < pinchViewPhotosWithText.count; i++){
			promise = promise.then(^(NSNumber* imageID){
				NSLog(@"successfully published image at index %ld", (long)(i-1));
				[imageIds addObject:imageID];

				NSArray* photoWithText = pinchViewPhotosWithText[i];
				UIImage* uiImage = photoWithText[0];
				NSString* text = photoWithText[1];
				NSNumber* textYPosition = photoWithText[2];
				return [self storeImage:uiImage withIndex:i andText:text andYPosition:textYPosition];
			});
		}
		return promise.then(^(NSNumber* imageID){
			[imageIds addObject:imageID];
			return imageIds;
		});
	} else {
		AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
			resolve([[NSArray alloc] init]);
		}];
		return promise;
	}
}

// when(stored every video)
// Each store video promise should resolve to the id of the GTL Video just stored
// So this promise should resolve to an array of gtl video id's
-(AnyPromise*) storeVideosFromPinchView: (PinchView*) pinchView {

	if (pinchView.containsVideo) {
		//Publishing videos sequentially
		NSArray* pinchViewVideosWithText = [pinchView getVideosWithText];
		NSMutableArray* videoIds = [[NSMutableArray alloc] initWithCapacity: pinchViewVideosWithText.count];
		AnyPromise* promise = [self storeVideoFromURL:[(AVURLAsset*)pinchViewVideosWithText[0][0] URL]
											  atIndex:0
											  andText:pinchViewVideosWithText[0][1]
										 andYPosition: pinchViewVideosWithText[0][2]];
		for (int i = 1; i < pinchViewVideosWithText.count; i++){
			promise = promise.then(^(NSNumber* imageID){
				NSLog(@"successfully published video at index %ld", (long)(i-1));
				[videoIds addObject:imageID];

				NSArray* videoWithText = pinchViewVideosWithText[i];
				AVURLAsset* videoAsset = videoWithText[0];
				NSString* text = videoWithText[1];
				NSNumber* textYPosition = videoWithText[2];
				return [self storeVideoFromURL:videoAsset.URL atIndex:i andText:text andYPosition: textYPosition];
			});
		}
		return promise.then(^(NSNumber* imageID){
			[videoIds addObject:imageID];
			return videoIds;
		});
	} else {
		AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
			resolve([[NSArray alloc] init]);
		}];
		return promise;
	}
}

-(AnyPromise*) storeVideoFromURL: (NSURL*) url atIndex: (NSInteger) indexInPage andText: (NSString*) text andYPosition: (NSNumber*) textYPosition {
	NSLog(@"publishing video at index %ld", (long)indexInPage);

	AnyPromise* getVideoDataPromise = [UtilityFunctions loadCachedDataFromURL: url];
	AnyPromise* getVideoUploadURIPromise = [self getVideoUploadURI];
	return PMKWhen(@[getVideoDataPromise, getVideoUploadURIPromise]).then(^(NSArray * results){
		NSData* videoData = results[0];
		NSString* uri = results[1];
		MediaUploader* videoUploader = [[MediaUploader alloc] initWithVideoData:videoData andUri: uri];
		[self.publishingProgress addChild:videoUploader.mediaUploadProgress withPendingUnitCount: PROGRESS_UNITS_FOR_VIDEO];
		[self.mediaUploaders addObject: videoUploader];
		return [videoUploader startUpload];
	}).then(^(NSString* blobStoreKeyString) {
		GTLVerbatmAppVideo* gtlVideo = [[GTLVerbatmAppVideo alloc] init];
		gtlVideo.indexInPage = [[NSNumber alloc] initWithInteger: indexInPage];
		gtlVideo.blobKeyString = blobStoreKeyString;
		gtlVideo.text = text;
		gtlVideo.textYPosition = textYPosition;
		//TODO: set user key?
		return [self insertVideo: gtlVideo];
	});
}


// (get image upload uri) then (upload image to blobstore using uri) then (store gtlimage with serving url from blobstore)
// Resolves to what insertImage resolves to,
// Which should be the ID of the GTL image just stored
-(AnyPromise*) storeImage: (UIImage*) image withIndex: (NSInteger) indexInPage andText: (NSString*) text andYPosition: (NSNumber*) textYPosition {
	NSLog(@"publishing image at index %ld", (long)indexInPage);

	return [self getImageUploadURI].then(^(NSString* uri) {
		MediaUploader* imageUploader = [[MediaUploader alloc] initWithImage: image andUri:uri];
		[self.publishingProgress addChild:imageUploader.mediaUploadProgress withPendingUnitCount: PROGRESS_UNITS_FOR_PHOTO];
		[self.mediaUploaders addObject: imageUploader];
		return [imageUploader startUpload];
	}).then(^(NSString* servingURL) {
		GTLVerbatmAppImage* gtlImage = [[GTLVerbatmAppImage alloc] init];
		gtlImage.indexInPage = [[NSNumber alloc] initWithInteger: indexInPage];
		gtlImage.servingUrl = servingURL;
		gtlImage.text = text;
		gtlImage.textYPosition = textYPosition;
		//TODO: set user key?
		return [self insertImage: gtlImage];
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
				NSLog(@"Publishing progress updated to %ld out of %ld", (long)self.publishingProgress.completedUnitCount, (long)self.totalProgressUnits);
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
				NSLog(@"Publishing progress updated to %ld out of %ld", (long)self.publishingProgress.completedUnitCount, (long)self.totalProgressUnits);
				resolve(storedVideo.identifier);
			}
		}];
	}];

	return promise;
}

// Queries insert Page into the datastore.
// PMKPromise resolves with either error or the id of the page just stored.
-(AnyPromise*) insertPage: (GTLVerbatmAppPage*) page {
	GTLQuery* insertPageQuery = [GTLQueryVerbatmApp queryForPageInsertPageWithObject: page];

	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
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
					 //TODO: should send a notification that there was an error publishing
				 } else {
					 [self.publishingProgress setCompletedUnitCount: self.totalProgressUnits];
					 NSLog(@"Publishing progress updated to %ld out of %ld", (long)self.publishingProgress.completedUnitCount, (long)self.totalProgressUnits);
					 self.mediaUploaders = nil;
					 NSLog(@"Successfully published POV!");
					 [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_POV_PUBLISHED
																		 object:ticket];
				 }
			 }];
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

-(NSMutableArray *) mediaUploaders {
	if(!_mediaUploaders) {
		_mediaUploaders = [[NSMutableArray alloc] init];
	}
	return _mediaUploaders;
}

@end
