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
#import "PinchView.h"

#import <PromiseKit/PromiseKit.h>
#import <Parse/PFUser.h>

#import "VideoPinchView.h"

@interface POVPublisher()

@property(nonatomic, strong) NSArray* pinchViews;
@property(nonatomic, strong) NSString* title;
@property(nonatomic, strong) UIImage* coverPic;

@property(nonatomic, strong) GTLServiceVerbatmApp *service;

//retains reference to media uploaders since their tasks are performed async
@property(nonatomic, strong) NSMutableArray* mediaUploaders;

@end

@implementation POVPublisher


-(instancetype) initWithPinchViews: (NSArray*) pinchViews andTitle: (NSString*) title andCoverPic: (UIImage*) coverPic {
	self = [super init];
	if (self) {
		self.pinchViews = pinchViews;
		self.title = title;
		self.coverPic = coverPic;
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

	GTLVerbatmAppPOV* povObject = [[GTLVerbatmAppPOV alloc] init];
	povObject.datePublished = [GTLDateTime dateTimeWithDate:[NSDate date] timeZone:[NSTimeZone localTimeZone]];
	povObject.numUpVotes = [NSNumber numberWithInt: 0];
	povObject.title = self.title;

	// when (got current user id + saved cover pic serving url + saved page ids) upload pov
	AnyPromise* getUserIDPromise = [self getCurrentUserID];
	AnyPromise* storeCoverPicPromise = [self storeCoverPicture: self.coverPic];
	AnyPromise* storePagesPromise = [self storePagesFromPinchViews: self.pinchViews];
	PMKWhen(@[getUserIDPromise, storeCoverPicPromise, storePagesPromise]).then(^(NSArray* results) {
		povObject.creatorUserId = results[0];
		// storeCoverPicPromise should resolve to the serving url of the cover pic
		povObject.coverPicUrl = results[1];
		// storePagesPromise should resolve to an array of page ids
		povObject.pageIds = results[2];
		[self insertPOV: povObject];

	}).catch(^(NSError *error){
		//This can catch at any part in the chain
		NSLog(@"Error uploading POV: %@", error.description);
		self.mediaUploaders = nil;
	});
}

// Resolves to either error or ID of the currently logged in user,
// or if no user is logged in 1 (this should never happen)
-(AnyPromise*) getCurrentUserID {
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		if (![PFUser currentUser]) {
			NSLog(@"User is not logged in.");
			resolve([NSNumber numberWithLongLong:1]);
		}
		NSString* email = [PFUser currentUser].email;
		GTLQueryVerbatmApp* getUserQuery = [GTLQueryVerbatmApp queryForVerbatmuserGetUserFromEmailWithEmail: email];

		[self.service executeQuery:getUserQuery completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppVerbatmUser* currentUser, NSError *error) {
			if (error) {
				resolve(error);
			} else {
				resolve(currentUser.identifier);
			}
		}];
	}];

	return promise;
}

// (get Image upload uri) then (upload cover pic to blobstore using uri)
// Resolves to what [coverPicUploader startUpload] resolves to,
// The serving url of the image in the blobstore from Images Service
-(AnyPromise*) storeCoverPicture: (UIImage*) coverPic {
	return [self getImageUploadURI].then(^(NSString* uri) {

		MediaUploader* coverPicUploader = [[MediaUploader alloc] initWithImage:coverPic andUri:uri];
		[self.mediaUploaders addObject: coverPicUploader];
		return [coverPicUploader startUpload];
	}).catch(^(NSError *error){
		//This can catch at any part in the chain
		NSLog(@"Error uploading POV: %@", error.description);
	});;
}

// when (stored every page)
// each store page promise should resolve to the GTL page's id,
// So this promise should resolve to an array of page ids
-(AnyPromise*) storePagesFromPinchViews: (NSArray*) pinchViews {
	NSMutableArray *storePagePromises = [NSMutableArray array];
	for (int i = 0; i < pinchViews.count; i++) {
		PinchView* pinchView = pinchViews[i];
		[storePagePromises addObject: [self storePageFromPinchView:pinchView withIndex:i]];
	}
	return PMKWhen(storePagePromises).catch(^(NSError *error){
		//This can catch at any part in the chain
		NSLog(@"Error uploading POV: %@", error.description);
	});
}

