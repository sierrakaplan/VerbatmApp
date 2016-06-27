//
//  FeedTableCell.h
//  Verbatm
//
//  Created by Iain Usiri on 6/27/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"





@interface FeedTableCell : UITableViewCell
-(void)presentProfileForChannel:(Channel *) channel;
@end
