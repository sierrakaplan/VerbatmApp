//
//  MediaDownloader.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 10/20/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "MediaDownloader.h"

@interface MediaDownloader()

@property (nonatomic, strong) ASIHTTPRequest* request;
@property (nonatomic, strong) MediaDownloadCompletionBlock completionBlock;

#define DOWNLOADING_VIDEO_PROGRESS_UNITS 10

@end

@implementation MediaDownloader

-(instancetype) initWithURI:(NSString *)uri {
	self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:uri]];
	[self.request setDelegate: self];
	[self.request setDownloadProgressDelegate:self];
	self.mediaDownloadProgress = [NSProgress progressWithTotalUnitCount:DOWNLOADING_VIDEO_PROGRESS_UNITS];

	return self;
}

-(AnyPromise*) startDownload {
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self startWithCompletionHandler: ^(NSError* error, NSData* responseData) {
			if (error) {
				resolve(error);
			} else {
				resolve(responseData);
			}
		}];
	}];

	return promise;
}

-(void) startWithCompletionHandler:(MediaDownloadCompletionBlock) completionBlock {
	self.completionBlock = completionBlock;
	[self.request startAsynchronous];
}

#pragma mark Delegate methods

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes {
	
}

@end
