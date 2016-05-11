//
//  NotificationCellView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 5/3/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum NotificationType {
	notificationTypeLike,
	notificationTypeReblog,
	notificationTypeFollow
} NotificationType;

@interface NotificationCellView : UITableViewCell

@property (nonatomic) NotificationType type;


@end
