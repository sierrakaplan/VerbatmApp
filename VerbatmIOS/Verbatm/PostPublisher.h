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
#import <PromiseKit/PromiseKit.h>

@interface PostPublisher : NSObject

@property(nonatomic, strong) NSProgress* publishingProgress;

-(void) storeVideoFromURL: (NSURL*) url withCompletionBlock:(void(^)(GTLVerbatmAppVideo *))block;

//stores an image for us and takes a completion block to handle the url
-(AnyPromise*) storeImage: (NSData*) imageData;

@end
