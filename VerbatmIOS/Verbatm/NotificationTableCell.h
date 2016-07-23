//
//  NotificationTableCell.h
//  Verbatm
//
//  Created by Iain Usiri on 7/4/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"
#import "Notification_BackendManager.h"



@protocol NotificationTableCellProtocol;

@interface NotificationTableCell : UITableViewCell

@property (nonatomic) PFObject * parseObject;
@property (nonatomic) Channel * channel;
@property (nonatomic) NotificationType notificationType;

-(void)presentNotification:(NotificationType) notificationType withChannel:(Channel *) channel andParseObject:(PFObject *)objectId;
@end


