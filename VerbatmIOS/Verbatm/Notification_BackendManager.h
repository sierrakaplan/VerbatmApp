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

// Make sure you VALID_NOTIFICATION_TYPE when updating enum
typedef enum {
	NotificationTypeNewFollower = 1 << 0, 			// 1
    NotificationTypeLike = 1 << 1, 					// 2
	NotificationTypeFriendJoinedVerbatm = 1 << 2, 	// 4
    NotificationTypeShare = 1 << 3, 				// 8
	NotificationTypeFriendsFirstPost = 1 << 4, 		// 16
	NotificationTypeReblog = 1 << 5, 				// 32
    NotificationTypeNewComment = 1 << 6             // 64
} NotificationType;

NSInteger const VALID_NOTIFICATION_TYPE = (NotificationTypeNewFollower | NotificationTypeLike | NotificationTypeFriendJoinedVerbatm |
										   NotificationTypeShare | NotificationTypeFriendsFirstPost | NotificationTypeReblog |
										   NotificationTypeNewComment);

@interface Notification_BackendManager : NSObject

+(void)createNotificationWithType:(NotificationType) notType receivingUser:(PFUser *) receivingUser relevantPostObject:(PFObject *) post;

+(void)getNotificationsForUserAfterDate:(NSDate *) afterDate withCompletionBlock:(void(^)(NSArray*)) block;


@end
