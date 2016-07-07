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

@end

@interface NotificationsListTVC : UITableViewController
@property (nonatomic) id<NotificationsListTVCProtocol> delegate;
@end
