//
//  MediaLoader.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/17/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <PromiseKit/PromiseKit.h>

typedef void(^MediaLoadCompletionBlock)(NSError* error, NSString* servingURL);

@interface MediaLoader : NSObject

-(instancetype) initWithBlobStoreKeyString:(NSString*) blobStoreKey andURI:(NSString *)uri;

// Resolves to either error or a serving url for the video
-(PMKPromise*) startDownload;

@end
