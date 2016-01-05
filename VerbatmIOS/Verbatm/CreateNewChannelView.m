//
//  CreateNewChannelView.m
//  Verbatm
//
//  Created by Iain Usiri on 1/4/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "CreateNewChannelView.h"
#import "Styles.h"


#define TEXT_FIELD_WALL_OFFSET 10.f

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
    self.layer.borderWidth = 2.f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.layer.shadowRadius = COLLECTION_PINCHVIEW_SHADOW_RADIUS;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 1;
}


-(void)createTextEntryField{
    CGRect textFieldFrame = CGRectMake(TEXT_FIELD_WALL_OFFSET, 0.f, self.frame.size.width - (2*TEXT_FIELD_WALL_OFFSET), self.frame.size.height/2.f);
    self.channelNameField = [[UITextField alloc] initWithFrame:textFieldFrame];
    self.channelNameField.backgroundColor = [UIColor clearColor];
    self.channelNameField.textColor = [UIColor whiteColor];
    UIColor * color = [UIColor whiteColor];
    self.channelNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString: @"Name your channel!" attributes:@{NSForegroundColorAttributeName: color}];
    self.channelNameField.returnKeyType = UIReturnKeyDone;
    [self addSubview:self.channelNameField];
    [self.channelNameField becomeFirstResponder];
    self.channelNameField.delegate = self;
    [self addSubview:self.channelNameField];
}

-(void)createButtons{
    CGRect cancelButtonFrame = CGRectMake(0.f, self.frame.size.height/2.f, self.frame.size.width/2.f, self.frame.size.height/2.f);
    
    self.cancelButton = [[UIButton alloc] initWithFrame:cancelButtonFrame];
    self.cancelButton.backgroundColor = [UIColor clearColor];
    [self.cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.cancelButton.layer.cornerRadius = 2.f;
    self.cancelButton.layer.borderWidth = 1.f;
    self.cancelButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.cancelButton addTarget:self action:@selector(cancelButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    
    CGRect acceptButtonFrame = CGRectMake(self.frame.size.width/2.f, self.frame.size.height/2.f, self.frame.size.width/2.f, self.frame.size.height/2.f);
    self.acceptButton = [[UIButton alloc] initWithFrame:acceptButtonFrame];
    self.acceptButton.backgroundColor = [UIColor clearColor];
    [self.acceptButton setTitle:@"CREATE" forState:UIControlStateNormal];
    [self.acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
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
