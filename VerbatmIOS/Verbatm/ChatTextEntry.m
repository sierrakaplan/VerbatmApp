//
//  ChatTextEntry.m
//  Verbatm
//
//  Created by Iain Usiri on 11/4/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "ChatTextEntry.h"
#import "HPGrowingTextView.h"

@interface ChatTextEntry ()<HPGrowingTextViewDelegate>
    @property (strong, nonatomic)  HPGrowingTextView * hpTextView;
    @property (strong, nonatomic)  UIButton *sendButton;
@end

@implementation ChatTextEntry

# pragma mark Initialization

-(instancetype)initWithFrame:(CGRect)frame {
    //load from Nib file..this initializes the background view and all its subviews
    self = [super initWithFrame:frame];
    if(self) {
        [self createButtons];
        [self createTextEntryView];
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}


-(void) createButtons {
    
    CGFloat buttonHeight = self.frame.size.height - TEXT_TOOLBAR_BUTTON_OFFSET;
    
    CGRect sendButtonFrame = CGRectMake(self.frame.size.width - TEXT_TOOLBAR_BUTTON_WIDTH, (self.frame.size.height/2) - (buttonHeight/2), TEXT_TOOLBAR_BUTTON_WIDTH, buttonHeight);
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton.layer.cornerRadius = 10;
    [self.sendButton setFrame:sendButtonFrame];
    [self.sendButton setBackgroundColor:[UIColor DONE_BUTTON_COLOR]];
    UIColor *labelColor = [UIColor blueColor];
    UIFont* labelFont = [UIFont fontWithName:BUTTON_FONT size:KEYBOARD_TOOLBAR_FONT_SIZE];
    NSAttributedString* title = [[NSAttributedString alloc] initWithString:@"Send" attributes:@{NSForegroundColorAttributeName: labelColor, NSFontAttributeName : labelFont}];
    [self.sendButton setAttributedTitle:title forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sendButton];
}



-(void) createTextEntryView{
    CGRect tvFrame = CGRectMake(5, 5, self.frame.size.width -  TEXT_TOOLBAR_BUTTON_WIDTH - 10, self.frame.size.height - 10);
    self.hpTextView = [[HPGrowingTextView alloc] initWithFrame:tvFrame];
    [self.hpTextView setFont:[UIFont fontWithName:DEFAULT_FONT size:TEXT_AVE_FONT_SIZE/1.2]];
    self.hpTextView.backgroundColor = [UIColor whiteColor];
    self.hpTextView.textColor = [UIColor blackColor];
    self.hpTextView.delegate = self;
    [self addSubview:self.hpTextView];
}

-(void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height {
    CGFloat baseY = self.frame.origin.y + self.frame.size.height;
    
    CGFloat newFrameY = baseY - height - 10;
    self.frame = CGRectMake(self.frame.origin.x,newFrameY, self.frame.size.width, height + 10);
    
    [self bringSubviewToFront:self.sendButton];
}

-(void) sendButtonPressed {
    if([self.hpTextView.text isEqualToString:@""]) return;
    if(self.delegate){
        [self.delegate sendMessage:self.hpTextView.text];
        self.hpTextView.text = @"";
    }
}




















@end