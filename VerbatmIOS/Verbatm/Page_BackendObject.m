//
//  Page_BackendObject.m
//  Verbatm
//
//  Created by Iain Usiri on 1/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "CollectionPinchView.h"
#import <Crashlytics/Crashlytics.h>

#import "ImagePinchView.h"

#import "PageTypeAnalyzer.h"
#import <Parse/PFQuery.h>
#import <Parse/PFRelation.h>
#import "Page_BackendObject.h"
#import "ParseBackendKeys.h"
#import "Photo_BackendObject.h"
#import "Video_BackendObject.h"
#import "UtilityFunctions.h"

@interface Page_BackendObject ()

@property (strong) NSMutableArray * photoAndVideoSavers;

@end

@implementation Page_BackendObject

-(instancetype)init{
	self = [super init];
	if(self){
		self.photoAndVideoSavers = [[NSMutableArray alloc] init];
	}
	return self;
}

-(AnyPromise*) savePageWithIndex:(NSInteger) pageIndex andPinchView:(PinchView *) pinchView andPost:(PFObject *) post {

	//create and save page object
	PFObject * newPageObject = [PFObject objectWithClassName:PAGE_PFCLASS_KEY];
	[newPageObject setObject:[NSNumber numberWithInteger:pageIndex] forKey:PAGE_INDEX_KEY];
	[newPageObject setObject:post forKey:PAGE_POST_KEY];

	if (pinchView.containsImage && pinchView.containsVideo) {
		[newPageObject setObject:[NSNumber numberWithInt:PageTypePhotoVideo] forKey:PAGE_VIEW_TYPE];

	} else if (pinchView.containsImage) {
		[newPageObject setObject:[NSNumber numberWithInt:PageTypePhoto] forKey:PAGE_VIEW_TYPE];
	} else {
		[newPageObject setObject:[NSNumber numberWithInt:PageTypeVideo] forKey:PAGE_VIEW_TYPE];
	}

	return [self savePageObject:newPageObject withPostObkect:post].then(^(void) {
		return [self storeImagesFromPinchView:pinchView withPageReference:newPageObject];
	}).then(^(NSError *error) {
		if (error) {
			return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
				resolve(error);
			}];
		}
		return [self storeVideosFromPinchView:pinchView withPageReference:newPageObject];
	});
}

-(AnyPromise*) savePageObject: (PFObject*)newPageObject withPostObkect:(PFObject *) post {
	return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
        [newPageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
			if(succeeded){//now we save the media for the specific
                PFRelation * pageRelation = [post relationForKey:POST_PAGES_PFRELATION];
                [pageRelation addObject:newPageObject];
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(succeeded){
                        resolve (newPageObject);
                    }else resolve(error);
                }];
			}
		}];
	}];
}


// when(stored every image)
// Each storeimage promise should resolve to the id of the GTL Image just stored
// So this promise should resolve to an array of gtl image id's
-(AnyPromise*) storeImagesFromPinchView: (PinchView*) pinchView withPageReference:(PFObject *) page {
	if (!pinchView.containsImage) return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
		resolve(nil);
	}];

	NSArray* pinchViewPhotosWithText = [pinchView getPhotosWithText];
	NSMutableArray *imagePinchViews = [[NSMutableArray alloc] init];
	BOOL half = NO;
	if (pinchView.containsImage && pinchView.containsVideo) {
		half = YES;
	}
	if ([pinchView isKindOfClass:[ImagePinchView class]]) {
		[imagePinchViews addObject:(ImagePinchView*) pinchView];
	} else if (pinchView.containsImage) {
		imagePinchViews = ((CollectionPinchView*)pinchView).imagePinchViews;
	}

	//Publishing images sequentially
    ((PinchView *)imagePinchViews[0]).beingPublished = YES;
	AnyPromise *getImageDataPromise = [imagePinchViews[0] getImageDataWithHalfSize:half];
	for (int i = 1; i < imagePinchViews.count; i++) {
		getImageDataPromise = getImageDataPromise.then(^(NSData *imageData) {
            
			NSArray* photoWithText = pinchViewPhotosWithText[i-1];
            
			return [self storeImageFromImageData:imageData andPhotoWithTextArray:photoWithText
										 atIndex:i withPageObject:page].then(^(void) {
                
                ((PinchView *)imagePinchViews[i]).beingPublished = YES;
				return [imagePinchViews[i] getImageDataWithHalfSize:half];
                
			});
            
		});
	}
	return getImageDataPromise.then(^(NSData *imageData) {
		NSInteger index = imagePinchViews.count - 1;
		NSArray* photoWithText = pinchViewPhotosWithText[index];
		return [self storeImageFromImageData:imageData andPhotoWithTextArray:photoWithText
									 atIndex:index withPageObject:page];
	});
}

