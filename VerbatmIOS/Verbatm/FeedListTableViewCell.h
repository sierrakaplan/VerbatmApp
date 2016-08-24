//
//  FeedListTableViewCell.h
//  Verbatm
//
//  Created by Iain Usiri on 8/23/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"

/*
 Cell for the list of all profiles that are updated and that you're following
 */
@interface FeedListTableViewCell : UITableViewCell
@property (nonatomic) Channel * currentChannel;
-(void)presentChannel:(Channel *) channel isSelected:(BOOL) isSelected;
@end
