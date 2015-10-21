//
//  MediaDownloader.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 10/20/15.
//  Copyright © 2015 Verbatm. All rights reserved.

// NOT IN USE (or finished)
//

#import <Foundation/Foundation.h>
#import <PromiseKit/PromiseKit.h>

typedef void(^MediaDownloadCompletionBlock)(NSError* error, NSData* responseData);

@interface MediaDownloader : NSObject

@property (nonatomic, strong) NSProgress* mediaDownloadProgress;

-(instancetype) initWithURI: (NSString*) uri;

-(AnyPromise*) startDownload;

@end
