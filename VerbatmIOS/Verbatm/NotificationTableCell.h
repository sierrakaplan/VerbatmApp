//
//  NotificationTableCell.h
//  Verbatm
//
//  Created by Iain Usiri on 7/4/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"

typedef enum {
    
    NewFollower = 1 << 0,
    Like = 1 << 1, //someone liked your content
    FriendJoinedVerbatm = 1 << 2,
    Share = 1 << 3, //someone shared your content
    FriendsFirstPost = 1 << 4
    
}NotificationType;

@interface NotificationTableCell : UITableViewCell
@property (nonatomic) id objectId;
@property (nonatomic) Channel * channel;
@property (nonatomic) NotificationType notificationType;

-(void)presentNotification:(NotificationType) notificationType withChannel:(Channel *) channel andObjectId:(id)objectId;
@end
