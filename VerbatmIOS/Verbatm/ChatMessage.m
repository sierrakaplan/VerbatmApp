//
//  ChatMessage.m
//  Verbatm
//
//  Created by Iain Usiri on 11/4/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "ChatMessage.h"

@implementation ChatMessage
-(instancetype) initWithMessage:(NSString *) message andUser:(NSString * ) userName{
    
    self = [super init];
    if(self){
        self.message = message;
        self.username = userName;
    }
    return self;
}
@end
