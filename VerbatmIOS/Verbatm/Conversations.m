//
//  Conversations.m
//  Verbatm
//
//  Created by Iain Usiri on 11/4/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//


/*
    This class manages the conversation transcripts for all the chats.
    Each conversation is managed in here including communicating with the Chat manager.
 */
#import "Conversations.h"
#import "ChatMessage.h"
#import "ChatManager.h"
#import <Parse/PFUser.h>
#import "Notifications.h"

@interface Conversations ()
// maintains the transcript for conversations between the current user and all others
//key is username (person I'm chatting with) object is array of ChatMessage Objects
@property (nonatomic, strong) NSMutableDictionary * conversations;
@property (nonatomic, strong) NSString * currentlyTalkingTo;//username of the person we are currently talking to. this is nil if the conversation isn't active
@property (nonatomic, strong) ChatManager * chatManager;
@end

@implementation Conversations


-(instancetype) init{
    self = [super init];
    if(self){
        self.currentlyTalkingTo = nil;
        self.chatManager = [[ChatManager alloc] init];
        [self listenForIncomingMessages];
    }
    return self;
}

#pragma mark -listening to backend-

-(void)listenForIncomingMessages{
    //gets notified if there is no internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newMessageReceived:)
                                                 name:NOTIFICATION_MESSAGE_RECEIVED
                                               object:nil];
}

-(void)newMessageReceived:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSString * userFrom = [userInfo objectForKey:@"Message Sender"];
    NSMutableArray * newMessages = [self.chatManager getMessagesFromUser:userFrom];
    NSMutableArray * transcript = [self.conversations objectForKey:userFrom];
    if(!transcript){
        transcript = [[NSMutableArray alloc] init];
        [self.conversations setObject:transcript forKey:userFrom];
    }
    
    [transcript addObjectsFromArray:newMessages];
    if(self.delegate) {
        [self.delegate messagesReceivedForCurrentChat:newMessages];
    }
}


-(void)startNewChatWith:(NSString *) newChat{
    if(newChat)self.currentlyTalkingTo = newChat;
}
-(void)endCurrentChat{
    self.currentlyTalkingTo = nil;
}

-(NSMutableArray *)getConversationTranscript{
    if(!self.currentlyTalkingTo) return nil;
    else return [self.conversations objectForKey:self.currentlyTalkingTo];
}


-(void)sendMessage:(ChatMessage *) message {
    if(self.currentlyTalkingTo){
        [self.chatManager sendMessage:message to:self.currentlyTalkingTo];
    }
}


#pragma mark -lazy instantiation-

-(NSMutableDictionary *) conversations{
    if(!_conversations) _conversations = [[NSMutableDictionary alloc] init];
    return _conversations;
}

@end
