//
//  POVLoadManager.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/7/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "POVLoadManager.h"
#import "GTLVerbatmAppPOVInfo.h"
#import "GTLVerbatmAppPOV.h"
#import "GTLServiceVerbatmApp.h"
#import "GTMHTTPFetcherLogging.h"
#import "GTLQueryVerbatmApp.h"
#import "GTLVerbatmAppPageListWrapper.h"
#import "GTLVerbatmAppPage.h"
#import "GTLVerbatmAppImage.h"
#import "GTLVerbatmAppVideo.h"
#import "GTLVerbatmAppVerbatmUser.h"
#import "GTLVerbatmAppResultsWithCursor.h"
#import "GTLVerbatmAppIdentifierListWrapper.h"

#import "PovInfo.h"

@interface POVLoadManager()

@property(nonatomic, strong) GTLServiceVerbatmApp *service;

@property (nonatomic) POVType povType;

// Array of PovInfo objects
@property (nonatomic, strong) NSMutableArray* povInfos;
// Cursor string associated with the povInfos (used to query for next batch)
@property (nonatomic, strong) NSString* cursorString;


@end


@implementation POVLoadManager


// Promise wrapper for asynchronous request to get image data (or any data) from the url
+ (AnyPromise*) loadDataFromURL: (NSString*) urlString {
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
		[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
			if (error) {
				resolve(nil);
			} else {
				resolve(data);
			}
		}];
	}];
	return promise;
}


-(instancetype) initWithType: (POVType) type {
	self = [super init];
	if (self) {
		self.povType = type;
	}
	return self;
}

// Load numToLoad POV's, replacing any POV's that were already loaded
// TODO: combine these?
// First loads the GTLVerbatmAppPOVInfo's from the datastore then downloads all the cover pictures and
// stores the array of POVInfo's
-(void) reloadPOVs: (NSInteger) numToLoad {

	NSLog(@"Refreshing POV's...");

	GTLQuery* loadQuery = [self getLoadingQuery: numToLoad withCursor: NO];
	[self loadPOVs: loadQuery].then(^(NSArray* gtlPovInfos) {
		NSMutableArray* loadCoverPhotoPromises = [[NSMutableArray alloc] init];
		for (GTLVerbatmAppPOVInfo* gtlPovInfo in gtlPovInfos) {
			if (gtlPovInfo.coverPicUrl) {
				[loadCoverPhotoPromises addObject: [self getPOVInfoWithExtraInfoFromGTLPOVInfo:gtlPovInfo]];
			}
		}
		return PMKWhen(loadCoverPhotoPromises);
	}).then(^(NSArray* povInfosWithCoverPhoto) {
		self.povInfos = [[NSMutableArray alloc] init];
		[self.povInfos addObjectsFromArray: povInfosWithCoverPhoto];
		NSLog(@"Successfully refreshed POVs!");
		[self.delegate povsRefreshed];
	}).catch(^(NSError* error) {
		NSLog(@"Error refreshing POVs: %@", error.description);
		[self.delegate povsFailedToRefresh];
	});
}


// Loads numOfNewPOVToLoad more POV's using the cursor stored so that it loads from where it left off
// First loads the GTLVerbatmAppPOVInfo's from the datastore then downloads all the cover pictures and
// stores the array of POVInfo's
-(void) loadMorePOVs: (NSInteger) numOfNewPOVToLoad {
	NSLog(@"Loading more POV's...");

	GTLQuery* loadQuery = [self getLoadingQuery: numOfNewPOVToLoad withCursor: YES];
	[self loadPOVs: loadQuery].then(^(NSArray* gtlPovInfos) {
		NSMutableArray* loadMoreInfoPromises = [[NSMutableArray alloc] init];
		for (GTLVerbatmAppPOVInfo* gtlPovInfo in gtlPovInfos) {
			[loadMoreInfoPromises addObject: [self getPOVInfoWithExtraInfoFromGTLPOVInfo:gtlPovInfo]];
		}
		return PMKWhen(loadMoreInfoPromises);
	}).then(^(NSArray* povInfosWithCoverPhoto) {
		[self.povInfos addObjectsFromArray: povInfosWithCoverPhoto];
		NSLog(@"Successfully loaded more POVs!");
		[self.delegate morePOVsLoaded];
	}).catch(^(NSError* error) {
		 NSLog(@"Error loading more POVs: %@", error.description);
	});
}

// Takes a query to load POVs whos expected result is a
// GTLVerbatmAppResultsWithCursor
// Returns a promise that resolves to either an error or an array of
// GTLVerbatmAppPOVInfo's
-(AnyPromise*) loadPOVs: (GTLQuery*) query {
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self.service executeQuery: query completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppResultsWithCursor* results, NSError *error) {
			self.cursorString = results.cursorString;
			if (error) {
				resolve(error);
			} else {
				resolve(results.results);
			}
		}];
	}];
	return promise;
}

