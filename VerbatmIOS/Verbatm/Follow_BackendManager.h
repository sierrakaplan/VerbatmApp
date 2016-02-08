//
//  Follow_BackendManager.h
//  Verbatm
//
//  Created by Iain Usiri on 2/6/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Channel.h"

@interface Follow_BackendManager : NSObject
-(void)currentUserFollowChannel:(Channel *) channelToFollow;
@end
