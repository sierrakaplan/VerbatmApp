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
#import "GTLVerbatmAppPageListWrapper.h"
#import "GTLVerbatmAppImageListWrapper.h"
#import "GTLVerbatmAppVideoListWrapper.h"
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

#import "UtilityFunctions.h"

@interface POVPublisher()

@property(nonatomic, strong) NSArray* pinchViews;
@property(nonatomic) NSInteger channelId;
// the total number of progress units it takes to publish,
// based on the number of photos and videos in a story
@property(nonatomic) NSInteger totalProgressUnits;

@property(nonatomic, strong) GTLServiceVerbatmApp *service;

@property(nonatomic, strong) MediaUploader* imageUploader;
@property(nonatomic, strong) MediaUploader* videoUploader;

@end

@implementation POVPublisher

-(instancetype) initWithPinchViews: (NSArray*) pinchViews
					  andChannelId: (NSInteger) channelId {
	self = [super init];
	if (self) {
		self.pinchViews = pinchViews;
		self.channelId = channelId;
		self.totalProgressUnits = PROGRESS_UNITS_FOR_INITIAL_PROGRESS + PROGRESS_UNITS_FOR_FINAL_PUBLISH;
		for (PinchView* pinchView in self.pinchViews) {
			NSArray* photos = [pinchView getPhotosWithText];
			NSArray* videos = [pinchView getVideosWithText];
			if (photos) {
				self.totalProgressUnits += photos.count*PROGRESS_UNITS_FOR_IMAGE;
			}
			if (videos) {
				self.totalProgressUnits += videos.count*PROGRESS_UNITS_FOR_VIDEO;
			}
		}
		NSLog(@"Total progress units: %ld", (long)self.totalProgressUnits);
	}
	return self;
}

-(instancetype) initWithPost: (GTLVerbatmAppPost*) post
				andChannelId: (NSInteger) channelId {
	//TODO: REBLOGGING (figure out if each page needs to be recreated)
	self = [super init];
	if (self) {

	}
	return self;
}

/*
 First save all videos and images in blobstore, 
 then save lists of gtlVerbatmAppImage and gtlVerbatmAppVideo in post
 Also save list of gtlVerbatmAppPage in post,
 then call insertPost
 */
- (void) publishFromPinchViews {
	NSLog(@"Attempting to publish POV...");
	self.publishingProgress = [NSProgress progressWithTotalUnitCount: self.totalProgressUnits];
	[self.publishingProgress setCompletedUnitCount:PROGRESS_UNITS_FOR_INITIAL_PROGRESS];

	GTLVerbatmAppPost* finalPost = [[GTLVerbatmAppPost alloc] init];
	finalPost.channelId = [NSNumber numberWithInteger:self.channelId];
	finalPost.sharedFromPostId = NULL; // this is the original post

	NSMutableArray* pages = [[NSMutableArray alloc] init]; // of GTLVerbatmAppPage
	NSMutableArray* images = [[NSMutableArray alloc] init]; // of GTLVerbatmAppImage
	NSMutableArray* videos = [[NSMutableArray alloc] init]; // of GTLVerbatmAppVideo


	AnyPromise* pagePromise = [self storePageFromPinchView:self.pinchViews[0] withPageNum:0];
	GTLVerbatmAppPage* page = [[GTLVerbatmAppPage alloc] init];
	page.pageNumberInPost = [NSNumber numberWithInteger:0];
	[pages addObject:page];

	for (int i = 1; i < self.pinchViews.count; i++) {
		PinchView* pinchView = self.pinchViews[i];
		GTLVerbatmAppPage* page = [[GTLVerbatmAppPage alloc] init];
		page.pageNumberInPost = [NSNumber numberWithInteger:i];
		[pages addObject:page];

		pagePromise = pagePromise.then(^(NSArray* result) {
			[images addObjectsFromArray:result[0]];
			[videos addObjectsFromArray:result[1]];
			return [self storePageFromPinchView:pinchView withPageNum:i];
		});
	}
	pagePromise.then(^(NSArray* result) {
		[images addObjectsFromArray:result[0]];
		[videos addObjectsFromArray:result[1]];

		GTLVerbatmAppPageListWrapper* pagesWrapper = [[GTLVerbatmAppPageListWrapper alloc] init];
		pagesWrapper.pages = pages;
		GTLVerbatmAppImageListWrapper* imagesWrapper = [[GTLVerbatmAppImageListWrapper alloc] init];
		imagesWrapper.images = images;
		GTLVerbatmAppVideoListWrapper* videosWrapper = [[GTLVerbatmAppVideoListWrapper alloc] init];
		videosWrapper.videos = videos;

		finalPost.pages = pagesWrapper;
		finalPost.images = imagesWrapper;
		finalPost.videos = videosWrapper;

		return [self insertPost: finalPost];
	}).catch(^(NSError *error){
		//This can catch at any part in the chain
		NSLog(@"Error publishing Post: %@", error.description);
		[self.publishingProgress cancel];
	});
}

