//
//  MediaLoader.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/17/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.

//	Responsible for retreiving videos from the blobstore
//

#import "MediaLoader.h"
#import "ASIFormDataRequest.h"

@interface MediaLoader()

@property (nonatomic, strong) ASIFormDataRequest* httpRequest;
@property (nonatomic, strong) MediaLoadCompletionBlock completionBlock;

#define BLOBKEYSTRING_KEY @"blob-key"

@end

@implementation MediaLoader

-(instancetype) initWithBlobStoreKeyString:(NSString*) blobStoreKey andURI:(NSString *)uri {

	self.httpRequest = [ASIFormDataRequest requestWithURL: [NSURL URLWithString:uri]];
	[self.httpRequest addPostValue:blobStoreKey forKey: BLOBKEYSTRING_KEY];
	[self.httpRequest setDelegate:self];

	return self;
}

-(PMKPromise*) startDownload {
	PMKPromise* promise = [PMKPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self startWithCompletionHandler: ^(NSError* error, NSString* servingURL) {
			if (error) {
				resolve(error);
			} else {
				resolve(servingURL);
			}
		}];
	}];

	return promise;
}

-(void) startWithCompletionHandler:(MediaLoadCompletionBlock) completionBlock {
	self.completionBlock = completionBlock;
	[self.httpRequest startAsynchronous];
}

-(void) requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"serving video from blobstore finished");
	//The response string is a blobkey string for video and an imagesservice servingurl for image
	NSString* responseString = [request responseString];
	self.completionBlock(nil, responseString);
}

-(void) requestFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	NSLog(@"error serving video%@", error);
	self.completionBlock(error, nil);
}

@end
