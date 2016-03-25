//
//  Like_BackendManager.h
//  Verbatm
//
//  Created by Iain Usiri on 3/20/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/PFObject.h>
@interface Like_BackendManager : NSObject

+(void) currentUserLikePost:(PFObject *) postParseObject;
+(void) currentUserStopLikingPost:(PFObject *) postParseObject;
//tests to see if the logged in user follows this channel
+(void) currentUserLikesPost:(PFObject *) postParseObject withCompletionBlock:(void(^)(bool))block;

+(void) numberOfLikesForPost:(PFObject*) postParseObject withCompletionBlock:(void(^)(NSNumber*)) block;

@end