// Once it gets the data from the cover photo url, creates a UIImage from that data
// and stores it in a newly created PovInfo, which it returns
-(AnyPromise*) getPOVInfoWithExtraInfoFromGTLPOVInfo: (GTLVerbatmAppPOVInfo*) gtlPovInfo {
	AnyPromise* userNamePromise = [self loadUserNameFromUserID:gtlPovInfo.creatorUserId];
	AnyPromise* coverPicDataPromise = [POVLoadManager loadDataFromURL: gtlPovInfo.coverPicUrl];
	AnyPromise* loadUserIDsWhoHaveLikedThisPOV = [self loadUserIDsWhoHaveLikedPOVWithID: gtlPovInfo.identifier];
	return PMKWhen(@[userNamePromise, coverPicDataPromise, loadUserIDsWhoHaveLikedThisPOV]).then(^(NSArray* results) {
		NSString* userName = results[0];
		NSData* coverPhotoData = results[1];
		UIImage* coverPhoto = nil;
		if (coverPhotoData && ![coverPhotoData isEqual:[NSNull null]]) {
			coverPhoto = [UIImage imageWithData: coverPhotoData];
		}
		NSArray* userIDs = results[2];
		PovInfo* povInfoWithCoverPhoto = [[PovInfo alloc] initWithGTLVerbatmAppPovInfo:gtlPovInfo andUserName:userName andCoverPhoto: coverPhoto andUserIDsWhoHaveLikedThisPOV:userIDs];
		return povInfoWithCoverPhoto;
	});
}

// If the user id is 1 or not found, resolves to "Unknown User"
// Otherwise resolves to user name
-(AnyPromise*) loadUserNameFromUserID: (NSNumber*) userID {

	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		if (userID.longLongValue == 1) {
			resolve(@"Unknown User");
		}
		GTLQuery* getUserQuery = [GTLQueryVerbatmApp queryForVerbatmuserGetUserWithIdentifier:userID.longLongValue];

		[self.service executeQuery:getUserQuery completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppVerbatmUser* userWithID, NSError *error) {
			if (error) {
				resolve(@"Unknown User");
			} else {
				resolve(userWithID.name);
			}
		}];
	}];

	return promise;
}

// Resolves to either error or Array of user ID's that correspond to users that have liked the POV with the given id
-(AnyPromise*) loadUserIDsWhoHaveLikedPOVWithID: (NSNumber*) povID {

	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		GTLQuery* getUserIDsWhoLikeThisPOVQuery = [GTLQueryVerbatmApp queryForPovGetUserIdsWhoLikeThisPOVWithIdentifier:povID.longLongValue];
		[self.service executeQuery:getUserIDsWhoLikeThisPOVQuery completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppIdentifierListWrapper* userIDs, NSError *error) {
			if (error) {
				resolve(error);
			} else {
				if (userIDs.identifiers) {
					resolve(userIDs.identifiers);
				} else {
					resolve([[NSArray alloc] init]);
				}
			}
		}];
	}];

	return promise;
}

// Returns a query that loads more POV's
// Different query depending on the povType (recent or trending)
-(GTLQuery*) getLoadingQuery: (NSInteger) numToLoad withCursor: (BOOL) withCursor {
	GTLQuery* loadQuery;

	// Note: cursor string will be nil if this is the first query.
	// That's ok on the backend.
	switch (self.povType) {
		case POVTypeRecent: {
			loadQuery = [GTLQueryVerbatmApp queryForPovGetRecentPOVsInfoWithCount: numToLoad];
			break;
		}
		case POVTypeTrending: {
			loadQuery = [GTLQueryVerbatmApp queryForPovGetTrendingPOVsInfoWithCount:numToLoad];
						break;
		}
		default:
			return nil;
	}
	if (withCursor) {
		[loadQuery setValue: self.cursorString forKey:@"cursorString"];
	}
	return loadQuery;
}

- (NSInteger) getNumberOfPOVsLoaded {
	return [self.povInfos count];
}

// Returns POVInfo at that index
- (PovInfo*) getPOVInfoAtIndex: (NSInteger) index {
	if (index >= 0 && index < [self.povInfos count]) {
		return self.povInfos[index];
	} else {
		return nil;
	}
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

- (NSMutableArray*) povInfos {
	if (!_povInfos) {
		_povInfos = [[NSMutableArray alloc] init];
	}
	return _povInfos;
}

@end