-(AnyPromise*) storeImageFromImageData: (NSData *) imageData andPhotoWithTextArray: (NSArray *)photoWithText
							   atIndex: (NSInteger) index withPageObject: (PFObject *) page {
	NSString* text = photoWithText[1];
	NSNumber* textYPosition = photoWithText[2];
	UIColor *textColor = photoWithText[3];
	NSNumber *textAlignment = photoWithText[4];
	NSNumber *textSize = photoWithText[5];

	Photo_BackendObject * photoObj = [[Photo_BackendObject alloc] init];
	[self.photoAndVideoSavers addObject:photoObj];
	return [photoObj saveImageData:imageData withText:text
				  andTextYPosition:textYPosition
					  andTextColor:textColor
				  andTextAlignment:textAlignment
					   andTextSize:textSize
					  atPhotoIndex:index
					 andPageObject:page];
}

-(AnyPromise*) storeVideosFromPinchView: (PinchView*) pinchView withPageReference:(PFObject *) page{
	if (!pinchView.containsVideo) return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
		resolve(nil);
	}];

	Video_BackendObject *videoObj = [[Video_BackendObject alloc] init];
	[self.photoAndVideoSavers addObject:videoObj];

	AVAsset* videoAsset = [pinchView getVideo];
	if (![videoAsset isKindOfClass:[AVURLAsset class]]) {
		NSString *videoFileName = [UtilityFunctions randomStringWithLength:10];
		NSURL* exportURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@%@", NSTemporaryDirectory(), videoFileName, @".mp4"]];
		AVAssetExportSession* exporter = [[AVAssetExportSession alloc] initWithAsset:videoAsset
																		  presetName:AVAssetExportPresetPassthrough];

		[exporter setOutputURL:exportURL];
		[exporter setOutputFileType:AVFileTypeMPEG4];
		return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
			[exporter exportAsynchronouslyWithCompletionHandler:^(void){
				//todo: add progress units for this part
				resolve(exportURL);
			}];
		}].then(^(NSURL* exportURL) {
			return [videoObj saveVideo:exportURL andPageObject:page];
		});
	} else {
		return [videoObj saveVideo:((AVURLAsset *)videoAsset).URL andPageObject:page];
	}
}

+(void)savePageToPFRelation:(PFObject *) page andPost:(PFObject *) post{
    PFRelation * postRelation = [post relationForKey:POST_PAGES_PFRELATION];
    [postRelation addObject:page];
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            NSLog(@"saved new post relation");
        }else NSLog(@"Failed to save new post relation");
    }];
    
}



+(void)getPagesFromPost:(PFObject *) post andCompletionBlock:(void(^)(NSArray *))block {

    PFQuery *pageQuery = [PFQuery queryWithClassName:PAGE_PFCLASS_KEY];
    [pageQuery whereKey:PAGE_POST_KEY equalTo:post];
    pageQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    BOOL __block isCacheResponse = YES;
    BOOL __block cacheResponsePassed = NO;
    //the cache policy makes our block get called twice. First time is always cache and second time
    //is always network.
    [pageQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                    NSError * _Nullable error) {
        
            if(objects && !error){
                //the result may have been cached and so we don't need to load this page again.
                if(!isCacheResponse && cacheResponsePassed) return;
                
                objects = [objects sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    PFObject * photoA = obj1;
                    PFObject * photoB = obj2;
                    
                    NSNumber * photoAnum = [photoA valueForKey:PHOTO_INDEX_KEY];
                    NSNumber * photoBnum = [photoB valueForKey:PHOTO_INDEX_KEY];
                    
                    if([photoAnum integerValue] > [photoBnum integerValue]){
                        return NSOrderedDescending;
                    }else if ([photoAnum integerValue] < [photoBnum integerValue]){
                        return NSOrderedAscending;
                    }
                    return NSOrderedSame;
                }];
                if(isCacheResponse){
                    NSLog(@"Just used cache for page");
                }else{
                    NSLog(@"Missed cache using network for page");
                }
                cacheResponsePassed = YES;
                isCacheResponse = NO;
                block(objects);
            }else{
                cacheResponsePassed = NO;
                if(!cacheResponsePassed && !isCacheResponse){
                    block(nil);
                    [[Crashlytics sharedInstance] recordError: error];
                }
                isCacheResponse = NO;
            }
	}];
}

+(void)deletePagesInPost:(PFObject *)post {
    
    PFRelation * pageRelation = [post relationForKey:POST_PAGES_PFRELATION];
    
    PFQuery * pageQuery = [pageRelation query];
    
   [Page_BackendObject getPagesFromPost:post andCompletionBlock:^(NSArray * objects) {
       if(objects){
           for (PFObject *obj in objects) {
               [Photo_BackendObject deletePhotosInPage:obj withCompeletionBlock:^(BOOL success) {
                   [Video_BackendObject deleteVideosInPage:obj withCompeletionBlock:^(BOOL success) {
                       [obj deleteInBackground];
                   }];
               }];
           }
       } 
   }];
}


@end
