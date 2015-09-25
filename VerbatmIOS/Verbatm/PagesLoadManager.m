//
//  PagesLoadManager.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/15/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//


#import "GTLQueryVerbatmApp.h"
#import "GTLServiceVerbatmApp.h"
#import "GTLVerbatmAppPageListWrapper.h"
#import "GTLVerbatmAppPage.h"
#import "GTLVerbatmAppImage.h"
#import "GTLVerbatmAppVideo.h"

#import "GTMHTTPFetcherLogging.h"

#import "PagesLoadManager.h"
#import "Page.h"

#import <PromiseKit/PromiseKit.h>

@interface PagesLoadManager()

@property(nonatomic, strong) GTLServiceVerbatmApp *service;

// Dict of key=POV id and value=Array of Page's
@property (strong, nonatomic) NSMutableDictionary* pagesForPOV;

//retains reference to media loaders since their tasks are performed async
@property (strong, nonatomic) NSMutableArray* mediaLoaders;

@end

@implementation PagesLoadManager

-(instancetype) init {
	self = [super init];
	if (self) {
	}
	return self;
}

- (NSArray*) getPagesForPOV: (NSNumber*) povID {
	NSArray* pages = [self.pagesForPOV objectForKey: povID];
	if (!pages) {
		NSLog(@"Error: getting pages that are not yet loaded");
	}
	return pages;
}


//TODO: think about way to load each page individually rather than all of them
// at once
/*
 Load the pages from the given pov ID.
 Then load the images and videos from each page
 Then store the array of page objects
 */
- (void) loadPagesForPOV: (NSNumber*) povID {
	[self loadPageListFromPOV:povID].then(^(GTLVerbatmAppPageListWrapper* pageList) {

		NSMutableArray* loadPagePromises = [[NSMutableArray alloc] init];
		for (GTLVerbatmAppPage* page in pageList.pages) {
			[loadPagePromises addObject: [self loadPageFromGTLPage: page]];
		}
		return PMKWhen(loadPagePromises);

	}).then(^(NSArray* pages) {
		[self.pagesForPOV setObject:pages forKey: povID];
		[self.delegate pagesLoadedForPOV: povID];
		self.mediaLoaders = nil;

	}).catch(^(NSError* error) {
		NSLog(@"Error loading pages from POV: %@", error.description);
		self.mediaLoaders = nil;
	});
}

//Queries for the pages from the given POV
//Returns a promise that resolves to either an error or the PageList from the POV
-(AnyPromise*) loadPageListFromPOV: (NSNumber*) povID {
	GTLQuery *pagesQuery = [GTLQueryVerbatmApp queryForPovGetPagesFromPOVWithIdentifier: povID.longLongValue];

	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self.service executeQuery:pagesQuery
				 completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppPageListWrapper* pageList, NSError *error) {
					 if (error) {
						 resolve(error);
					 } else {
						 resolve(pageList);
					 }
				 }];
	}];
	return promise;
}

// Resolves to a Page object from a GTLVerbatmAppPage
// Loads all the GTLVerbatmAppImage and Video objects and
// creates a Page object containing them.
-(AnyPromise*) loadPageFromGTLPage: (GTLVerbatmAppPage*) gtlPage {
	return PMKWhen(@[[self loadImagesForImageIDs: gtlPage.imageIds],
					 [self loadVideosFromVideoIDs: gtlPage.videoIds]]).then(^(NSArray* imagesAndVideos) {
		Page* page = [Page alloc];
		page.images = imagesAndVideos[0];
		page.videos = imagesAndVideos[1];
		page.indexInPOV = gtlPage.indexInPOV.integerValue;
		return page;
	});
}

// Resolves to array of GTLVerbatmAppImage's or error
-(AnyPromise*) loadImagesForImageIDs: (NSArray*) imageIDs {
	NSMutableArray* loadImagePromises = [[NSMutableArray array] init];
	for (NSNumber* imageID in imageIDs) {
		[loadImagePromises addObject:[self loadImageWithID: imageID]];
	}
	return PMKWhen(loadImagePromises).catch(^(NSError *error){
		//This can catch at any part in the chain
		NSLog(@"Error loading images: %@", error.description);
	});
}

// Resolves to array of GTLVerbatmAppVideo's or error
-(AnyPromise*) loadVideosFromVideoIDs: (NSArray*) videoIDs {
	NSMutableArray* loadVideoPromises = [[NSMutableArray array] init];
	for (NSNumber* videoID in videoIDs) {
		[loadVideoPromises addObject:[self loadVideoWithID: videoID]];
	}
	return PMKWhen(loadVideoPromises).catch(^(NSError *error){
		//This can catch at any part in the chain
		NSLog(@"Error loading videos: %@", error.description);
	});
}

//TODO: see if batch query speeds things up
//GTLBatchQuery* imagesBatchQuery = [GTLBatchQuery batchQuery];

//Queries for GTLVerbatmAppImage with given ID from server
//Resolves to GTLVerbatmAppImage or error
-(AnyPromise*) loadImageWithID: (NSNumber*) imageID {
	GTLQuery* loadImageQuery = [GTLQueryVerbatmApp queryForImageGetImageWithIdentifier: imageID.longLongValue];

	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self.service executeQuery: loadImageQuery
				 completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppImage* image, NSError *error) {
					 if (error) {
						 resolve(error);
					 } else {
						 resolve(image);
					 }
				 }];
	}];
	return promise;
}

//Queries for GTLVerbatmAppVideo with given ID from server
//Resolves to either GTLVerbatmAppVideo or error
-(AnyPromise*) loadVideoWithID: (NSNumber*) videoID {
	GTLQuery* loadVideoQuery = [GTLQueryVerbatmApp queryForVideoGetVideoWithIdentifier: videoID.longLongValue];

	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self.service executeQuery: loadVideoQuery
				 completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppVideo* video, NSError *error) {
					 if (error) {
						 resolve(error);
					 } else {
						 resolve(video);
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

-(NSDictionary*) pagesForPOV {
	if (!_pagesForPOV) {
		_pagesForPOV = [[NSMutableDictionary alloc] init];
	}
	return _pagesForPOV;
}

-(NSMutableArray*) mediaLoaders {
	if(!_mediaLoaders) {
		_mediaLoaders = [[NSMutableArray alloc] init];
	}
	return _mediaLoaders;
}


@end
