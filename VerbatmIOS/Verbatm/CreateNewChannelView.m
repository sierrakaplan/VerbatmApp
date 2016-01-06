//
//  CreateNewChannelView.m
//  Verbatm
//
//  Created by Iain Usiri on 1/4/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "CreateNewChannelView.h"
#import "SizesAndPositions.h"
#import "Styles.h"


#define TEXT_FIELD_WALL_OFFSET 0.f

#define FOLLOWER_TEXT_FONT_SIZE 20.f
#define CANCEL_CREATE_FONT_SIZE 18.f
#define BUTTON_HEIGHT 50.f

@interface CreateNewChannelView ()<UITextFieldDelegate>
@property (nonatomic) UITextField * channelNameField;
@property (nonatomic) UIButton * cancelButton;
@property (nonatomic) UIButton * acceptButton;
@end


@implementation CreateNewChannelView


-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if(self){
        [self formatViews];
    }
    return self;
}

-(void)formatViews{
    [self createTextEntryField];
    [self createButtons];
    self.backgroundColor = [UIColor blackColor];
    self.layer.cornerRadius = 5.f;
}


-(void)createTextEntryField{
    CGRect textFieldFrame = CGRectMake(TEXT_FIELD_WALL_OFFSET, 0.f, self.frame.size.width - (2*TEXT_FIELD_WALL_OFFSET), self.frame.size.height/3.f);
    self.channelNameField = [[UITextField alloc] initWithFrame:textFieldFrame];
    self.channelNameField.backgroundColor = [UIColor clearColor];
    self.channelNameField.textColor = [UIColor whiteColor];
    UIColor * color = [UIColor whiteColor];
    self.channelNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString: @"Name your channel!" attributes:@{NSForegroundColorAttributeName: color,  NSFontAttributeName: [UIFont fontWithName:TAB_BAR_FOLLOWERS_FONT size: FOLLOWER_TEXT_FONT_SIZE] }];
    self.channelNameField.returnKeyType = UIReturnKeyDone;
    [self addSubview:self.channelNameField];
    [self.channelNameField becomeFirstResponder];
    self.channelNameField.delegate = self;
    [self addSubview:self.channelNameField];
}

-(void)createButtons{
    
    CGRect cancelButtonFrame = CGRectMake(0.f, self.frame.size.height - BUTTON_HEIGHT, self.frame.size.width/2.f, BUTTON_HEIGHT);
    
    self.cancelButton = [[UIButton alloc] initWithFrame:cancelButtonFrame];
    self.cancelButton.backgroundColor = [UIColor clearColor];
    
    [self.cancelButton setAttributedTitle:[[NSAttributedString alloc] initWithString: @"Cancel" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],  NSFontAttributeName: [UIFont fontWithName:TAB_BAR_FOLLOWERS_FONT size: CANCEL_CREATE_FONT_SIZE] }] forState:UIControlStateNormal];
    
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    
    self.cancelButton.layer.cornerRadius = 2.f;
    self.cancelButton.layer.borderWidth = 1.f;
    self.cancelButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.cancelButton addTarget:self action:@selector(cancelButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    
    CGRect acceptButtonFrame = CGRectMake(self.frame.size.width/2.f, self.frame.size.height - BUTTON_HEIGHT, self.frame.size.width/2.f,BUTTON_HEIGHT);
    self.acceptButton = [[UIButton alloc] initWithFrame:acceptButtonFrame];
    self.acceptButton.backgroundColor = [UIColor clearColor];
    
    [self.acceptButton setAttributedTitle:[[NSAttributedString alloc] initWithString: @"Create" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],  NSFontAttributeName: [UIFont fontWithName:TAB_BAR_FOLLOWERS_FONT size: CANCEL_CREATE_FONT_SIZE] }] forState:UIControlStateNormal];

    
    self.acceptButton.layer.cornerRadius = 2.f;
    self.acceptButton.layer.borderWidth = 1.f;
    self.acceptButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [self.acceptButton addTarget:self action:@selector(acceptButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelButton];
    [self addSubview:self.acceptButton];
}


-(void)cancelButtonSelected:(UIButton *) button{
    [self.delegate cancelCreation];
}

-(void)acceptButtonSelected:(UIButton *) button{
    [self.delegate createChannelWithName:self.channelNameField.text];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
