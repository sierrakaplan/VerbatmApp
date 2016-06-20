//
//  CreatorAndChannelBar.h
//  Verbatm
//
//  Created by Iain Usiri on 12/29/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"
#import <Parse/PFUser.h>

@protocol CreatorAndChannelBarProtocol <NSObject>
//this prompts the view controller to present the channel
//that has been selected
-(void)channelSelected:(Channel *) channel;

@end

@interface CreatorAndChannelBar : UIView

-(instancetype) initWithFrame:(CGRect)frame andChannel:(Channel *) channel;
@property (nonatomic, weak) id<CreatorAndChannelBarProtocol> delegate;

@end
