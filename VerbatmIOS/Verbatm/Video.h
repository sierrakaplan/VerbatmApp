//
//  Video.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/17/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.

//	Wrapper for GTLVerbatmAppVideo that includes the blobstoreResourceURL
//	Useful for after serving the video from the blobstore
//

#import <Foundation/Foundation.h>

@interface Video : NSObject

@property (strong, nonatomic) NSString* blobStoreResourceURL;
@property (nonatomic, retain) NSNumber *identifier;  // longLongValue

@property (nonatomic, retain) NSNumber *indexInPage;  // intValue
@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) NSNumber *userId;

@end
