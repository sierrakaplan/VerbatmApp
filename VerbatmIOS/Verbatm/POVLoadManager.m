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
#import "GTLVerbatmAppResultsWithCursor.h"

@interface POVLoadManager()

@property(nonatomic, strong) GTLServiceVerbatmApp *service;

@property (nonatomic) POVType povType;

// Array of GTLVerbatmAppPovInfo objects
@property (nonatomic, strong) NSMutableArray* povInfos;
// Cursor string associated with the povInfos (used to query for next batch)
@property (nonatomic, strong) NSString* cursorString;

// Dictionary of GTLVerbatmAppPageCollection objects associated with their POV id's
@property (nonatomic, strong) NSMutableDictionary* pageCollections;



@end

@implementation POVLoadManager

-(id) initWithType: (POVType) type {
	self = [super init];
	if (self) {
		self.povType = type;
	}
	return self;
}

-(void) loadPOVs: (NSInteger) numToLoad {
	GTLQuery* loadQuery;

	switch (self.povType) {
		case POVTypeRecent: {
			loadQuery = [GTLQueryVerbatmApp queryForPovGetRecentPOVsInfoWithCount: numToLoad
																	   cursorString: self.cursorString];
		}
		case POVTypeTrending: {
			loadQuery = [GTLQueryVerbatmApp queryForPovGetTrendingPOVsInfoWithCount:numToLoad
																	   cursorString: self.cursorString];
		}
		default:
			return;
	}

	[self.service executeQuery:loadQuery
			 completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppResultsWithCursor* results, NSError *error) {
				 if (error) {
					 NSLog(@"Error loading POVs: %@", error.description);
				 } else {
					 NSLog(@"Successfully loaded POVs!");
					 [self.povInfos addObjectsFromArray: results.results];
					 self.cursorString = results.cursorString;
					 //TODO: notification to update
				 }
			 }];
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

//Returns the pages for a POV at a given index
- (void) loadPOVPagesForPOVAtIndex: (NSInteger) index {
	if (index < 0 || index >= [self.povInfos count]) {
		NSLog(@"Error: Requesting pages for POV at index not yet loaded");
		return;
	}
	NSNumber* povId = ((GTLVerbatmAppPOVInfo*)self.povInfos[index]).identifier;
	GTLQuery *pagesQuery = [GTLQueryVerbatmApp queryForPovGetPagesFromPOVWithIdentifier: povId.longLongValue];

	[self.service executeQuery:pagesQuery
			 completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppPageCollection* result, NSError *error) {
				 if (error) {
					 NSLog(@"Error loading pages from POV: %@", error.description);
				 } else {
					 [self.pageCollections setObject:result forKey: povId];
					 //TODO: notification to update
				 }
			 }];
}

-(GTLVerbatmAppPageCollection*) getPageCollectionForPOVAtIndex: (NSInteger) index {
	if (index < 0 || index >= [self.povInfos count]) {
		NSLog(@"Error: Requesting pages for POV at index not yet loaded");
		return nil;
	}
	NSNumber* povId = ((GTLVerbatmAppPOVInfo*)self.povInfos[index]).identifier;
	return [self getPageCollectionForPOV: povId];
}

-(GTLVerbatmAppPageCollection*) getPageCollectionForPOV: (NSNumber*) povID {
	GTLVerbatmAppPageCollection* pages = self.pageCollections[povID];
	if (!pages) {
		NSLog(@"Error: Requesting pages for POV that are not yet loaded");
	}
	return pages;
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

- (NSMutableDictionary*) pageCollections {
	if (!_pageCollections) {
		_pageCollections = [[NSMutableDictionary alloc] init];
	}
	return _pageCollections;
}

@end
