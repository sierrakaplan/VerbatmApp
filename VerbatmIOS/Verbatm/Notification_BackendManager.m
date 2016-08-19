//
//  Notification_BackendManager.m
//  Verbatm
//
//  Created by Iain Usiri on 7/5/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Notification_BackendManager.h"
#import <Parse/PFQuery.h>
#import "ParseBackendKeys.h"
#import <Crashlytics/Crashlytics.h>
#import "UserInfoCache.h"

@interface Notification_BackendManager ()
#define LOAD_MAX_AMOUNT 20
@end

@implementation Notification_BackendManager


+ (void)createNotificationWithType:(NotificationType) notType receivingUser:(PFUser *) receivingUser relevantPostObject:(PFObject *) post {
	if (![[UserInfoCache sharedInstance] getUserChannel]) return; // Don't send notification if for some reason user hasn't saved channel
    if(![[receivingUser objectId] isEqualToString:[[PFUser currentUser] objectId]]){
        NSNumber * notificationType = [NSNumber numberWithInteger:notType];
        PFObject * notificationObject = [PFObject objectWithClassName:NOTIFICATION_PFCLASS_KEY];
        [notificationObject setValue:[NSNumber numberWithBool:YES] forKey:NOTIFICATION_IS_NEW];
        [notificationObject setValue:[PFUser currentUser] forKey:NOTIFICATION_SENDER];
        [notificationObject setValue:receivingUser forKey:NOTIFICATION_RECEIVER];
        if(post)[notificationObject setValue:post forKey:NOTIFICATION_POST];
        [notificationObject setValue:notificationType forKey:NOTIFICATION_TYPE];
		// Will return error if notification already existed - ignore
        [notificationObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

		}];
    }
}

+(void)getNotificationsForUserAfterDate:(NSDate *) afterDate withCompletionBlock:(void(^)(NSArray*)) block {
    PFQuery * query = [PFQuery queryWithClassName:NOTIFICATION_PFCLASS_KEY];
    [query whereKey:NOTIFICATION_RECEIVER equalTo:[PFUser currentUser]];
    [query orderByDescending:@"createdAt"];
    [query setLimit:LOAD_MAX_AMOUNT];
    if(afterDate)[query whereKey:@"createdAt" lessThan:afterDate];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
		if(error){
			[[Crashlytics sharedInstance] recordError:error];
        }
		NSMutableArray *finalObjects = [[NSMutableArray alloc] initWithCapacity:objects.count];
		for (PFObject* notificationObject in objects) {
			PFUser *notificationSender = [notificationObject valueForKey:NOTIFICATION_SENDER];
			NSNumber *notificationType = notificationObject[NOTIFICATION_TYPE];
			if (notificationSender != nil && (notificationType.integerValue & VALID_NOTIFICATION_TYPE)) {
				[finalObjects addObject:notificationObject];
			}
		}
        block(finalObjects);
    }];
}



@end
