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

#import <Parse/PFObject.h>
#import "POVLoadManager.h"
#import "PhotoVideoAVE.h"
#import "PhotoAVE.h"
#import "PinchView.h"
#import "ParseBackendKeys.h"
#import "Photo_BackendObject.h"


#import "UtilityFunctions.h"

#import "VideoPinchView.h"
#import "VideoAVE.h"
#import "Video_BackendObject.h"

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

-(void) getAVEFromPage: (PFObject *)page withFrame: (CGRect) frame andCompletionBlock:(void(^)(ArticleViewingExperience *))block {
    
    AveTypes type = [((NSNumber *)[page valueForKey:PAGE_AVE_TYPE]) intValue];
    
    if(type == AveTypePhoto) {
        [self getUIImagesFromPage:page withCompletionBlock:^(NSMutableArray * imagesAndText) {
            
            PhotoAVE *photoAve = [[PhotoAVE alloc] initWithFrame:frame andPhotoArray:imagesAndText];
            photoAve.isPhotoVideoSubview = NO;
            
            block(photoAve);
        }];
    }else if (type == AveTypeVideo){
        [self getVideosFromPage:page withCompletionBlock:^(NSMutableArray * videoTextObjects) {
            
            VideoAVE *videoAve = [[VideoAVE alloc] initWithFrame:frame andVideoArray:videoTextObjects];
            
            block(videoAve);
        }];
        
        
    }else if( type == AveTypePhotoVideo){
        
        [self getVideosFromPage:page withCompletionBlock:^(NSMutableArray * videoTextObjects) {
            [self getUIImagesFromPage:page withCompletionBlock:^(NSMutableArray * imagesAndText) {
                PhotoVideoAVE *photoVideoAVE = [[PhotoVideoAVE alloc] initWithFrame:frame
                                                                          andPhotos:imagesAndText
                                                                          andVideos:videoTextObjects];
                
                block(photoVideoAVE);
            
            }];
        }];
        
    }
    
}

-(void) getUIImagesFromPage: (PFObject *) page withCompletionBlock:(void(^)(NSMutableArray *)) block{
    
    [Photo_BackendObject getPhotosForPage:page andCompletionBlock:^(NSArray * photoObjects) {
        
        NSMutableArray* loadImageDataPromises = [[NSMutableArray alloc] init];
        for (PFObject * photoBackendObject in photoObjects) {
            NSString * photoUrl = [photoBackendObject valueForKey:PHOTO_IMAGEURL_KEY];
            AnyPromise* getImageDataPromise = [UtilityFunctions loadCachedDataFromURL: [NSURL URLWithString:photoUrl]];
            [loadImageDataPromises addObject: getImageDataPromise];
        }
        PMKWhen(loadImageDataPromises).then(^(NSArray* results) {
            NSMutableArray* uiImages = [[NSMutableArray alloc] init];
            for (int i = 0; i < results.count; i++) {
                NSData* imageData = results[i];
                UIImage* uiImage = [UIImage imageWithData:imageData];
                PFObject * photoBO = photoObjects[i];
                
                NSString * imageText =  [photoBO valueForKey:PHOTO_TEXT_KEY];
                NSNumber * yoffset = [photoBO valueForKey:PHOTO_TEXT_YOFFSET_KEY];
                
                [uiImages addObject: @[uiImage, imageText, yoffset]];
            }
            block(uiImages);
        });
    }];
}

-(void) getVideosFromPage: (PFObject*) page withCompletionBlock:(void(^)(NSMutableArray *)) block{
    
    
    [Video_BackendObject getVideosForPage:page andCompletionBlock:^(NSArray * pfVideoObjectArray) {
        NSMutableArray* videoURLs = [[NSMutableArray alloc] init];
        for (PFObject * pfVideo in pfVideoObjectArray) {
            
            NSString * videoBlobKey = [pfVideo valueForKey:BLOB_STORE_URL];
            NSURLComponents *components = [NSURLComponents componentsWithString: GET_VIDEO_URI];
            NSURLQueryItem* blobKey = [NSURLQueryItem queryItemWithName:BLOBKEYSTRING_KEY value: videoBlobKey];
            components.queryItems = @[blobKey];
            NSLog(@"Requesting blobstore video with url: %@", components.URL.absoluteString);
            [videoURLs addObject: @[components.URL, @"", @(0)]];
        }
        block(videoURLs);
    }];
}

@end
