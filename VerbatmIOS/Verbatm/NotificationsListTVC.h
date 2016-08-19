//
//  NotificationsListTVC.h
//  Verbatm
//
//  Created by Iain Usiri on 7/4/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotificationsListTVCProtocol <NSObject>

-(void)notificationListHideTabBar:(BOOL) shouldHide;
-(void)showNotificationIndicator;//tells the master nav to put up notification that there's a notificatioin
-(void)removeNotificationIndicator;

@end

@interface NotificationsListTVC : UITableViewController

@property (nonatomic, weak) id<NotificationsListTVCProtocol> delegate;

-(void)refreshNotifications;

@end
