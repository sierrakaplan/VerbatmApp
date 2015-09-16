//
//  UpdatingManager.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/16/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "UpdatingManager.h"
#import "GTLVerbatmAppPOV.h"
#import "GTLServiceVerbatmApp.h"
#import "GTMHTTPFetcherLogging.h"
#import "GTLQueryVerbatmApp.h"

#import <PromiseKit/PromiseKit.h>

@interface UpdatingManager()

@property(nonatomic, strong) GTLServiceVerbatmApp *service;

@end

@implementation UpdatingManager


// Updates the like property of a POV. Unfortunately there's no
// more efficient way to do this than by getting the whole POV
// and then restoring it
- (void) povWithId: (NSNumber*) povID wasLiked: (BOOL) liked {
	NSLog(@"Working on loading pov with ID %lld in order to update upvotes . . .", povID.longLongValue);
	[self loadPOVWithID: povID].then(^(GTLVerbatmAppPOV* oldPOV) {
		long long newNumUpVotes = liked ? oldPOV.numUpVotes.longLongValue + 1 : oldPOV.numUpVotes.longLongValue - 1;
		oldPOV.numUpVotes = [NSNumber numberWithLongLong: newNumUpVotes];
		NSLog(@"Working updating pov \"%@\" 's number of upvotes to: %lld . . .", oldPOV.title, oldPOV.numUpVotes.longLongValue);
		return [self storePOV: oldPOV];
	}).then(^(GTLVerbatmAppPOV* newPOV) {
		NSLog(@"Successfully updated pov \"%@\" 's number of upvotes to: %lld", newPOV.title, newPOV.numUpVotes.longLongValue);
	}).catch(^(NSError* error) {
		NSLog(@"Error updating POV: %@", error.description);
	});
}

// Resolves to either an error or the POV with the given id
-(PMKPromise*) loadPOVWithID: (NSNumber*) povID {
	GTLQuery* loadPOVQuery = [GTLQueryVerbatmApp queryForPovGetPOVWithIdentifier: povID.longLongValue];

	PMKPromise* promise = [PMKPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self.service executeQuery: loadPOVQuery
				 completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppPOV* pov, NSError *error) {
					 if (error) {
						 resolve(error);
					 } else {
						 resolve(pov);
					 }
				 }];
	}];
	return promise;
}

// Re inserts the given POV
-(PMKPromise*) storePOV: (GTLVerbatmAppPOV*) pov {
	GTLQuery* storePOVQuery = [GTLQueryVerbatmApp queryForPovInsertPOVWithObject: pov];

	PMKPromise* promise = [PMKPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self.service executeQuery: storePOVQuery
				 completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppPOV* pov, NSError *error) {
					 if (error) {
						 resolve(error);
					 } else {
						 resolve(pov);
					 }
				 }];
	}];
	return promise;
}

#pragma mark - Lazy Instantiation -

- (GTLServiceVerbatmApp *)service {
	if (!_service) {
		_service = [[GTLServiceVerbatmApp alloc] init];

		_service.retryEnabled = YES;

		// Development only
		[GTMHTTPFetcher setLoggingEnabled:YES];
	}

	return _service;
}

@end
