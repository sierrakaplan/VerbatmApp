//
//  FollowFriendCell.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/20/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Parse/PFUser.h>

@class Channel;

@interface FollowFriendCell : UITableViewCell

-(void) presentFriendChannel: (Channel*)friendChannel;

@end
