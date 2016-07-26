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

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVKit/AVKit.h>

@class Channel;
@class PFObject;

@interface UtilityFunctions : NSObject

+ (id)sharedInstance;

+(NSString*) stripLargePhotoSuffix:(NSString*)photoUrl;

+(NSString*) addSuffixToPhotoUrl:(NSString*)photoUrl forSize:(NSInteger)size;

+ (NSArray*)shuffleArray:(NSArray*)array;

+ (AVMutableComposition*) fuseAssets:(NSArray*)videoList;

+ (NSString *) randomStringWithLength: (NSInteger)length;

// Promise wrapper for asynchronous request to get image data (or any data) from the url
- (AnyPromise*) loadCachedPhotoDataFromURL: (NSURL*) url;

- (AnyPromise*) loadCachedVideoDataFromURL: (NSURL*) url;

// Cancels all NSURLSession sharedSession data tasks, including downloading photos
- (void) cancelAllSharedSessionDataTasks;

//decompress our video file
+ (NSData *)gzipInflate:(NSData*)data;

+(Channel*)checkIfChannelList:(NSArray*)list containsChannel:(Channel*)channel;

+(PFObject*)checkIfObjectsList:(NSArray*)list containsObject:(PFObject*)object;

@end
