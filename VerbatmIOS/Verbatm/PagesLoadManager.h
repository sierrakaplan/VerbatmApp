//
//  PagesLoadManager.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/15/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//
//	Class in charge of loading page information from a POV.
//	Stores all of the GTLPages and GTLImages + GTLVideos per page
//	that have been loaded (not too memory inefficient since videos
// 	images just store a url, not all of the data, and queries
//	are expensive)
//	Notifies through a delegate when the pages for a POV and
//	images/videos for a page have been loaded
//
//

#import <Foundation/Foundation.h>

@protocol PagesLoadManagerDelegate <NSObject>

-(void) pagesLoadedForPOV: (NSNumber*) povID;

@end

@interface PagesLoadManager : NSObject

@property (strong, nonatomic) id<PagesLoadManagerDelegate> delegate;

// Loads the pages for the given POV, as well as the media
// associated with each page, and stores it. Calls delegate method
// when all media has been loaded so that VC can ask for it.
- (void) loadPagesForPOV: (NSNumber*) povID;

// once the pages have loaded, returns an array of Page objects
- (NSArray*) getPagesForPOV: (NSNumber*) povID;

@end
