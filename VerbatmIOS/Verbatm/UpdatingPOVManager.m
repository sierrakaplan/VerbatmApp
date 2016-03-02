//
//  UpdatingManager.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/16/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "UpdatingPOVManager.h"
#import "GTLVerbatmAppPOV.h"
#import "GTLServiceVerbatmApp.h"
#import "GTMHTTPFetcherLogging.h"
#import "GTLQueryVerbatmApp.h"
#import "GTLVerbatmAppVerbatmUser.h"

#import "UserManager.h"

#import <PromiseKit/PromiseKit.h>

@interface UpdatingPOVManager()

@property(nonatomic, strong) GTLServiceVerbatmApp *service;

@end

@implementation UpdatingPOVManager

// Resolves to either an error or the POV with the given id
-(AnyPromise*) loadPOVWithID: (NSNumber*) povID {
	GTLQuery* loadPOVQuery = [GTLQueryVerbatmApp queryForPovGetPOVWithIdentifier: povID.longLongValue];

	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self.service executeQuery: loadPOVQuery
				 completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppPOV* pov, NSError *error) {
					 if (error) {
						 resolve(error);
					 } else {
						 // have to do this because otherwise it thinks the values in the array are of type NSString* from the JSON
						 NSMutableArray* userIDs = [[NSMutableArray alloc] init];
						 if (pov.usersWhoHaveLikedIDs) {
							 for (NSNumber* userIdentifier in pov.usersWhoHaveLikedIDs) {
								 [userIDs addObject:[NSNumber numberWithLongLong:userIdentifier.longLongValue]];
							 }
						 }
						 pov.usersWhoHaveLikedIDs = userIDs;
						 resolve(pov);
					 }
				 }];
	}];
	return promise;
}

// Re inserts the given POV
-(AnyPromise*) storePOV: (GTLVerbatmAppPOV*) pov {
	GTLQuery* storePOVQuery = [GTLQueryVerbatmApp queryForPovUpdatePOVWithObject: pov];

	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
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
