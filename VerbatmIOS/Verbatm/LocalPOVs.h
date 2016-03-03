//
//  LocalPOVs.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/2/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <PromiseKit/PromiseKit.h>

@interface LocalPOVs : NSObject

+ (LocalPOVs*) sharedInstance;

// Enter index of -1 for it to be stored at the end
- (void) storePOVWithThread: (NSString*) thread andPinchViews: (NSMutableArray*) pinchViews atIndex: (NSInteger) index;

-(AnyPromise*) getPOVsFromChannel: (NSString*) thread;

@end
