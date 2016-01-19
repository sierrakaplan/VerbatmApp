////
////  POVLoadManager.h
////  Verbatm
////
////  Created by Sierra Kaplan-Nelson on 9/7/15.
////  Copyright (c) 2015 Verbatm. All rights reserved.
////
////	Loads POV's from the server, in POVType order (Trending or most recent)
////	Stores POVInfo's (all information about POV besides pages)
////	that have been loaded
////	Also stores a cursor string so that it can keep loading more POV's
////	where it left off
////	Notifies through a delegate when more POV's are loaded
////	(not a Notification because there can be multiple POVLoadManagers
//// 	associated with different list views - trending + most recent)
////
//
//#import <Foundation/Foundation.h>
//#import <PromiseKit/PromiseKit.h>
//
//@class PovInfo;
//
//@protocol POVLoadManagerDelegate <NSObject>
//
//// Successfully loaded more POV's
//-(void) morePOVsLoaded: (NSInteger) numLoaded;
//// Was unable to load more POV's for some reason
//-(void) failedToLoadMorePOVs;
//
//// Reloaded the POV's from the server (starting at the beginning without a cursor)
//-(void) povsRefreshed;
//// Was unable to refresh POV's for some reason
//-(void) povsFailedToRefresh;
//
//
//@end
//
//@interface POVLoadManager : NSObject
//
//typedef NS_ENUM(NSInteger, POVType) {
//	POVTypeTrending,
//	POVTypeRecent,
//	POVTypeUser // filters only user stories
//};
//
//@property (strong, nonatomic) id<POVLoadManagerDelegate> delegate;
//// tells if we have reached the end of our feed
//@property (nonatomic) BOOL noMorePOVsToLoad;
//
//// Initialize with the type of POV's to load (trending, recent, etc.)
//// Don't use this for POVTypeUser because needs user id to get the pov's associated with
//-(instancetype) initWithType: (POVType) type;
//
//-(instancetype) initWithUserId: (NSNumber*) userId andChannel:(NSString *) channelName;
//
//-(void) loadRecentPosts;
//
//// Query for next batch of POVInfos (when scrolling down)
//-(void) loadMorePOVs: (NSInteger) numToLoad;
//
//// Reloads the POVs
//-(void) reloadPOVs: (NSInteger) numToLoad;
//
//// Returns size of the POVInfo array in memory
//-(NSInteger) getNumberOfPOVsLoaded;
//
//// Get the POVInfo at the given index. Will return nil if not loaded yet
//// Should only be called after getting notification from loadPOV's
//- (PovInfo*) getPOVInfoAtIndex: (NSInteger) index;
//
//// Get the index of the POV. Will return NSNotFound if not found
//-(NSInteger) getIndexOfPOV: (PovInfo*) povInfo;
//
//// updates povInfo's numlikes and adds current user id to its list of users who have liked it
//// this is only on the front end, the database is updated somewhere else
//-(void) currentUserLiked: (BOOL) liked povInfo: (PovInfo*) povInfo;
//
//@end
