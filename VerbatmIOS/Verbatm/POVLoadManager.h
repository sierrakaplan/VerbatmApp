//
//  POVLoadManager.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/7/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTLVerbatmAppPOVInfo;
@class GTLVerbatmAppPageCollection;

@protocol POVLoadManagerDelegate <NSObject>

-(void) morePOVsLoaded;

@end

@interface POVLoadManager : NSObject

typedef NS_ENUM(NSInteger, POVType) {
	POVTypeTrending,
	POVTypeRecent
};

@property (strong, nonatomic) id<POVLoadManagerDelegate> delegate;

// Initialize with the type of POV's to load (trending, recent, etc.)
-(id) initWithType: (POVType) type;

// Query for next batch of POVInfos (when scrolling down)
-(void) loadMorePOVs: (NSInteger) numToLoad;

// Reloads the POVs
-(void) reloadPOVs: (NSInteger) numToLoad;

// Returns size of the POVInfo array in memory
-(NSInteger) getNumberOfPOVsLoaded;

// Get the POVInfo at the given index. Will return nil if not loaded yet
// Should only be called after getting notification from loadPOV's
- (GTLVerbatmAppPOVInfo*) getPOVInfoAtIndex: (NSInteger) index;

// Loads the pages from the POVInfo at the given index.
// If a POVInfo at that index isn't loaded will print error and do nothing
- (void) loadPOVPagesForPOVAtIndex: (NSInteger) index;

// Returns the page collection for the POV at index.
// If a POVInfo at that index isn't loaded will print error and return nil
// If the POVInfo exists but there are no pages loaded for it yet will print error and return nil
-(GTLVerbatmAppPageCollection*) getPageCollectionForPOVAtIndex: (NSInteger) index;

// Returns the page collection for the POV with the given ID
// If there are no pages loaded for a POV with that id will print error and return nil
- (GTLVerbatmAppPageCollection*) getPageCollectionForPOV: (NSNumber*) povID;

@end
