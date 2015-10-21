//
//  UseFulFunctions.m
//  Verbatm
//
//  Created by Iain Usiri on 9/27/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "UtilityFunctions.h"


@implementation UtilityFunctions

// Promise wrapper for asynchronous request to get image data (or any data) from the url
+ (AnyPromise*) loadCachedDataFromURL: (NSURL*) url {
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		NSURLRequest* request = [NSURLRequest requestWithURL:url
												 cachePolicy:NSURLRequestReturnCacheDataElseLoad
											 timeoutInterval:300];
		[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
			if (error) {
				NSLog(@"Error retrieving data from url: \n %@", error.description);
				resolve(nil);
			} else {
				//				NSLog(@"Successfully retrieved data from url");
				resolve(data);
			}
		}];
	}];
	return promise;
}


@end
