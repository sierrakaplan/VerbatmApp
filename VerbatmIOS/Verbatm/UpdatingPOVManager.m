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


// Updates the like property of a POV. Unfortunately there's no
// more efficient way to do this than by getting the whole POV
// and then restoring it
- (void) povWithId: (NSNumber*) povID wasLiked: (BOOL) liked {

	// Update current user's list of povs they like
	UserManager* userManager = [UserManager sharedInstance];
	GTLVerbatmAppVerbatmUser* currentUser = [userManager getCurrentUser];
	NSArray* likedPOVIDs = currentUser.likedPOVIDs;
	NSMutableArray* updatedLikes = [[NSMutableArray alloc] initWithArray:likedPOVIDs copyItems:NO];
	if (liked && ![likedPOVIDs containsObject: povID]) {
		[updatedLikes addObject: povID];
	} else if (!liked && [likedPOVIDs containsObject: povID]) {
		[updatedLikes removeObject: povID];
	}
	currentUser.likedPOVIDs = updatedLikes;

	[userManager updateCurrentUser:currentUser].then(^(GTLVerbatmAppVerbatmUser* user) {
		NSLog(@"Updated current user's likes");
	}).catch(^(NSError* error) {
		NSLog(@"Error updating user: %@", error.description);
	});

	// Update Pov's users who have liked it
	[self loadPOVWithID: povID].then(^(GTLVerbatmAppPOV* oldPOV) {
		NSMutableArray* updatedUsersWhoHaveLikedThisPOV = [[NSMutableArray alloc] initWithArray:oldPOV.usersWhoHaveLikedIDs copyItems:NO];
		if (liked && ![updatedUsersWhoHaveLikedThisPOV containsObject: currentUser.identifier]) {
			[updatedUsersWhoHaveLikedThisPOV addObject: currentUser.identifier];
		} else if(!liked && [updatedUsersWhoHaveLikedThisPOV containsObject: currentUser.identifier]) {
			[updatedUsersWhoHaveLikedThisPOV removeObject: currentUser.identifier];
		}
		oldPOV.usersWhoHaveLikedIDs = updatedUsersWhoHaveLikedThisPOV;
		long long newNumUpVotes = (long long) updatedUsersWhoHaveLikedThisPOV.count;
		oldPOV.numUpVotes = [NSNumber numberWithLongLong: newNumUpVotes];
		return [self storePOV: oldPOV];
	}).then(^(GTLVerbatmAppPOV* newPOV) {
//		NSLog(@"Successfully updated pov \"%@\" 's number of upvotes to: %lld", newPOV.title, newPOV.numUpVotes.longLongValue);
	}).catch(^(NSError* error) {
		NSLog(@"Error updating POV: %@", error.description);
	});
}

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
