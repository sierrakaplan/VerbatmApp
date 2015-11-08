//
//  Conversations.h
//  Verbatm
//
//  Created by Iain Usiri on 11/4/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatMessage.h"

@protocol ConversationProtocol <NSObject>
    -(void) messagesReceivedForCurrentChat: (NSMutableArray *) messages;
@end

@interface Conversations : NSObject
    @property (nonatomic) id<ConversationProtocol> delegate;
    //notifies us to track the current ongoing conversation
    -(void)startNewChatWith:(NSString *) newChat;
    // when the users are no longer talking this should be caleld
    -(void)endCurrentChat;
    //only call if you have called startNewChatWith
    -(void)sendMessage:(ChatMessage *) message;
    //only call if you have called startNewChatWith
    -(NSMutableArray *)getConversationTranscript;
@end
