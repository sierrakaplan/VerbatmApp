//
//  ChatMessage.h
//

//
//  Created by Iain Usiri on 11/4/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

/*
 Simple class to track a message and who sent it 
 */


#import <Foundation/Foundation.h>

@interface ChatMessage : NSObject
    @property (nonatomic, strong) NSString * message;
    @property (nonatomic, strong) NSString * username;//person the send the message

-(instancetype) initWithMessage:(NSString *) message andUser:(NSString * ) userName;
@end
