//
//  Photo_BackendObject.h
//  Verbatm
//
//  Created by Iain Usiri on 1/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/PFObject.h>

@interface Photo_BackendObject : NSObject

//make sure that the page object is already saved before calling this function
-(void)saveImage:(UIImage  *) image withText:(NSString *) userText andTextYPosition:(NSNumber *) textYPosition atPhotoIndex:(NSInteger) photoIndex andPageObject:(PFObject *) pageObject;
//querry for all photos relating to a specific page
+(void)getPhotosForPage:(PFObject *) page andCompletionBlock:(void(^)(NSArray *))block;

@end
