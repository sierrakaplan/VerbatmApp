//
//  Photo_BackendObject.m
//  Verbatm
//
//  Created by Iain Usiri on 1/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//


#import "Notifications.h"

#import "Photo_BackendObject.h"
#import <Parse/PFUser.h>
#import <Parse/PFQuery.h>
#import "ParseBackendKeys.h"
#import "PostPublisher.h"
#import "PublishingProgressManager.h"
#import <PromiseKit/AnyPromise.h>

@interface Photo_BackendObject ()

@property (nonatomic) PostPublisher * mediaPublisher;

@end

@implementation Photo_BackendObject

-(AnyPromise*) saveImageWithName:(NSString*)fileName
						 andData:(NSData *) imageData
		withText:(NSString *) text
andTextYPosition:(NSNumber *) textYPosition
	andTextColor:(UIColor *) textColor
andTextAlignment:(NSNumber *) textAlignment
	 andTextSize:(NSNumber *) textSize
	atPhotoIndex:(NSInteger) photoIndex
   andPageObject:(PFObject *) pageObject {
    self.mediaPublisher = [[PostPublisher alloc] init];
    return [self.mediaPublisher storeImageWithName:fileName andData:imageData].then(^(id result) {
		if ([result isKindOfClass:[NSError class]]) {
			return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
				resolve(result);
			}];
		}
		NSString *blobstoreUrl = (NSString*) result;
		if (![blobstoreUrl hasSuffix:@"=s0"]) {
			blobstoreUrl = [blobstoreUrl stringByAppendingString:@"=s0"];
		}
        //in completion
        return [self createAndSavePhotoObjectwithBlobstoreUrl:blobstoreUrl
											  withText:text
									  andTextYPosition:textYPosition
										  andTextColor:textColor
									  andTextAlignment:textAlignment
										   andTextSize:textSize
										  atPhotoIndex:photoIndex
										 andPageObject:pageObject].then(^(NSError*error) {
			return error; //Will be nil if succeeded
		});
    });
}

/* media, text, textYPosition, textColor, textAlignment, textSize */
-(AnyPromise*) createAndSavePhotoObjectwithBlobstoreUrl:(NSString *) imageURL
									   withText:(NSString *) text
							   andTextYPosition:(NSNumber *) textYPosition
								   andTextColor:(UIColor *) textColor
							   andTextAlignment:(NSNumber *) textAlignment
									andTextSize:(NSNumber *) textSize
								   atPhotoIndex:(NSInteger) photoIndex
								  andPageObject:(PFObject *) pageObject {

    PFObject * newPhotoObject = [PFObject objectWithClassName:PHOTO_PFCLASS_KEY];
    
    [newPhotoObject setObject:[NSNumber numberWithInteger:photoIndex] forKey:PHOTO_INDEX_KEY];
    [newPhotoObject setObject:imageURL forKey:PHOTO_IMAGEURL_KEY];
    [newPhotoObject setObject:pageObject forKey:PHOTO_PAGE_OBJECT_KEY];
	[newPhotoObject setObject:text forKey:PHOTO_TEXT_KEY];
    [newPhotoObject setObject:textYPosition forKey:PHOTO_TEXT_YOFFSET_KEY];
	[newPhotoObject setObject:[NSKeyedArchiver archivedDataWithRootObject:textColor] forKey:PHOTO_TEXT_COLOR_KEY];
	[newPhotoObject setObject:textAlignment forKey:PHOTO_TEXT_ALIGNMENT_KEY];
	[newPhotoObject setObject:textSize forKey:PHOTO_TEXT_SIZE_KEY];

	return [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
		[newPhotoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
			if(succeeded && !error){
				[[PublishingProgressManager sharedInstance] mediaSavingProgressed:1];
				resolve(nil);
			} else {
				resolve(error);
			}
		}];
	}];
}

+(void)getPhotosForPage:(PFObject *) page andCompletionBlock:(void(^)(NSArray *))block {
    
    PFQuery *imagesQuery = [PFQuery queryWithClassName:PHOTO_PFCLASS_KEY];
    [imagesQuery whereKey:PHOTO_PAGE_OBJECT_KEY equalTo:page];
    [imagesQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                         NSError * _Nullable error) {
        if(objects && !error){
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
            
            block(objects);
        }
    }];
}

+(void)deletePhotosInPage:(PFObject *)page withCompeletionBlock:(void(^)(BOOL))block {
	PFQuery *imagesQuery = [PFQuery queryWithClassName:PHOTO_PFCLASS_KEY];
	[imagesQuery whereKey:PHOTO_PAGE_OBJECT_KEY equalTo:page];
	[imagesQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
													NSError * _Nullable error) {
		if(objects && !error){
			for (PFObject *photoObj in objects) {
				[photoObj deleteInBackground];
			}
			block(YES);
			return;
		}
		block (NO);
	}];
}

@end
