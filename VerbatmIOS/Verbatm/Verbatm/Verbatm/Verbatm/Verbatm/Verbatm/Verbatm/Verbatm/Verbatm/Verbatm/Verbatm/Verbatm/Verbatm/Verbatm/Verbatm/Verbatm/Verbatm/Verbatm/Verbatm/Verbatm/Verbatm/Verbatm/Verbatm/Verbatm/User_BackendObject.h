//
//  User_BackendObject.h
//  Verbatm
//
//  Created by Iain Usiri on 3/24/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFUser;

@interface User_BackendObject : NSObject

+(void)updateUserNameOfCurrentUserTo:(NSString *) newName;

//Checks if user has been blocked by current user
+(void)userIsBlockedByCurrentUser:(PFUser *)user withCompletionBlock:(void(^)(BOOL))block;

+(void)blockUser:(PFUser *)user;

+(void)unblockUser:(PFUser *)user;

+ (void) migrateUserToOneChannelWithCompletionBlock:(void(^)(BOOL))block;

@end