// when (saved image ids + saved video ids) then (store page)
// Resolves to the GTL page's id that was just stored
-(AnyPromise*) storePageFromPinchView: (PinchView*)pinchView withIndex:(NSInteger) indexInPOV {

	GTLVerbatmAppPage* page = [[GTLVerbatmAppPage alloc] init];
	page.indexInPOV = [[NSNumber alloc] initWithInteger: indexInPOV];
//	return [self insertPage: page];

	AnyPromise* imageIdsPromise = [self storeImagesFromPinchView: pinchView];
	AnyPromise* videoIdsPromise = [self storeVideosFromPinchView: pinchView];

	// after page.imageIds and page.videoIds have been stored, upload the page
	return PMKWhen(@[imageIdsPromise, videoIdsPromise]).then(^(NSArray *results){
		page.imageIds = results[0];
		page.videoIds = results[1];
		return [self insertPage: page];
	}).catch(^(NSError *error){
		//This can catch at any part in the chain
		NSLog(@"Error uploading POV: %@", error.description);
	});
}

// when(stored every image)
// Each storeimage promise should resolve to the id of the GTL Image just stored
// So this promise should resolve to an array of gtl image id's
-(AnyPromise*) storeImagesFromPinchView: (PinchView*) pinchView {
	NSMutableArray *storeImagePromises = [[NSMutableArray array] init];

	if(pinchView.containsImage) {
		NSArray* pinchViewImages = [pinchView getPhotos];

		for (int i = 0; i < pinchViewImages.count; i++) {
			UIImage* uiImage = pinchViewImages[i];
			[storeImagePromises addObject: [self storeImage:uiImage withIndex:i]];
		}
	}
	return PMKWhen(storeImagePromises).catch(^(NSError *error){
		//This can catch at any part in the chain
		NSLog(@"Error uploading POV: %@", error.description);
	});
}

// when(stored every video)
// Each store video promise should resolve to the id of the GTL Video just stored
// So this promise should resolve to an array of gtl video id's
-(AnyPromise*) storeVideosFromPinchView: (PinchView*) pinchView {
	NSMutableArray *storeVideoPromises = [[NSMutableArray array] init];
	if(pinchView.containsVideo) {
        NSArray* pinchViewVideos = @[];
        if([pinchView isKindOfClass:[CollectionPinchView class]]){
            pinchViewVideos = [((CollectionPinchView *)pinchView) getVideosInDataFormat];
        }else if ([pinchView isKindOfClass:[VideoPinchView class]]){
            pinchViewVideos = [((VideoPinchView *)pinchView) getVideosInDataFormat];
        }
        
        if(!pinchViewVideos)return nil;
		for (int i = 0; i < pinchViewVideos.count; i++) {
			NSData* videoData = pinchViewVideos[i];
			[storeVideoPromises addObject: [self storeVideo:videoData withIndex:i]];
		}
	}
	return PMKWhen(storeVideoPromises).catch(^(NSError *error){
		//This can catch at any part in the chain
		NSLog(@"Error uploading POV: %@", error.description);
	});
}

// (get image upload uri) then (upload image to blobstore using uri) then (store gtlimage with serving url from blobstore)
// Resolves to what insertImage resolves to,
// Which should be the ID of the GTL image just stored
-(AnyPromise*) storeImage: (UIImage*) image withIndex: (NSInteger) indexInPage {
	return [self getImageUploadURI].then(^(NSString* uri) {
		MediaUploader* imageUploader = [[MediaUploader alloc] initWithImage: image andUri:uri];
		[self.mediaUploaders addObject: imageUploader];
		return [imageUploader startUpload];
	}).then(^(NSString* servingURL) {
		GTLVerbatmAppImage* gtlImage = [[GTLVerbatmAppImage alloc] init];
		gtlImage.indexInPage = [[NSNumber alloc] initWithInteger: indexInPage];
		gtlImage.servingUrl = servingURL;
		//TODO: set user key and ?text?

		return [self insertImage: gtlImage];
	});
}

//  (get video upload uri) then (upload video to blobstore using uri) then (store gtlvideo with blob key string)
// Resolves to what insertVideo resolves to,
// Which should be the ID of the GTL video just stored
-(AnyPromise*) storeVideo: (NSData*) videoData withIndex: (NSInteger) indexInPage {
	return [self getVideoUploadURI].then(^(NSString* uri) {
		MediaUploader* videoUploader = [[MediaUploader alloc] initWithVideoData:videoData andUri: uri];
		[self.mediaUploaders addObject: videoUploader];
		return [videoUploader startUpload];
	}).then(^(NSString* blobStoreKeyString) {
		GTLVerbatmAppVideo* gtlVideo = [[GTLVerbatmAppVideo alloc] init];
		gtlVideo.indexInPage = [[NSNumber alloc] initWithInteger: indexInPage];
		gtlVideo.blobKeyString = blobStoreKeyString;
		//TODO: set user key and ?text?

		return [self insertVideo: gtlVideo];
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
					 NSLog(@"Successfully uploaded POV!");
					 self.mediaUploaders = nil;
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
