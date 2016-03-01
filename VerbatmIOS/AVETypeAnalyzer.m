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
#import "VideoDownloadManager.h"

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



+(ArticleViewingExperience *)getAVEFromPageMedia:(NSArray *)pageMedia withFrame:(CGRect)frame {
    AveTypes type = [pageMedia[0] intValue];//convert nsnumber back to our type
    if(type == AveTypePhoto) {
            PhotoAVE *photoAve = [[PhotoAVE alloc] initWithFrame:frame andPhotoArray:pageMedia[1]];
            photoAve.isPhotoVideoSubview = NO;
        return photoAve;
        
    }else if (type == AveTypeVideo){
        
            return [[VideoAVE alloc] initWithFrame:frame andVideoArray:pageMedia[1]];
            
        
        
    }else if( type == AveTypePhotoVideo){
                return [[PhotoVideoAVE alloc] initWithFrame:frame
                                            andPhotos:pageMedia[1]
                                            andVideos:pageMedia[2]];
                
       
        
    }
    
    //should never reach here
    return nil;
}


-(void) getAVEFromPage: (PFObject *)page withFrame: (CGRect) frame andCompletionBlock:(void(^)(NSArray *))block {
    
    AveTypes type = [((NSNumber *)[page valueForKey:PAGE_AVE_TYPE]) intValue];
    
    if(type == AveTypePhoto) {
        [self getUIImagesFromPage:page withCompletionBlock:^(NSMutableArray * imagesAndText) {
            
             block(@[[NSNumber numberWithInt:type], imagesAndText]);
        }];
    }else if (type == AveTypeVideo){
        [self getVideosFromPage:page withCompletionBlock:^(NSMutableArray * videoTextObjects) {
            
            block(@[[NSNumber numberWithInt:type], videoTextObjects]);
        }];
        
        
    }else if( type == AveTypePhotoVideo){
        
        [self getVideosFromPage:page withCompletionBlock:^(NSMutableArray * videoTextObjects) {
            [self getUIImagesFromPage:page withCompletionBlock:^(NSMutableArray * imagesAndText) {
                block(@[[NSNumber numberWithInt:type], imagesAndText, videoTextObjects]);
            
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
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSMutableArray* uiImages = [[NSMutableArray alloc] init];
                for (int i = 0; i < results.count; i++) {
                    NSData* imageData = results[i];
                    
                    if(![imageData isKindOfClass:[NSNull class]]){
                        UIImage* uiImage = [UIImage imageWithData:imageData];
                        PFObject * photoBO = photoObjects[i];
                        
                        NSString * imageText =  [photoBO valueForKey:PHOTO_TEXT_KEY];
                        NSNumber * yoffset = [photoBO valueForKey:PHOTO_TEXT_YOFFSET_KEY];
                        
                        [uiImages addObject: @[uiImage, imageText, yoffset]];
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
        AnyPromise* getImageDataPromise = [UtilityFunctions loadCachedDataFromURL: [NSURL URLWithString:url]];
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
                NSLog(@"Requesting blobstore video with url: %@", components.URL.absoluteString);
                if(i < videoThumbNails.count){
                    [finalVideoObjects addObject: @[components.URL, @"", @(0), [UIImage imageWithData:videoThumbNails[i]]]];
                    [finalVideoUrls addObject:components.URL];
                }else{
                    [finalVideoObjects addObject: @[components.URL, @"", @(0)]];
                    [finalVideoUrls addObject:components.URL];
                }
            }
            
            //register the videos in our video
            if(finalVideoUrls.count >1){
                [[VideoDownloadManager sharedInstance] prepareVideoFromAsset_synchronous:finalVideoUrls];
            }else{
                [[VideoDownloadManager sharedInstance] prepareVideoFromURL_synchronous:[finalVideoUrls firstObject]];
            }
            block(finalVideoObjects);
        }];
        
    }];
}

@end
