//
//  LocalPOVs.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/2/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//
//	This class was created for Matter Demo Day, to store user posts locally.
//	It can be used to store a user post consisting of a pinch views and a channel (thread) name
//	in the user defaults, in order to display a post stored locally. It is hacky not production level code.
//	It remains around for test purposes only.
//

#import <Foundation/Foundation.h>

#import <PromiseKit/PromiseKit.h>

@interface LocalPOVs : NSObject

+ (LocalPOVs*) sharedInstance;

// Enter index of -1 for it to be stored at the end
- (void) storePOVWithThread: (NSString*) thread andPinchViews: (NSMutableArray*) pinchViews atIndex: (NSInteger) index;

-(AnyPromise*) getPOVsFromChannel: (NSString*) thread;

@end
