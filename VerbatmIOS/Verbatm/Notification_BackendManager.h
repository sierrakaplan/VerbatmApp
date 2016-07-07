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
    
    NewFollower = 1 << 0,
    Like = 1 << 1, //someone liked your content
    FriendJoinedVerbatm = 1 << 2,
    Share = 1 << 3, //someone shared your content
    FriendsFirstPost = 1 << 4
    
}NotificationType;

@interface Notification_BackendManager : NSObject
+(void)createNotificationWithType:(NotificationType) notType receivingUser:(PFUser *) receivingUser relevantPostObject:(PFObject *) post;
+(void)getNotificationsForUserAfterDate:(NSDate *) afterDate withCompletionBlock:(void(^)(NSArray*)) block;


@end
