//
//  Notification_BackendManager.h
//  Verbatm
//
//  Created by Iain Usiri on 7/5/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/PFUser.h>
#import <Parse/PFObject.h>

typedef enum {
	NewFollower = 1 << 0, 			// 1
    Like = 1 << 1, 					// 2
	FriendJoinedVerbatm = 1 << 2, 	// 4
    Share = 1 << 3, 				// 8
	FriendsFirstPost = 1 << 4, 		// 16
	Reblog = 1 << 5, 				// 32
    NewComment = 1<<6,                  //64
    CommentReply = 1<<7                  //128 /**/

} NotificationType;

@interface Notification_BackendManager : NSObject

+(void)createNotificationWithType:(NotificationType) notType receivingUser:(PFUser *) receivingUser relevantPostObject:(PFObject *) post;

+(void)getNotificationsForUserAfterDate:(NSDate *) afterDate withCompletionBlock:(void(^)(NSArray*)) block;


@end
