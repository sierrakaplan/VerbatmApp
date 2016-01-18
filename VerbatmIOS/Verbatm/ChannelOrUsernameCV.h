//
//  ChannelOrUsernameCV.h
//  Verbatm
//
//  Created by Iain Usiri on 1/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelOrUsernameCV : UITableViewCell


- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isChannel:(BOOL) isChannel isAChannelThatIFollow:(BOOL) channelThatIFollow;

-(void)setCellTextTitle:(NSString *) title;

@end
