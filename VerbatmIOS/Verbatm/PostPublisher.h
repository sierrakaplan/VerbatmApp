//
//  Uploader.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/1/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLVerbatmAppImage.h"
#import "GTLVerbatmAppVideo.h"

@interface PostPublisher : NSObject

#define PROGRESS_UNITS_FOR_INITIAL_PROGRESS 5 // to show the user something is happening
#define PROGRESS_UNITS_FOR_FINAL_PUBLISH 3
#define PROGRESS_UNITS_FOR_PHOTO 3
#define PROGRESS_UNITS_FOR_VIDEO 10

// initialized once publish has been called
@property(nonatomic, strong) NSProgress* publishingProgress;

-(void) storeVideoFromURL: (NSURL*) url withCompletionBlock:(void(^)(GTLVerbatmAppVideo *))block;

//stores an image for us and takes a completion block to handle the url
-(void) storeImage: (UIImage*) image withCompletionBlock:(void(^)(GTLVerbatmAppImage *))block;

@end
