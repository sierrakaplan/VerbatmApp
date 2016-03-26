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


-(NSMutableArray*) getPageViewsFromPinchViews:(NSArray*) pinchViews withFrame:(CGRect)frame inPreviewMode: (BOOL) inPreviewMode {
	NSMutableArray* results = [[NSMutableArray alloc] init];
	for(PinchView* pinchView in pinchViews) {
		[results addObject:[self getPageViewFromPinchView:pinchView withFrame:frame inPreviewMode:inPreviewMode]];
	}
	return results;
}

-(PageViewingExperience *) getPageViewFromPinchView: (PinchView*) pinchView withFrame: (CGRect) frame inPreviewMode: (BOOL) inPreviewMode {
	if (pinchView.containsImage && pinchView.containsVideo) {
		PhotoVideoPVE *photoVideoPageView = [[PhotoVideoPVE alloc] initWithFrame:frame andPinchView:(CollectionPinchView *)pinchView inPreviewMode:inPreviewMode];
		return photoVideoPageView;

	} else if (pinchView.containsImage) {
		PhotoPVE *photoPageView = [[PhotoPVE alloc] initWithFrame:frame andPinchView:pinchView inPreviewMode:inPreviewMode];
		photoPageView.isPhotoVideoSubview = NO;
		return photoPageView;

	} else {
		VideoPVE *videoPageView = [[VideoPVE alloc] initWithFrame:frame andPinchView:pinchView inPreviewMode:inPreviewMode];
		return videoPageView;
	}
}

+(PageViewingExperience *)getPageViewFromPageMedia:(NSArray *)pageMedia withFrame:(CGRect)frame {
	PageTypes type = [pageMedia[0] intValue];//convert nsnumber back to our type
	if(type == PageTypePhoto) {
		PhotoPVE *photoPageView = [[PhotoPVE alloc] initWithFrame:frame andPhotoArray:pageMedia[1]];
		photoPageView.isPhotoVideoSubview = NO;
		return photoPageView;

	}else if (type == PageTypeVideo){
		return [[VideoPVE alloc] initWithFrame:frame andVideoWithTextArray:pageMedia[1]];

	} else if (type == PageTypePhotoVideo){
		return [[PhotoVideoPVE alloc] initWithFrame:frame
										  andPhotos:pageMedia[1]
										  andVideos:pageMedia[2]];
	}

	//should never reach here
	return nil;
}

-(void) getPageViewFromPage: (PFObject *)page withFrame: (CGRect) frame andCompletionBlock:(void(^)(NSArray *))block {

	PageTypes type = [((NSNumber *)[page valueForKey:PAGE_VIEW_TYPE]) intValue];

	if (type == PageTypePhoto) {
		[self getUIImagesFromPage:page withCompletionBlock:^(NSMutableArray * imagesAndText) {

			block(@[[NSNumber numberWithInt:type], imagesAndText]);
		}];
	} else if (type == PageTypeVideo){
		[self getVideosFromPage:page withCompletionBlock:^(NSMutableArray * videoTextObjects) {

			block(@[[NSNumber numberWithInt:type], videoTextObjects]);
		}];

	} else if( type == PageTypePhotoVideo){

		[self getVideosFromPage:page withCompletionBlock:^(NSMutableArray * videoTextObjects) {
			[self getUIImagesFromPage:page withCompletionBlock:^(NSMutableArray * imagesAndText) {
				block(@[[NSNumber numberWithInt:type], imagesAndText, videoTextObjects]);

			}];
		}];
	}
}

/* photoTextArray is array containing subarrays of photo and text info
 @[@[photo, text, textYPosition, textColor, textAlignment, textSize],...] */
