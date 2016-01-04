//
//  SelectChannel.h
//  Verbatm
//
//  Created by Iain Usiri on 1/3/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"
/*
    Presents a list of Channels that the user can select
 */

@protocol SelectChannelProtocol <NSObject>

-(void) channelSelected:(Channel *) channel;


@end

@interface SelectChannel : UIScrollView
-(instancetype) initWithFrame:(CGRect)frame andChannels:(NSArray *) channels;
@property (nonatomic) id <SelectChannelProtocol> delegate;
-(void)unselectAllOptions;
@end