- (void) publishReblog {
	//TODO
}

// Resolves to @[gtlImages, gtlVideos] from page, where gtlImages and gtlVideos are arrays
-(AnyPromise*) storePageFromPinchView: (PinchView*) pinchView withPageNum: (NSInteger) pageNum {
	NSLog(@"publishing page at index %ld", (long)pageNum);

	NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:2];
	return [self storeImagesFromPinchView:pinchView withPageNum: pageNum].then(^(NSArray* gtlImages) {
		[result addObject:gtlImages];
		return [self storeVideosFromPinchView:pinchView withPageNum:pageNum];
	}).then(^(NSArray* gtlVideos) {
		[result addObject:gtlVideos];
		return result;
	});
}

// when(stored every image)
// Each storeimage promise should resolve to a GTLVerbatmAppImage
// So this promise should resolve to an array of GTLVerbatmAppImage,
// or an empty array if the pinch view contains no images.
// Stores the images sequentially rather than in parallel because memory issues
-(AnyPromise*) storeImagesFromPinchView: (PinchView*) pinchView
							withPageNum: (NSInteger) pageNum {
	if (pinchView.containsImage) {
		//Publishing images sequentially
		NSArray* pinchViewPhotosWithText = [pinchView getPhotosWithText];
		NSMutableArray* gtlImages = [[NSMutableArray alloc] initWithCapacity: pinchViewPhotosWithText.count];

		AnyPromise* promise = [self storeImage:pinchViewPhotosWithText[0][0]
									 withIndex:0
									andPageNum: pageNum
									   andText:pinchViewPhotosWithText[0][1]
								  andYPosition:pinchViewPhotosWithText[0][2]];
		for (int i = 1; i < pinchViewPhotosWithText.count; i++){
			promise = promise.then(^(GTLVerbatmAppImage* gtlImage){
				NSLog(@"successfully published image at index %ld", (long)(i-1));
				[gtlImages addObject:gtlImage];
				NSArray* photoWithText = pinchViewPhotosWithText[i];
				UIImage* uiImage = photoWithText[0];
				NSString* text = photoWithText[1];
				NSNumber* textYPosition = photoWithText[2];
				return [self storeImage:uiImage
							  withIndex:i
							 andPageNum: pageNum
								andText:text
						   andYPosition:textYPosition];
			});
		}
		return promise.then(^(GTLVerbatmAppImage* gtlImage){
			[gtlImages addObject:gtlImage];
			return gtlImages;
		});
	} else {
		AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
			resolve([[NSArray alloc] init]);
		}];
		return promise;
	}
}

// when(stored every video)
// Each storevideo promise should resolve to a GTLVerbatmAppVideo
// So this promise should resolve to an array of GTLVerbatmAppVideo,
// or an empty array if the pinch view contains no videos.
// Stores the videos sequentially rather than in parallel because memory issues
-(AnyPromise*) storeVideosFromPinchView: (PinchView*) pinchView withPageNum: (NSInteger) pageNum {

	if (pinchView.containsVideo) {
		//Publishing videos sequentially
		NSArray* pinchViewVideosWithText = [pinchView getVideosWithText];
		NSMutableArray* gtlVideos = [[NSMutableArray alloc] initWithCapacity: pinchViewVideosWithText.count];
		AnyPromise* promise = [self storeVideoFromURL:[(AVURLAsset*)pinchViewVideosWithText[0][0] URL]
											  atIndex: 0
										   andPageNum: pageNum
											  andText: pinchViewVideosWithText[0][1]
										 andYPosition: pinchViewVideosWithText[0][2]];
		for (int i = 1; i < pinchViewVideosWithText.count; i++){
			promise = promise.then(^(GTLVerbatmAppVideo* gtlVideo){
				NSLog(@"successfully published video at index %ld", (long)(i-1));
				[gtlVideos addObject:gtlVideo];
				NSArray* videoWithText = pinchViewVideosWithText[i];
				AVURLAsset* videoAsset = videoWithText[0];
				NSString* text = videoWithText[1];
				NSNumber* textYPosition = videoWithText[2];
				return [self storeVideoFromURL:videoAsset.URL
									   atIndex: i
									andPageNum: pageNum
									   andText: text
								  andYPosition: textYPosition];
			});
		}
		return promise.then(^(GTLVerbatmAppVideo* gtlVideo){
			[gtlVideos addObject:gtlVideo];
			return gtlVideos;
		});
	} else {
		AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
			resolve([[NSArray alloc] init]);
		}];
		return promise;
	}
}