-(void) getUIImagesFromPage: (PFObject *) page withCompletionBlock:(void(^)(NSMutableArray *)) block{

	[Photo_BackendObject getPhotosForPage:page andCompletionBlock:^(NSArray * photoObjects) {

		NSMutableArray* loadImageDataPromises = [[NSMutableArray alloc] init];
		for (PFObject * photoBackendObject in photoObjects) {
			NSString * photoUrl = [photoBackendObject valueForKey:PHOTO_IMAGEURL_KEY];
			AnyPromise* getImageDataPromise = [UtilityFunctions loadCachedPhotoDataFromURL: [NSURL URLWithString:photoUrl]];
			[loadImageDataPromises addObject: getImageDataPromise];
		}
		PMKWhen(loadImageDataPromises).then(^(NSArray* results) {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				NSMutableArray* uiImages = [[NSMutableArray alloc] init];
				for (int i = 0; i < results.count; i++) {
					NSData* imageData = results[i];
					if(![imageData isKindOfClass:[NSNull class]]){
						UIImage* uiImage = [UIImage imageWithData:imageData];
						PFObject *imageAndTextObj = photoObjects[i];

						NSString *text =  [imageAndTextObj valueForKey:PHOTO_TEXT_KEY];
						NSNumber *yOffset = [imageAndTextObj valueForKey:PHOTO_TEXT_YOFFSET_KEY];

						UIColor *textColor = [imageAndTextObj valueForKey:PHOTO_TEXT_COLOR_KEY];
						if (textColor == nil) textColor = [UIColor TEXT_PAGE_VIEW_DEFAULT_COLOR];
						NSNumber *textAlignment = [imageAndTextObj valueForKey:PHOTO_TEXT_ALIGNMENT_KEY];
						if (textAlignment == nil) textAlignment = [NSNumber numberWithInt:0];
						NSNumber *textSize = [imageAndTextObj valueForKey:PHOTO_TEXT_SIZE_KEY];
						if (textSize == nil) textSize = [NSNumber numberWithFloat:TEXT_PAGE_VIEW_DEFAULT_FONT_SIZE];

						[uiImages addObject: @[uiImage, text, yOffset, textColor, textAlignment, textSize]];
					}
				}
				dispatch_async(dispatch_get_main_queue(), ^{
					block(uiImages);
				});
			});
		});
	}];
}

-(void)getImagefromUrl:(NSMutableArray *) thumbnailUrls withCompletionBlock:(void(^)(NSArray *)) block {

	NSMutableArray* loadImageDataPromises = [[NSMutableArray alloc] init];

	for (NSString * url in thumbnailUrls) {
		AnyPromise* getImageDataPromise = [UtilityFunctions loadCachedPhotoDataFromURL: [NSURL URLWithString:url]];
		[loadImageDataPromises addObject: getImageDataPromise];
	}
	PMKWhen(loadImageDataPromises).then(^(NSArray* results) {
		block(results);
	});

}

-(void) getVideosFromPage: (PFObject*) page withCompletionBlock:(void(^)(NSMutableArray *)) block{
	[Video_BackendObject getVideosForPage:page andCompletionBlock:^(NSArray * pfVideoObjectArray) {
		NSMutableArray* videoURLs = [[NSMutableArray alloc] init];
		//get thumbnail urls for all videos
		for (PFObject * pfVideo in pfVideoObjectArray) {
			NSString * thumbNailUrl = [pfVideo valueForKey:VIDEO_THUMBNAIL_KEY];
			[videoURLs addObject:thumbNailUrl];
		}

		//download all thumbnail urls for videos
		[self getImagefromUrl:videoURLs withCompletionBlock:^(NSArray * videoThumbNails) {
			NSMutableArray * finalVideoObjects = [[NSMutableArray alloc] init];
			NSMutableArray * finalVideoUrls= [[NSMutableArray alloc] init];
			for (int i = 0; i < pfVideoObjectArray.count; i++) {
				PFObject * pfVideo = pfVideoObjectArray[i];
				NSString * videoBlobKey = [pfVideo valueForKey:BLOB_STORE_URL];
				NSURLComponents *components = [NSURLComponents componentsWithString: GET_VIDEO_URI];
				NSURLQueryItem* blobKey = [NSURLQueryItem queryItemWithName:BLOBKEYSTRING_KEY value: videoBlobKey];
				components.queryItems = @[blobKey];

				UIImage * thumbNail;
				if(i < videoThumbNails.count){
					thumbNail = [UIImage imageWithData:videoThumbNails[i]];
				}
				if(thumbNail){
					[finalVideoObjects addObject: @[components.URL, @"", @(0),thumbNail]];
					[finalVideoUrls addObject:components.URL];
				}else{
					[finalVideoObjects addObject: @[components.URL, @"", @(0)]];
					[finalVideoUrls addObject:components.URL];
				}
			}

			if(finalVideoUrls.count >1){
				//todo:
//				[[VideoDownloadManager sharedInstance] prepareVideoFromAsset_synchronous:finalVideoUrls];
			}else{
				[[VideoDownloadManager sharedInstance] downloadURL:[finalVideoUrls firstObject]];
			}

			block(finalVideoObjects);
		}];

	}];
}

@end
