//
//  Photo_BackendObject.m
//  Verbatm
//
//  Created by Iain Usiri on 1/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//


#import "GTLVerbatmAppImage.h"

#import "Photo_BackendObject.h"
#import <Parse/PFUser.h>
#import "ParseBackendKeys.h"
#import "POVPublisher.h"


@interface Photo_BackendObject ()
    @property (nonatomic) POVPublisher * mediaPublisher;
@end

@implementation Photo_BackendObject

-(void)saveImage:(UIImage  *) image withText:(NSString *) userText andTextYPosition:(NSNumber *) textYPosition atPhotoIndex:(NSInteger) photoIndex andPageObject:(PFObject *) pageObject;
{
    self.mediaPublisher = [[POVPublisher alloc] init];
    [self.mediaPublisher storeImage:image withCompletionBlock:^(GTLVerbatmAppImage * gtlImage) {
        NSString * blobStoreUrl = gtlImage.servingUrl;
        //in completion block of blobstore save
        [self createAndSavePhotoObjectwithBlobstoreUrl:blobStoreUrl withText:userText andTextYPosition:textYPosition atPhotoIndex:photoIndex andPageObject:pageObject];
    }];
    
}


-(void)createAndSavePhotoObjectwithBlobstoreUrl:(NSString *) imageURL withText:(NSString *) userText andTextYPosition:(NSNumber *) textYPosition atPhotoIndex:(NSInteger) photoIndex andPageObject:(PFObject *) pageObject{
    
    PFObject * newPhotoObject = [PFObject objectWithClassName:PHOTO_PFCLASS_KEY];
    
    [newPhotoObject setObject:[NSNumber numberWithInteger:photoIndex] forKey:PHOTO_INDEX_KEY];
    [newPhotoObject setObject:imageURL forKey:PHOTO_IMAGEURL_KEY];
    [newPhotoObject setObject:pageObject forKey:PHOTO_PAGE_OBJECT_KEY];
    [newPhotoObject setObject:textYPosition forKey:PHOTO_TEXT_YOFFSET_KEY];
    [newPhotoObject setObject:userText forKey:PHOTO_TEXT_KEY];
    
    [newPhotoObject saveInBackground];
    
}


@end