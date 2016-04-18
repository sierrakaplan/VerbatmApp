//
//  ExploreChannelCellView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel.h"
#import <UIKit/UIKit.h>

@interface ExploreChannelCellView : UITableViewCell

@property (nonatomic) BOOL alreadyPresented;

-(void)presentChannel:(Channel *) channel;

-(void)onScreen;

-(void)offScreen;

@end
