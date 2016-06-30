//
//  Uploader.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/1/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/PromiseKit.h>

@interface PostPublisher : NSObject

@property(nonatomic, strong) NSProgress* publishingProgress;

//Resolves to either NSString *blobstoreurl or an NSError
-(AnyPromise*) storeVideoFromURL: (NSURL*) url;

//Resolves to either NSString *blobstoreurl or an NSError
-(AnyPromise*) storeImage: (NSData*) imageData;

@end
