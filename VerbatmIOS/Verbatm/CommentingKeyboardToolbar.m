//
//  CommentingKeyboardToolbar.m
//  Verbatm
//
//  Created by Iain Usiri on 8/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "CommentingKeyboardToolbar.h"
#import "Styles.h"

@interface CommentingKeyboardToolbar ()
    @property (nonatomic, readwrite) UITextView * commentTextView;
    @property (nonatomic) UIButton * doneButton;
@end

#define X_OFFSET 15.f
#define Y_BUFFER 5.f //Distance between the top/bottom of text view and top/bottom of superview
#define DONE_BUTTON_WIDTH 50.f
@implementation CommentingKeyboardToolbar



-(instancetype)initWithFrame:(CGRect)frame{
    self =[super initWithFrame: frame];
    
    if(self){
        self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.f];
        [self presetTextView];
    }
    return self;
}

-(void)presetTextView{
    
    CGFloat frameWidth = self.frame.size.width - (DONE_BUTTON_WIDTH + (3.f * X_OFFSET));
    CGRect frame = CGRectMake(X_OFFSET, Y_BUFFER, frameWidth, self.frame.size.height - (2*Y_BUFFER));
    
    self.commentTextView = [[UITextView alloc] initWithFrame:frame];
    self.commentTextView.backgroundColor = [UIColor whiteColor];
    [self.commentTextView setFont:[UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWERS_FONT size:CHANNEL_TAB_BAR_FOLLOWERS_FONT_SIZE]];
    self.commentTextView.layer.cornerRadius = 3.f;
    [self addSubview:self.commentTextView];
    
    CGRect doneButtonframe = CGRectMake((2.f*X_OFFSET) + frameWidth, Y_BUFFER,
                                        DONE_BUTTON_WIDTH,self.frame.size.height - (2*Y_BUFFER));
    self.doneButton = [[UIButton alloc] initWithFrame:doneButtonframe];
    [self.doneButton addTarget:self action:@selector(doneButtonSelected) forControlEvents:UIControlEventTouchDown];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self addSubview:self.doneButton];
}

-(BOOL)thereIsAppropriateText:(NSString *) text{
    
    NSString * removeSpaces = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if([removeSpaces isEqualToString:@""]){
        return NO;
    }
    
    return YES;
}

-(void)doneButtonSelected{
    if([self thereIsAppropriateText:self.commentTextView.text]){
        [self.delegate doneButtonSelectedWithFinalString:self.commentTextView.text];
    }
    [self.commentTextView setText:@""];
    [self.commentTextView resignFirstResponder];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
