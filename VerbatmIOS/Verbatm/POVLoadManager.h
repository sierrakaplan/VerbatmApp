//
//  POVLoadManager.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/7/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//
//	Loads POV's from the server, in POVType order (Trending or most recent)
//	Stores POVInfo's (all information about POV besides pages)
//	that have been loaded
//	Also stores a cursor string so that it can keep loading more POV's
//	where it left off
//	Notifies through a delegate when more POV's are loaded
//	(not a Notification because there can be multiple POVLoadManagers
// 	associated with different list views - trending + most recent)
//

#import <Foundation/Foundation.h>

@class PovInfo;

@protocol POVLoadManagerDelegate <NSObject>

-(void) morePOVsLoaded;
-(void) povsRefreshed;
-(void) povsFailedToRefresh;
-(void) failedToLoadMorePOVs;

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
- (PovInfo*) getPOVInfoAtIndex: (NSInteger) index;

@end
