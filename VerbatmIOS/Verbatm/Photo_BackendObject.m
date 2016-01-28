//
//  Photo_BackendObject.m
//  Verbatm
//
//  Created by Iain Usiri on 1/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Photo_BackendObject.h"
#import <Parse/PFUser.h>
#import "ParseBackendKeys.h"



@implementation Photo_BackendObject

+(void)saveImage:(UIImage  *) image withText:(NSString *) userText andTextYPosition:(NSNumber *) textYPosition atPhotoIndex:(NSInteger) photoIndex andPageObject:(PFObject *) pageObject;
{
    
    //save the image to the GAE blobstore -- TODO Sierra (new)
    NSString * blobStoreUrl;//set this with the url from the blobstore
    
    //in completion block of blobstore save
    [Photo_BackendObject createAndSavePhotoObjectwithBlobstoreUrl:blobStoreUrl withText:userText andTextYPosition:textYPosition atPhotoIndex:photoIndex andPageObject:pageObject];
}


+(void)createAndSavePhotoObjectwithBlobstoreUrl:(NSString *) imageURL withText:(NSString *) userText andTextYPosition:(NSNumber *) textYPosition atPhotoIndex:(NSInteger) photoIndex andPageObject:(PFObject *) pageObject{
    
    PFObject * newPhotoObject = [PFObject objectWithClassName:PHOTO_PFCLASS_KEY];
    
    [newPhotoObject setObject:[NSNumber numberWithInteger:photoIndex] forKey:PHOTO_INDEX_KEY];
    [newPhotoObject setObject:imageURL forKey:PHOTO_IMAGEURL_KEY];
    [newPhotoObject setObject:pageObject forKey:PHOTO_PAGE_OBJECT_KEY];
    [newPhotoObject setObject:textYPosition forKey:PHOTO_TEXT_YOFFSET_KEY];
    [newPhotoObject setObject:userText forKey:PHOTO_TEXT_KEY];
    
    [newPhotoObject saveInBackground];
    
}


@end
