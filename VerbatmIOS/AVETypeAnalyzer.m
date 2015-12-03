//
//  v_Analyzer.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "AVETypeAnalyzer.h"
#import <PromiseKit/PromiseKit.h>

#import "CollectionPinchView.h"

#import "GTLVerbatmAppImage.h"
#import "GTLVerbatmAppVideo.h"

#import "ImagePinchView.h"

#import "Page.h"
#import "POVLoadManager.h"
#import "PhotoVideoAVE.h"
#import "PhotoAVE.h"
#import "PinchView.h"

#import "UtilityFunctions.h"

#import "VideoPinchView.h"
#import "VideoAVE.h"

@interface AVETypeAnalyzer()

#define GET_VIDEO_URI @"https://verbatmapp.appspot.com/serveVideo"
#define BLOBKEYSTRING_KEY @"blob-key"

@end


@implementation AVETypeAnalyzer


-(NSMutableArray*) getAVESFromPinchViews:(NSArray*) pinchViews withFrame:(CGRect)frame inPreviewMode: (BOOL) inPreviewMode {
	NSMutableArray* results = [[NSMutableArray alloc] init];
	for(PinchView* pinchView in pinchViews) {
		[results addObject:[self getAVEFromPinchView:pinchView withFrame:frame inPreviewMode:inPreviewMode]];
	}
	return results;
}

-(ArticleViewingExperience*) getAVEFromPinchView: (PinchView*) pinchView withFrame: (CGRect) frame inPreviewMode: (BOOL) inPreviewMode {
	if (pinchView.containsImage && pinchView.containsVideo) {
		PhotoVideoAVE *photoVideoAVE = [[PhotoVideoAVE alloc] initWithFrame:frame andPinchView:(CollectionPinchView *)pinchView inPreviewMode:inPreviewMode];
		return photoVideoAVE;

	} else if (pinchView.containsImage) {
		PhotoAVE * photoAve = [[PhotoAVE alloc] initWithFrame:frame andPinchView:pinchView inPreviewMode:inPreviewMode];
		photoAve.isPhotoVideoSubview = NO;
		return photoAve;

	} else {
		VideoAVE *videoAve = [[VideoAVE alloc] initWithFrame:frame andPinchView:pinchView inPreviewMode:inPreviewMode];
		return videoAve;
	}
}

-(AnyPromise*) getAVEFromPage: (Page*)page withFrame: (CGRect) frame {
	if (page.images.count && page.videos.count) {
		return [self getUIImagesFromPage: page].then(^(NSArray* imagesAndText) {
			PhotoVideoAVE *photoVideoAVE = [[PhotoVideoAVE alloc] initWithFrame:frame andPhotos:imagesAndText
																	  andVideos:[self getVideosFromPage: page]];
			return photoVideoAVE;
		});

	} else if (page.images.count) {
		return [self getUIImagesFromPage: page].then(^(NSArray* imagesAndText) {
			PhotoAVE *photoAve = [[PhotoAVE alloc] initWithFrame:frame andPhotoArray:imagesAndText];
			photoAve.isPhotoVideoSubview = NO;
			return photoAve;
		});

	} else {
		return [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
			VideoAVE *videoAve = [[VideoAVE alloc] initWithFrame:frame andVideoArray:[self getVideosFromPage: page]];
			resolve(videoAve);
		}];
	}
}

-(AnyPromise*) getUIImagesFromPage: (Page*) page {

	NSMutableArray* loadImageDataPromises = [[NSMutableArray alloc] init];
	for (GTLVerbatmAppImage* image in page.images) {
		AnyPromise* getImageDataPromise = [UtilityFunctions loadCachedDataFromURL: [NSURL URLWithString:image.servingUrl]];
		[loadImageDataPromises addObject: getImageDataPromise];
	}
	return PMKWhen(loadImageDataPromises).then(^(NSArray* results) {
		NSMutableArray* uiImages = [[NSMutableArray alloc] init];
		for (int i = 0; i < results.count; i++) {
			NSData* imageData = results[i];
			GTLVerbatmAppImage* gtlImage = page.images[i];
			UIImage* uiImage = [UIImage imageWithData:imageData];
			if (!gtlImage.text) {
				gtlImage.text = @"";
			}
			if (!gtlImage.textYPosition) {
				gtlImage.textYPosition = [NSNumber numberWithFloat: 0.f];
			} 
			[uiImages addObject: @[uiImage, gtlImage.text, gtlImage.textYPosition]];
		}
		return uiImages;
	});
}

-(NSArray*) getVideosFromPage: (Page*) page {
	NSMutableArray* videoURLs = [[NSMutableArray alloc] init];
	for (GTLVerbatmAppVideo* video in page.videos) {
		NSURLComponents *components = [NSURLComponents componentsWithString: GET_VIDEO_URI];
		NSURLQueryItem* blobKey = [NSURLQueryItem queryItemWithName:BLOBKEYSTRING_KEY value: video.blobKeyString];
		components.queryItems = @[blobKey];
//		NSLog(@"Requesting blobstore video with url: %@", components.URL.absoluteString);
		if (!video.text) {
			video.text = @"";
		}
		if (!video.textYPosition) {
			video.textYPosition = [NSNumber numberWithFloat: 0.f];
		}
		[videoURLs addObject: @[components.URL, video.text, video.textYPosition]];
	}
	return videoURLs;
}

@end
