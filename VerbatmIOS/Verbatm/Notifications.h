//
//  Notifications.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/17/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#ifndef Notifications_h
#define Notifications_h

#pragma mark - Networking -
#define INTERNET_CONNECTION_NOTIFICATION @"internet_connection_notification"
//this key gives you access to a string that tells you if the connection is established or not
#define INTERNET_CONNECTION_KEY @"internet_connection_key"

#define NOTIFICATION_POST_CURRENTLY_PUBLISHING @"notification_pov_publishing"
#define NOTIFICATION_POST_PUBLISHED @"notification_pov_published"
#define NOTIFICATION_POST_FAILED_TO_PUBLISH @"notification_pov_failed_to_publish"


#define NOTIFICATION_REFRESH_FEEDS @"notification_refresh_feeds"


#define NOTIFICATION_USER_LOGIN_SUCCEEDED @"notification_login_succeeded" 
#define NOTIFICATION_USER_LOGIN_FAILED @"notification_login_failed" // includes NSError object

#define NOTIFICATION_USER_SIGNED_OUT @"user_signed_out"
#define NOTIFICATION_USERNAME_CHANGED_SUCCESFULLY @"user_name_changed_success"
#define NOTIFICATION_USERNAME_CHANGE_FAILED @"user_name_change_failed"

#define NOTIFICATION_NOW_FOLLOWING_USER @"following_user"
#define NOTIFICATION_STOPPED_FOLLOWING_USER @"stoped_following_user"

#define NOTIFICATION_FREE_MEMORY_DISCOVER @"free_memory_discover"

#endif /* Header_h */
