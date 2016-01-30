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

#define NOTIFICATION_POV_PUBLISHED @"notification_pov_published"
#define NOTIFICATION_REFRESH_FEEDS @"notification_refresh_feeds"
#define NOTIFICATION_USER_LOGIN_SUCCEEDED @"notification_login_succeeded" // includes GTLVerbatmAppVerbatmUser object
#define NOTIFICATION_USER_LOGIN_FAILED @"notification_login_failed" // includes NSError object

#define NOTIFICATION_USER_SIGNED_OUT @"user_signed_out"

#endif /* Header_h */
