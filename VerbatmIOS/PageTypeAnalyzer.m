//
//  v_Analyzer.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "PageTypeAnalyzer.h"
#import <PromiseKit/PromiseKit.h>

#import "CollectionPinchView.h"

#import "GTLVerbatmAppImage.h"
#import "GTLVerbatmAppVideo.h"

#import "ImagePinchView.h"

#import <Parse/PFObject.h>
#import "PhotoVideoPVE.h"
#import "PhotoPVE.h"
#import "PinchView.h"
#import "ParseBackendKeys.h"
#import "Photo_BackendObject.h"

#import "Styles.h"

#import "UtilityFunctions.h"

#import "VideoPinchView.h"
#import "VideoPVE.h"
#import "Video_BackendObject.h"
#import "VideoDownloadManager.h"

@interface PageTypeAnalyzer()

#define GET_VIDEO_URI @"https://verbatmapp.appspot.com/serveVideo"
#define BLOBKEYSTRING_KEY @"blob-key"

@end


@implementation PageTypeAnalyzer


+(NSMutableArray*) getPageViewsFromPinchViews:(NSArray*) pinchViews withFrame:(CGRect)frame inPreviewMode: (BOOL) inPreviewMode {
	NSMutableArray* results = [[NSMutableArray alloc] init];
	for(int i = 0; i < pinchViews.count; i++) {
		PinchView *pinchView = pinchViews[i];
		PageViewingExperience *pageView = [self getPageViewFromPinchView:pinchView withFrame:frame inPreviewMode:inPreviewMode];
		pageView.indexInPost = i;
		[results addObject:pageView];
	}
	return results;
}

+(PageViewingExperience *) getPageViewFromPinchView: (PinchView*) pinchView withFrame: (CGRect) frame inPreviewMode: (BOOL) inPreviewMode {
	if (pinchView.containsImage && pinchView.containsVideo) {
		PhotoVideoPVE *photoVideoPageView = [[PhotoVideoPVE alloc] initWithFrame:frame andPinchView:(CollectionPinchView *)pinchView inPreviewMode:inPreviewMode];
		return photoVideoPageView;

	} else if (pinchView.containsImage) {
		PhotoPVE *photoPageView = [[PhotoPVE alloc] initWithFrame:frame andPinchView:pinchView inPreviewMode:inPreviewMode isPhotoVideoSubview:NO];
		return photoPageView;

	} else {
		VideoPVE *videoPageView = [[VideoPVE alloc] initWithFrame:frame andPinchView:pinchView inPreviewMode:inPreviewMode
											  isPhotoVideoSubview:NO];
		return videoPageView;
	}
}

+(void) getPageMediaFromPage: (PFObject *)page withCompletionBlock:(void(^)(NSArray *))block {
	PageTypes type = [((NSNumber *)[page valueForKey:PAGE_VIEW_TYPE]) intValue];
	if (type == PageTypePhoto) {
		[self getUIImagesFromPage:page withCompletionBlock:^(NSMutableArray * imagesAndText) {
			block(@[[NSNumber numberWithInt:type], imagesAndText]);
		}];
	} else if (type == PageTypeVideo){
		[self getVideoFromPage:page withCompletionBlock:^(NSArray *videoAndThumbnail) {
			block(@[[NSNumber numberWithInt:type], videoAndThumbnail]);
		}];
	} else if( type == PageTypePhotoVideo){
		[self getVideoFromPage:page withCompletionBlock:^(NSArray *videoAndThumbnail) {
			[self getUIImagesFromPage:page withCompletionBlock:^(NSMutableArray* imagesAndText) {
				block(@[[NSNumber numberWithInt:type], imagesAndText, videoAndThumbnail]);
			}];
		}];
	}
}

/* photoTextArray is array containing subarrays of photo and text info
 @[@[url, uiimage, text, textYPosition, textColor, textAlignment, textSize],...] */
