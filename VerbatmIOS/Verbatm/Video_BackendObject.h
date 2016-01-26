//
//  Video_BackendObject.h
//  Verbatm
//
//  Created by Iain Usiri on 1/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/PFObject.h>

/*
 
 Manages saving the information for a specific video by storing it in GAE and then 
 saving it and a relation in
 */


@interface Video_BackendObject : NSObject

//Page object is the page object that this video is related to
//page object must already be saved in the database before this function is called
+(void)saveVideo:(NSURL *) videoUrl atVideoIndex:(NSInteger) videoIndex andPageObject:(PFObject *) pageObject;

//add querry for all video related to a specific page object
@end
