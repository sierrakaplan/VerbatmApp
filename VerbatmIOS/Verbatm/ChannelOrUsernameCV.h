//
//  ChannelOrUsernameCV.h
//  Verbatm
//
//  Created by Iain Usiri on 1/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"
#import "Comment.h"

@interface ChannelOrUsernameCV : UITableViewCell


- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isChannel:(BOOL) isChannel;

-(void)presentChannel:(Channel *) channel;

-(void)presentComment:(Comment *) commentObject;

-(void)clearView;

+(CGFloat)getHeightForCellFromCommentObject:(Comment *) commentObject;

@end