// (get image upload uri) then (upload image to blobstore using uri)
//then resolve to gtlImage containing serving url
-(AnyPromise*) storeImage: (UIImage*) image
				withIndex: (NSInteger) indexInPage
			   andPageNum: (NSInteger) pageNum
				  andText: (NSString*) text
			 andYPosition: (NSNumber*) textYPosition {
	NSLog(@"publishing image at index %ld", (long)indexInPage);

	return [self getImageUploadURI].then(^(NSString* uri) {
		self.imageUploader = [[MediaUploader alloc] initWithImage: image andUri:uri];
		if ([self.publishingProgress respondsToSelector:@selector(addChild:withPendingUnitCount:)]) {
			[self.publishingProgress addChild:self.imageUploader.mediaUploadProgress withPendingUnitCount: PROGRESS_UNITS_FOR_IMAGE];
		}
		return [self.imageUploader startUpload];
	}).then(^(NSString* servingURL) {
		GTLVerbatmAppImage* gtlImage = [[GTLVerbatmAppImage alloc] init];
		gtlImage.indexInPage = [[NSNumber alloc] initWithInteger: indexInPage];
		gtlImage.pageNum = [[NSNumber alloc] initWithInteger:pageNum];
		gtlImage.servingUrl = servingURL;
		gtlImage.text = text;
		gtlImage.textYPosition = textYPosition;

		if (![self.publishingProgress respondsToSelector:@selector(addChild:withPendingUnitCount:)]) {
			[self.publishingProgress setCompletedUnitCount:self.publishingProgress.completedUnitCount + PROGRESS_UNITS_FOR_IMAGE];
		}
		NSLog(@"Publishing progress updated to %ld out of %ld", (long)self.publishingProgress.completedUnitCount, (long)self.totalProgressUnits);

		return gtlImage;
	});
}

// (get video data from url + get video upload uri) then (upload video to blobstore using uri)
//then resolve to gtlVideo containing blobKeyString
-(AnyPromise*) storeVideoFromURL: (NSURL*) url
						 atIndex: (NSInteger)indexInPage
						 andPageNum: (NSInteger) pageNum
						 andText: (NSString*) text
					andYPosition: (NSNumber*) textYPosition {
	NSLog(@"publishing video at index %ld", (long)indexInPage);

	AnyPromise* getVideoDataPromise = [UtilityFunctions loadCachedDataFromURL: url];
	AnyPromise* getVideoUploadURIPromise = [self getVideoUploadURI];
	return PMKWhen(@[getVideoDataPromise, getVideoUploadURIPromise]).then(^(NSArray * results){
		NSData* videoData = results[0];
		NSString* uri = results[1];
		self.videoUploader = [[MediaUploader alloc] initWithVideoData:videoData andUri: uri];
		if ([self.publishingProgress respondsToSelector:@selector(addChild:withPendingUnitCount:)]) {
			[self.publishingProgress addChild:self.videoUploader.mediaUploadProgress withPendingUnitCount: PROGRESS_UNITS_FOR_VIDEO];
		}
		return [self.videoUploader startUpload];
	}).then(^(NSString* blobStoreKeyString) {
		GTLVerbatmAppVideo* gtlVideo = [[GTLVerbatmAppVideo alloc] init];
		gtlVideo.indexInPage = [[NSNumber alloc] initWithInteger: indexInPage];
		gtlVideo.pageNum = [NSNumber numberWithInteger:pageNum];
		gtlVideo.blobKeyString = blobStoreKeyString;
		gtlVideo.text = text;
		gtlVideo.textYPosition = textYPosition;

		if (![self.publishingProgress respondsToSelector:@selector(addChild:withPendingUnitCount:)]) {
			[self.publishingProgress setCompletedUnitCount:self.publishingProgress.completedUnitCount + PROGRESS_UNITS_FOR_VIDEO];
		}
		NSLog(@"Publishing progress updated to %ld out of %ld", (long)self.publishingProgress.completedUnitCount, (long)self.totalProgressUnits);

		return gtlVideo;
	});
}

#pragma mark - Insert post into cloud sql -

-(AnyPromise*) insertPost: (GTLVerbatmAppPost*) post {
	GTLQuery* insertPostQuery = [GTLQueryVerbatmApp queryForPostInsertPostWithObject:post];

	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
		[self.service executeQuery:insertPostQuery
				 completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppPost* post, NSError *error) {
					 if (error) {
						 resolve(error);
					 } else {
						 [self.publishingProgress setCompletedUnitCount: self.totalProgressUnits];
						 NSLog(@"Publishing progress updated to %ld out of %ld", (long)self.publishingProgress.completedUnitCount, (long)self.totalProgressUnits);
						 NSLog(@"Successfully published POV!");
						 [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_POV_PUBLISHED
																			 object:ticket];
						 resolve(post);
					 }
				 }];
	}];
	return promise;
}


#pragma mark - Get upload URIS -

// Queries for a uri from the blob store to upload images to
-(AnyPromise*) getImageUploadURI {
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self.service executeQuery:[GTLQueryVerbatmApp queryForPostGetImageUploadURI]
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
		[self.service executeQuery:[GTLQueryVerbatmApp queryForPostGetVideoUploadURI]
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
