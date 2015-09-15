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
#import "GTLVerbatmAppResultsWithCursor.h"

@interface POVLoadManager()

@property(nonatomic, strong) GTLServiceVerbatmApp *service;

@property (nonatomic) POVType povType;

// Array of GTLVerbatmAppPovInfo objects
@property (nonatomic, strong) NSMutableArray* povInfos;
// Cursor string associated with the povInfos (used to query for next batch)
@property (nonatomic, strong) NSString* cursorString;


@end


@implementation POVLoadManager

-(instancetype) initWithType: (POVType) type {
	self = [super init];
	if (self) {
		self.povType = type;
	}
	return self;
}


// Loads numToLoad more POV's using the cursor stored so that it loads from where it left off
-(void) loadMorePOVs: (NSInteger) numToLoad {

	GTLQuery* loadQuery = [self getLoadingQuery: numToLoad withCursor: YES];

	[self.service executeQuery:loadQuery
			 completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppResultsWithCursor* results, NSError *error) {
				 if (error) {
					 NSLog(@"Error loading POVs: %@", error.description);
				 } else {
					 NSLog(@"Successfully loaded POVs!");
					 [self.povInfos addObjectsFromArray: results.results];
					 self.cursorString = results.cursorString;

					 [self.delegate morePOVsLoaded];
				 }
			 }];
}

// Load numToLoad POV's, replacing any POV's that were already loaded
-(void) reloadPOVs: (NSInteger) numToLoad {
	GTLQuery* loadQuery = [self getLoadingQuery: numToLoad withCursor: NO];

	[self.service executeQuery:loadQuery
			 completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppResultsWithCursor* results, NSError *error) {
				 if (error) {
					 NSLog(@"Error loading POVs: %@", error.description);
				 } else {
					 NSLog(@"Successfully loaded POVs!");
					 self.povInfos = [[NSMutableArray alloc] init];
					 [self.povInfos addObjectsFromArray: results.results];
					 self.cursorString = results.cursorString;

					 [self.delegate morePOVsLoaded];
				 }
			 }];
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
- (GTLVerbatmAppPOVInfo*) getPOVInfoAtIndex: (NSInteger) index {
	if (index >= 0 && index < [self.povInfos count]) {
		return self.povInfos[index];
	} else {
		NSLog(@"Error: Requesting POV for index not yet loaded");
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
