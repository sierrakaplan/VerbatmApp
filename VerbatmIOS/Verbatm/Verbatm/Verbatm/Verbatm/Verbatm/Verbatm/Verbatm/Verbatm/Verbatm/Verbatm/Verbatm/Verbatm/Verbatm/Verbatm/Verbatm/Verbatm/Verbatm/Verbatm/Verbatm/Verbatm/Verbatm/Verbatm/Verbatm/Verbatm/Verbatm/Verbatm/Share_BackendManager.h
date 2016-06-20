//
//  Share_BackendManager.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 3/24/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/PromiseKit.h>

@interface Share_BackendManager : NSObject

+(void) currentUserReblogPost: (PFObject *) postParseObject toChannel: (PFObject *) channelObject;

//tests to see if the logged in user shared this post
+(void) currentUserSharedPost:(PFObject *) postParseObject withCompletionBlock:(void(^)(bool))block;

/* Promise resolves to NSNumber */
+(AnyPromise*) numberOfSharesForPost:(PFObject*) postParseObject;

+(void) deleteSharesForPost:(PFObject*) postParseObject withCompletionBlock:(void(^)(BOOL)) block;

@end
