//
//  ChatNameTableViewCell.h
//  Verbatm
//
//  Created by Iain Usiri on 11/6/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatNameTableViewCell : UITableViewCell
@property (nonatomic) BOOL unreadMessage;
@property (nonatomic, strong) UILabel * userName;
@end
