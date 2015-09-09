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
#import "GTLVerbatmAppPageCollection.h"
#import "GTLVerbatmAppResultsWithCursor.h"

@interface POVLoadManager()

@property(nonatomic, strong) GTLServiceVerbatmApp *service;

@property (nonatomic) POVType povType;
@property (nonatomic, strong) NSArray* povInfos;

@property (nonatomic, strong) NSString* cursorString;

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
					 NSLog(@"Error loading POVs: %@", error);
				 } else {
					 NSLog(@"Successfully loaded POVs!");
					 self.povInfos = results.results;
					 self.cursorString = results.cursorString;
					 //TODO: notification to update
				 }
			 }];
}

// Returns POVInfo at that index
- (GTLVerbatmAppPOVInfo*) getPOVInfoAtIndex: (NSInteger) index {
	if (index >= 0 && index < [self.povInfos count]) {
		return self.povInfos[index];
	} else {
		return nil;
	}
}

//Returns the pages for a POV at a given index
- (void) loadPOVPagesAtIndex: (NSInteger) index {
	NSNumber* povId = ((GTLVerbatmAppPOVInfo*)self.povInfos[index]).identifier;
	GTLQuery *pagesQuery = [GTLQueryVerbatmApp queryForPovGetPagesFromPOVWithIdentifier: povId.longLongValue];

	[self.service executeQuery:pagesQuery
			 completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppPageCollection* result, NSError *error) {
				 if (error) {

				 } else {
					 //TODO: notification to update
				 }
			 }];
}


- (NSInteger) getNumberOfPOVsLoaded {
	return [self.povInfos count];
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

- (NSArray*) povs {
	if (!_povs) {
		_povs = [[NSArray alloc] init];
	}
	return _povs;
}

@end
