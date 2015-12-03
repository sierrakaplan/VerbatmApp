//
//  LocalPOVs.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/2/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalPOVs : NSObject

+ (LocalPOVs*) sharedInstance;

- (void) storePOVWithThread: (NSString*) thread andPinchViews: (NSMutableArray*) pinchViews;

-(NSArray*) getPOVsFromThread: (NSString*) thread;

@end
