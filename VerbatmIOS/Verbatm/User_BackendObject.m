
//
//  User_BackendObject.m
//  Verbatm
//
//  Created by Iain Usiri on 3/24/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel_BackendObject.h"
#import "Follow_BackendManager.h"
#import "User_BackendObject.h"
#import <Parse/PFUser.h>
#import <Parse/PFQuery.h>
#import "ParseBackendKeys.h"
#import "Notifications.h"

@implementation User_BackendObject


+(void)updateUserNameOfCurrentUserTo:(NSString *) newName{
    if(newName && [User_BackendObject stringHasCharacters:newName] &&
       ![newName isEqualToString:[[PFUser currentUser] valueForKey:VERBATM_USER_NAME_KEY]]) {

		//we check if the name is already taken
        PFQuery * userQuery = [PFQuery queryWithClassName:USER_KEY];
        [userQuery whereKey:VERBATM_USER_NAME_KEY equalTo:newName];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                             NSError * _Nullable error) {
            if(objects.count == 0){
                //name not taken
                [[PFUser currentUser] setValue:newName forKey:VERBATM_USER_NAME_KEY];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(succeeded){
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USERNAME_CHANGED_SUCCESFULLY object:nil];
                    }else{
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USERNAME_CHANGE_FAILED object:nil];
                    }
                }];
            }
        }];
    }
}

+(void)userIsBlockedByCurrentUser:(PFUser *)user withCompletionBlock:(void(^)(BOOL))block {
	PFQuery *blockQuery = [PFQuery queryWithClassName:BLOCK_PFCLASS_KEY];
	[blockQuery whereKey:BLOCK_USER_BLOCKING_KEY equalTo:[PFUser currentUser]];
	[blockQuery whereKey:BLOCK_USER_BLOCKED_KEY equalTo:user];
	[blockQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
		if (objects && objects.count) block(YES);
		else block(NO);
	}];
}

+(void)blockUser:(PFUser *)user {
	PFObject *newBlockObject = [PFObject objectWithClassName:BLOCK_PFCLASS_KEY];
	[newBlockObject setObject:[PFUser currentUser] forKey:BLOCK_USER_BLOCKING_KEY];
	[newBlockObject setObject:user forKey:BLOCK_USER_BLOCKED_KEY];
	[newBlockObject saveInBackground];

	//Make sure blocked user unfollows all of current user's channels
	[Channel_BackendObject getChannelsForUser:[PFUser currentUser] withCompletionBlock:^(NSMutableArray *channels) {
		for (Channel *channel in channels) {
			[Follow_BackendManager user:user stopFollowingChannel:channel];
		}
	}];
}

+(void)unblockUser:(PFUser *)user {
	PFQuery *blockQuery = [PFQuery queryWithClassName:BLOCK_PFCLASS_KEY];
	[blockQuery whereKey:BLOCK_USER_BLOCKING_KEY equalTo:[PFUser currentUser]];
	[blockQuery whereKey:BLOCK_USER_BLOCKED_KEY equalTo:user];
	[blockQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
		if (objects) {
			for (PFObject *block in objects) {
				[block deleteInBackground]; //should only be one
			}
		} else {
			NSLog(@"Error unblocking: %@", error.description);
		}
	}];
}

+(BOOL)stringHasCharacters:(NSString *) text{
    NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
    return ![[text stringByTrimmingCharactersInSet:alphaSet] isEqualToString:text];
}



@end
