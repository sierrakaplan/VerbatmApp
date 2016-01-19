//
//  Uploader.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/1/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "GTLVerbatmAppPost.h"
#import <Foundation/Foundation.h>

@interface POVPublisher : NSObject

#define PROGRESS_UNITS_FOR_INITIAL_PROGRESS 5 // to show the user something is happening
#define PROGRESS_UNITS_FOR_FINAL_PUBLISH 3
#define PROGRESS_UNITS_FOR_IMAGE 3
#define PROGRESS_UNITS_FOR_VIDEO 10

// initialized once publish has been called
@property(nonatomic, strong) NSProgress* publishingProgress;

// Initialize publisher with an array of PinchViews from the post (each being a page),
// and the id of the channel it's being published into (get from backend)
-(instancetype) initWithPinchViews: (NSArray*) pinchViews
					  andChannelId: (NSInteger) channelId;

// Initialize publisher with a post to be "reblogged"
// and the id of the channel it's being published into (get from backend)
// This initializer is for reblogging purposes
-(instancetype) initWithPost: (GTLVerbatmAppPost*) post
		 andChannelId: (NSInteger) channelId;

// assumes publisher was initialized with pinch views
- (void) publishFromPinchViews;

// assumes publisher was initialized with Post
- (void) publishReblog;

@end
