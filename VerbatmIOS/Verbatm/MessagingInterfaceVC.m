//
//  MessagingInterfaceVC.m
//  Verbatm
//
//  Created by Iain Usiri on 11/4/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "MessagingInterfaceVC.h"
#import "ChatTextEntry.h"
#import "ChatCell.h"
#import "ChatMessage.h"
#import "Conversations.h"
#import <Parse/PFUser.h>
#import "SizesAndPositions.h"
@interface MessagingInterfaceVC ()<ChatTextEntryProtocol, ConversationProtocol>

    @property (nonatomic, strong) UIScrollView * chatScrollView;
    @property (nonatomic, strong) ChatTextEntry* toolBar;
    @property (nonatomic, strong) Conversations * conversationManager;
    #pragma mark Keyboard related properties
    @property (atomic) NSInteger keyboardHeight;

    //the lowest chat cell in our scrollview
    @property (nonatomic, strong)  ChatCell * lastChatCell;

    #define CELL_Y_OFFSET 15.F
@end

@implementation MessagingInterfaceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addToolBarToView];
    [self.view addSubview:self.chatScrollView];
    [self setUpNotifications];
    self.conversationManager = [[Conversations alloc] init];
    self.conversationManager.delegate = self;
    
    [self.conversationManager startNewChatWith:@"avardhan@stanford.edu"];

    //if(self.chatingWith)[self.conversationManager startNewChatWith:self.chatingWith];
    [self addMessagesToSV:[self.conversationManager getConversationTranscript]];
}


//creates a toolbar to add onto the keyboard
-(void)addToolBarToView {
    CGRect toolBarFrame = CGRectMake(0, self.view.frame.size.height - CHAT_TEXT_TOOLBAR_HEIGHT, self.view.frame.size.width, CHAT_TEXT_TOOLBAR_HEIGHT);
     self.toolBar= [[ChatTextEntry alloc] initWithFrame:toolBarFrame];
    self.toolBar.delegate = self;
    [self.view addSubview:self.toolBar];
}

-(void) setUpNotifications {
    //Tune in to get notifications of keyboard behavior
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    
    
}

#pragma mark Keyboard Notifications

//When keyboard appears get its height. This is only neccessary when the keyboard first appears
-(void)keyboardWillShow:(NSNotification *) notification {
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //store the keyboard height for further use
    self.keyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
}

-(void)keyBoardDidChangeFrame: (NSNotification *) notification {
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //store the keyboard height for further use
    self.keyboardHeight = keyboardSize.height;
    [self adjustViewFrames];
}


-(void) keyBoardDidShow:(NSNotification *) notification {
    [self adjustViewFrames];
}


-(void)keyboardWillDisappear:(NSNotification *) notification {
    self.keyboardHeight = 0;
    [self adjustViewFrames];
}

-(void)adjustViewFrames{
    self.toolBar.frame = CGRectMake(self.toolBar.frame.origin.x, self.view.frame.size.height - self.keyboardHeight - self.toolBar.frame.size.height,
                                    self.toolBar.frame.size.width, self.toolBar.frame.size.height);
    self.chatScrollView.frame = CGRectMake(self.chatScrollView.frame.origin.x, self.chatScrollView.frame.origin.y,
                                           self.chatScrollView.frame.size.width, self.toolBar.frame.origin.y);
}


#pragma mark - present messages on sv -

-(void)addMessagesToSV:(NSMutableArray *) messages{
    for(ChatMessage * message in messages){
        BOOL isMyMessage = [message.username isEqualToString:[[PFUser currentUser] username]];
        
        //turn the message into a chat cell
        ChatCell * newCell = [[ChatCell alloc] initWithText:message.message screenWidth:self.view.frame.size.width isLoggedInUser:isMyMessage];
        CGRect newFrame = newCell.frame;
        CGFloat frameX = (isMyMessage) ? 3.f : self.view.frame.size.width - newCell.frame.size.width - 3.f;
        
        if(self.lastChatCell){
            newFrame.origin = CGPointMake(frameX, self.lastChatCell.frame.origin.y +
                                                            self.lastChatCell.frame.size.height + CELL_Y_OFFSET);
        }else{
            newFrame.origin = CGPointMake(frameX, CELL_Y_OFFSET * 4);
        }
        newCell.frame = newFrame;
        [self.chatScrollView addSubview:newCell];
        self.chatScrollView.contentSize = CGSizeMake(0, newCell.frame.origin.y +
                                                     newCell.frame.size.height + CELL_Y_OFFSET);
        
        CGFloat contentOffset = (self.chatScrollView.contentSize.height >
                                 self.chatScrollView.frame.size.height)  ?
                                self.chatScrollView.contentSize.height - self.chatScrollView.frame.size.height:0;
        self.chatScrollView.contentOffset = CGPointMake(0,contentOffset);
        self.lastChatCell = newCell;
    }
}


#pragma mark -chat entry protocol-
-(void)sendMessage:(NSString *) message {
    ChatMessage * newMessage = [[ChatMessage alloc] initWithMessage:message andUser:[[PFUser currentUser] username]];
    [self addMessagesToSV:[[NSMutableArray alloc] initWithArray:@[newMessage]]];
    [self.conversationManager sendMessage:newMessage];
    [self adjustViewFrames];
}

#pragma mark -conversation protocol-
-(void) messagesReceivedForCurrentChat: (NSMutableArray *) messages{
    [self addMessagesToSV:messages];
}



#pragma mark - lazy instantiation -
-(UIScrollView *) chatScrollView {
    if(!_chatScrollView) {
        CGRect svFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width,self.toolBar.frame.origin.y);
        _chatScrollView = [[UIScrollView alloc] initWithFrame:svFrame];
    }
    return _chatScrollView;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
