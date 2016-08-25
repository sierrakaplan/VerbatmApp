//
//  FollowFriendCell.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/20/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//
// 	This is a simple table view cell showing the friend's name and a follow button.

#import <UIKit/UIKit.h>

#import <Parse/PFUser.h>

@class Channel;

@interface FollowFriendCell : UITableViewCell

-(void) presentFriendChannel: (Channel*)friendChannel;

@end
