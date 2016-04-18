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
		return [[VideoPVE alloc] initWithFrame:frame andVideo:pageMedia[1][0] andThumbnail:pageMedia[1][1]];

	} else if (type == PageTypePhotoVideo){
		return [[PhotoVideoPVE alloc] initWithFrame:frame
										  andPhotos:pageMedia[1]
										   andVideo:pageMedia[2][0] andVideoThumbnail:pageMedia[2][1]];
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
 @[@[url, text, textYPosition, textColor, textAlignment, textSize],...] */
-(void) getUIImagesFromPage: (PFObject *) page withCompletionBlock:(void(^)(NSMutableArray *)) block{

	[Photo_BackendObject getPhotosForPage:page andCompletionBlock:^(NSArray * photoObjects) {

		NSMutableArray* uiImages = [[NSMutableArray alloc] init];

		for (PFObject * imageAndTextObj in photoObjects) {
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

			[uiImages addObject: @[photoURL, text, yOffset, textColor, textAlignment, textSize]];

			dispatch_async(dispatch_get_main_queue(), ^{
				block(uiImages);
			});
		}
	}];
}

-(void)getImagesfromUrls:(NSArray *) thumbnailUrls withCompletionBlock:(void(^)(NSArray *)) block {

	NSMutableArray* loadImageDataPromises = [[NSMutableArray alloc] init];

	for (NSString * url in thumbnailUrls) {
		AnyPromise* getImageDataPromise = [UtilityFunctions loadCachedPhotoDataFromURL: [NSURL URLWithString:url]];
		[loadImageDataPromises addObject: getImageDataPromise];
	}
	PMKWhen(loadImageDataPromises).then(^(NSArray* results) {
		block(results);
	});

}

//Video array looks like @[URL, thumbnail]
-(void) getVideoFromPage: (PFObject*) page withCompletionBlock:(void(^)(NSArray *)) block{
	[Video_BackendObject getVideoForPage:page andCompletionBlock:^(PFObject *videoObject) {
		//get thumbnail url for video
		NSString * thumbNailUrl = [videoObject valueForKey:VIDEO_THUMBNAIL_KEY];

		//download all thumbnail urls for videos
		[self getImagesfromUrls:@[thumbNailUrl] withCompletionBlock:^(NSArray * videoThumbNails) {
			NSString * videoBlobKey = [videoObject valueForKey:BLOB_STORE_URL];
			NSURLComponents *components = [NSURLComponents componentsWithString: GET_VIDEO_URI];
			NSURLQueryItem* blobKey = [NSURLQueryItem queryItemWithName:BLOBKEYSTRING_KEY value: videoBlobKey];
			components.queryItems = @[blobKey];

			UIImage * thumbNail = [UIImage imageWithData:videoThumbNails[0]];
			[[VideoDownloadManager sharedInstance] downloadURL:components.URL];
			block(@[components.URL, thumbNail]);
		}];
		
	}];
}

@end
