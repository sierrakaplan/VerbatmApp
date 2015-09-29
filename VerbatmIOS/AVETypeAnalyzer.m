//
//  v_Analyzer.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "AVETypeAnalyzer.h"
#import "PinchView.h"
#import "CollectionPinchView.h"
#import "GTLVerbatmAppImage.h"
#import "GTLVerbatmAppVideo.h"
#import "ImagePinchView.h"
#import "VideoPinchView.h"
#import "VideoAVE.h"
#import "TextAVE.h"
#import "Page.h"
#import "POVLoadManager.h"
#import "PhotoVideoAVE.h"
#import "BaseArticleViewingExperience.h"

#import <PromiseKit/PromiseKit.h>

@interface AVETypeAnalyzer()

@property(nonatomic, strong) NSMutableArray* results;

#define GET_VIDEO_URI @"https://verbatmapp.appspot.com/serveVideo"
#define BLOBKEYSTRING_KEY @"blob-key"

@end


@implementation AVETypeAnalyzer

@synthesize results = _results;

-(NSMutableArray*) getAVESFromPinchViews:(NSArray*) pinchViews withFrame:(CGRect)frame {
	for(PinchView* pinchView in pinchViews) {
		//there are some issue where a messed up p_obj arrives
		if(!(pinchView.containsImage || pinchView.containsVideo)) {
//			NSLog(@"Pinch view says it has no type of media in it.");
			continue;
		}

		[self getAVEFromPinchView:pinchView withFrame:frame];
	}

	return self.results;
}

-(NSMutableArray*) getAVESFromPages: (NSArray*) pages withFrame: (CGRect) frame {
	for (Page* page in pages) {
		AVEType type;

		if (page.images.count && page.videos.count) {
			type = AVETypePhotoVideo;
		} else if (page.images.count) {
			type = AVETypePhoto;
		} else if(page.videos.count) {
			type = AVETypeVideo;
		}

		[self getUIImagesFromPage: page].then(^(NSArray* images) {
			BaseArticleViewingExperience * textAndOtherMediaAVE = [[BaseArticleViewingExperience alloc] initWithFrame:frame andText:nil andPhotos:images andVideos:[self getVideosFromPage: page] andAVEType:type];
			[self.results addObject:textAndOtherMediaAVE];
		});
	}
	return self.results;
}

-(AnyPromise*) getAVEFromPage: (Page*) page withFrame: (CGRect) frame {
	AVEType type;

	if (page.images.count && page.videos.count) {
		type = AVETypePhotoVideo;
	} else if (page.images.count) {
		type = AVETypePhoto;
	} else if(page.videos.count) {
		type = AVETypeVideo;
	}

	return [self getUIImagesFromPage: page].then(^(NSArray* images) {
		BaseArticleViewingExperience * textAndOtherMediaAVE = [[BaseArticleViewingExperience alloc] initWithFrame: frame andText:nil andPhotos:images andVideos:[self getVideosFromPage: page] andAVEType:type];
		return textAndOtherMediaAVE;
	});
}

-(AnyPromise*) getUIImagesFromPage: (Page*) page {

	NSMutableArray* loadImageDataPromises = [[NSMutableArray alloc] init];
	for (GTLVerbatmAppImage* image in page.images) {

		AnyPromise* getImageDataPromise = [POVLoadManager loadDataFromURL: image.servingUrl];
		[loadImageDataPromises addObject: getImageDataPromise];
	}
	return PMKWhen(loadImageDataPromises).then(^(NSArray* results) {
		NSMutableArray* uiImages = [[NSMutableArray alloc] init];
		for (NSData* imageData in results) {
			UIImage* uiImage = [UIImage imageWithData:imageData];
			[uiImages addObject: uiImage];
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
		[videoURLs addObject: components.URL];
	}
	return videoURLs;
}

-(void) getAVEFromPinchView: (PinchView*) pinchView withFrame: (CGRect) frame {

	AVEType type;

	if (pinchView.containsImage && pinchView.containsVideo) {
		type = AVETypePhotoVideo;
	} else if (pinchView.containsImage) {
		type = AVETypePhoto;
	} else if(pinchView.containsVideo) {
		type = AVETypeVideo;
	}

	BaseArticleViewingExperience * textAndOtherMediaAVE = [[BaseArticleViewingExperience alloc] initWithFrame:frame andText:@"" andPhotos:[pinchView getPhotos] andVideos:[pinchView getVideos] andAVEType:type];
	[self.results addObject:textAndOtherMediaAVE];
}


#pragma  mark - Lazy Instantiation

-(NSMutableArray*) results {
	if (!_results) {
		_results =  [[NSMutableArray alloc] init];
	}
	return _results;
}

@end
