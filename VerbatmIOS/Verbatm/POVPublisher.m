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

#import "GTMHTTPFetcherLogging.h"

#import "Notifications.h"

#import "POVPublisher.h"
#import "PinchView.h"

@interface POVPublisher()

@property(nonatomic, strong) GTLServiceVerbatmApp *service;

@end

@implementation POVPublisher

- (void) publishPOVFromPinchViews: (NSArray*) pinchViews andTitle: (NSString*) title andCoverPic: (UIImage*) coverPic {

	GTLVerbatmAppPOV* povObject = [[GTLVerbatmAppPOV alloc] init];
	povObject.datePublished = [GTLDateTime dateTimeWithDate:[NSDate date] timeZone:[NSTimeZone localTimeZone]];
	povObject.numUpVotes = [NSNumber numberWithInt: 0];
	povObject.title = title;

	//TODO: change these
	povObject.coverPicUrl = @"coverPicUrl";
	povObject.creatorUserId = [NSNumber numberWithLongLong:1];

	GTLVerbatmAppPageListWrapper* pageListWrapper =  [[GTLVerbatmAppPageListWrapper alloc] init];
	NSMutableArray* pages = [[NSMutableArray alloc] init];
	for (int i = 0; i < [pinchViews count]; i++) {
		PinchView* pinchView = pinchViews[i];
		GTLVerbatmAppPage* page = [self sortPinchView:pinchView];
		page.indexInPOV = [NSNumber numberWithInt:i];
		[pages addObject: page];
	}

	pageListWrapper.pages = pages;
	GTLQuery* insertPagesQuery = [GTLQueryVerbatmApp queryForPageInsertPagesWithObject: pageListWrapper];

	[self.service executeQuery:insertPagesQuery completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppPageListWrapper* pageListWrapper, NSError *error) {
		if (error) {
			NSLog(@"Error uploading Pages: %@", error.description);
		} else {
			NSMutableArray* pageIds = [[NSMutableArray alloc] init];
			for (GTLVerbatmAppPage* page in pageListWrapper.pages) {
				NSNumber* pageId = page.identifier;
				[pageIds addObject: pageId];
			}
			povObject.pageIds = pageIds;
			[self insertPOV: povObject];
		}
	}];
}

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

//TODO: Go through pinch objects and save each image and video! (Get url from server and upload it to that url)
- (GTLVerbatmAppPage*) sortPinchView:(PinchView*)pinchView {

	GTLVerbatmAppPage* page = [[GTLVerbatmAppPage alloc] init];
	if(pinchView.containsImage) {

		NSMutableArray* gtlImages = [[NSMutableArray alloc] init];
		for (UIImage* uiimage in [pinchView getPhotos]) {
			// Store image in server and
			GTLVerbatmAppImage* gtlImage = [self getGTLImageFromUIImage: uiimage];
			[gtlImages addObject: gtlImage];
		}
//		page.imageIDs = ;

	} else {
		page.imageIds = nil;
	}

	if(pinchView.containsVideo) {

		NSMutableArray* gtlVideos = [[NSMutableArray alloc] init];
		for (AVAsset* videoAsset in [pinchView getVideos]) {
			GTLVerbatmAppVideo* gtlVideo = [self getGTLVideoFromAVAsset:videoAsset];
			[gtlVideos addObject: gtlVideo];
		}
//		page.videos = [[NSArray alloc] initWithArray:gtlVideos copyItems:YES];

	} else {
		page.videoIds = nil;
	}

	return page;
}

- (GTLVerbatmAppImage*) getGTLImageFromUIImage: (UIImage*) uiImage {
	GTLVerbatmAppImage* gtlImage = [[GTLVerbatmAppImage alloc] init];
	// TODO store image in blobstore and get url
	return gtlImage;
}

- (GTLVerbatmAppVideo*) getGTLVideoFromAVAsset: (AVAsset*) videoAsset {
	GTLVerbatmAppVideo* gtlVideo = [[GTLVerbatmAppVideo alloc] init];
	// TODO store video in blobstore and get url
	return gtlVideo;
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
