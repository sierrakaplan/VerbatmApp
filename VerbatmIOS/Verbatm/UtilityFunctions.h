//
//  UseFulFunctions.h
//  Verbatm
//
//  Created by Iain Usiri on 9/27/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <PromiseKit/PromiseKit.h>

@interface UtilityFunctions : NSObject

// Promise wrapper for asynchronous request to get image data (or any data) from the url
+ (AnyPromise*) loadCachedPhotoDataFromURL: (NSURL*) url;
+ (AnyPromise*) loadCachedVideoDataFromURL: (NSURL*) url;
//decompress our video file
+ (NSData *)gzipInflate:(NSData*)data;

@end