+(void) getUIImagesFromPage: (PFObject *) page withCompletionBlock:(void(^)(NSMutableArray *)) block{

	[Photo_BackendObject getPhotosForPage:page andCompletionBlock:^(NSArray * photoObjects) {

		NSMutableArray* imageUrls = [[NSMutableArray alloc] init];
		for (PFObject * imageAndTextObj in photoObjects) {
			NSString * photoUrlString = [imageAndTextObj valueForKey:PHOTO_IMAGEURL_KEY];
			// Don't want high quality image for this - just loading thumbnails
			[imageUrls addObject: photoUrlString];
		}

		[self getThumbnailDatafromUrls:imageUrls withCompletionBlock:^(NSArray *imageData) {
			NSMutableArray* imageTextArrays = [[NSMutableArray alloc] init];
			for (int i = 0; i < photoObjects.count; i++) {
				PFObject * imageAndTextObj = photoObjects[i];
				NSString * photoUrlString = [imageAndTextObj valueForKey:PHOTO_IMAGEURL_KEY];

				NSURL *photoURL = [NSURL URLWithString:photoUrlString];

				NSString *text =  [imageAndTextObj valueForKey:PHOTO_TEXT_KEY];
				NSNumber *yOffset = [imageAndTextObj valueForKey:PHOTO_TEXT_YOFFSET_KEY];

				NSData *textColorData = [imageAndTextObj valueForKey:PHOTO_TEXT_COLOR_KEY];
				UIColor *textColor = textColorData == nil ? nil : [NSKeyedUnarchiver unarchiveObjectWithData:textColorData];
				if (textColor == nil) textColor = [UIColor TEXT_PAGE_VIEW_DEFAULT_COLOR];
				NSNumber *textAlignment = [imageAndTextObj valueForKey:PHOTO_TEXT_ALIGNMENT_KEY];
				if (textAlignment == nil) textAlignment = [NSNumber numberWithInt:0];
				NSNumber *textSize = [imageAndTextObj valueForKey:PHOTO_TEXT_SIZE_KEY];
				if (textSize == nil) textSize = [NSNumber numberWithFloat:TEXT_PAGE_VIEW_DEFAULT_FONT_SIZE];

				[imageTextArrays addObject: @[photoURL, [UIImage imageWithData:imageData[i]], text,
											  yOffset, textColor, textAlignment, textSize]];
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				block(imageTextArrays);
			});
		}];
	}];
}

+(void)getThumbnailDatafromUrls:(NSArray *)urls withCompletionBlock:(void(^)(NSArray *)) block {

	NSMutableArray* loadImageDataPromises = [[NSMutableArray alloc] init];
	for (NSString *uri in urls) {
		NSString *smallImageUri = uri;
		NSString * suffix = @"=s0";
		if ([uri hasSuffix:suffix] ) {
			smallImageUri = [uri substringWithRange:NSMakeRange(0, uri.length-suffix.length)];
		}

		AnyPromise* getImageDataPromise = [UtilityFunctions loadCachedPhotoDataFromURL: [NSURL URLWithString: smallImageUri]];
		[loadImageDataPromises addObject: getImageDataPromise];
	}
	PMKWhen(loadImageDataPromises).then(^(NSArray* results) {
		block(results);
	});

}

//Video array looks like @[URL, thumbnail]
+(void) getVideoFromPage: (PFObject*) page withCompletionBlock:(void(^)(NSArray *)) block{
	[Video_BackendObject getVideoForPage:page andCompletionBlock:^(PFObject *videoObject) {
		//get thumbnail url for video
		NSString * thumbNailUrl = [videoObject valueForKey:VIDEO_THUMBNAIL_KEY];

		//download all thumbnail urls for videos
		[self getThumbnailDatafromUrls:@[thumbNailUrl] withCompletionBlock:^(NSArray * videoThumbNails) {
			NSString * videoBlobKey = [videoObject valueForKey:BLOB_STORE_URL];
			NSURLComponents *components = [NSURLComponents componentsWithString: GET_VIDEO_URI];
			NSURLQueryItem* blobKey = [NSURLQueryItem queryItemWithName:BLOBKEYSTRING_KEY value: videoBlobKey];
			components.queryItems = @[blobKey];

			UIImage * thumbNail = [UIImage imageWithData:videoThumbNails[0]];
			//todo: see if downloading videos can be made better
//			[[VideoDownloadManager sharedInstance] downloadURL:components.URL];
			block(@[components.URL, thumbNail]);
		}];
		
	}];
}

@end
