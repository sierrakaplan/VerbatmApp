//
//  PostChannelAndCreatorBar.h
//  Verbatm
//
//  Created by Iain Usiri on 3/22/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"

@interface PostChannelAndCreatorBar : UIView
-(instancetype) initWithFrame:(CGRect)frame andChannel:(Channel *) channel;
@end
