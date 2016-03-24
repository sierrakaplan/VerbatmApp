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


#define TEXT_FIELD_WALL_OFFSET 10.f

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
    self.layer.cornerRadius = 10.f;
    self.layer.borderColor = VERBATM_GOLD_COLOR.CGColor;
    
    
    self.layer.borderWidth = 1.f;
    self.clipsToBounds = YES;
}


-(void)createTextEntryField{
    CGRect textFieldFrame = CGRectMake(TEXT_FIELD_WALL_OFFSET, 0.f, self.frame.size.width - (2*TEXT_FIELD_WALL_OFFSET), self.frame.size.height/3.f);
    self.channelNameField = [[UITextField alloc] initWithFrame:textFieldFrame];
    self.channelNameField.backgroundColor = [UIColor clearColor];
    self.channelNameField.textColor = [UIColor whiteColor];
    UIColor * color = [UIColor whiteColor];
    UIFont * placeHolderTextFont = [UIFont fontWithName:CHANNEL_CREATION_USER_TEXT_ENTRY_PLACEHOLDER_FONT size: FOLLOWER_TEXT_FONT_SIZE];
    
    UIFont * entryTextFont = [UIFont fontWithName:CHANNEL_CREATION_USER_TEXT_ENTRY_FONT size: FOLLOWER_TEXT_FONT_SIZE];
    
    //order of setting font here matters -- first set text font then create placeholder
    
    [self.channelNameField setFont: entryTextFont];
    
    self.channelNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString: @"Name your channel!" attributes:@{NSForegroundColorAttributeName: color,  NSFontAttributeName:placeHolderTextFont }];
    
    
    
    self.channelNameField.returnKeyType = UIReturnKeyDone;
    [self addSubview:self.channelNameField];
    [self.channelNameField becomeFirstResponder];
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    self.channelNameField.delegate = self;
    [self addSubview:self.channelNameField];
}

-(void)createButtons{
    
    CGRect cancelButtonFrame = CGRectMake(-5.f, self.frame.size.height - BUTTON_HEIGHT, (self.frame.size.width/2.f) + 5.f, BUTTON_HEIGHT+ 5.f);
    
    self.cancelButton = [[UIButton alloc] initWithFrame:cancelButtonFrame];
    self.cancelButton.backgroundColor = [UIColor clearColor];
    
    [self.cancelButton setAttributedTitle:[[NSAttributedString alloc] initWithString: @"Cancel" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],  NSFontAttributeName: [UIFont fontWithName:CHANNEL_CREATION_BUTTON_FONT size: CANCEL_CREATE_FONT_SIZE] }] forState:UIControlStateNormal];
    
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    
    self.cancelButton.layer.cornerRadius = 2.f;
    self.cancelButton.layer.borderWidth = 0.5;
    self.cancelButton.layer.borderColor = VERBATM_GOLD_COLOR.CGColor;
    [self.cancelButton addTarget:self action:@selector(cancelButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    
    CGRect acceptButtonFrame = CGRectMake(self.frame.size.width/2.f, self.frame.size.height - BUTTON_HEIGHT, (self.frame.size.width/2.f) + 5.f,BUTTON_HEIGHT + 5.f);
    self.acceptButton = [[UIButton alloc] initWithFrame:acceptButtonFrame];
    self.acceptButton.backgroundColor = [UIColor clearColor];
    
    [self.acceptButton setAttributedTitle:[[NSAttributedString alloc] initWithString: @"Create" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],  NSFontAttributeName: [UIFont fontWithName:CHANNEL_CREATION_BUTTON_FONT size: CANCEL_CREATE_FONT_SIZE] }] forState:UIControlStateNormal];

    
    self.acceptButton.layer.cornerRadius = 2.f;
    self.acceptButton.layer.borderWidth = 0.5;
    self.acceptButton.layer.borderColor = VERBATM_GOLD_COLOR.CGColor;
    
    [self.acceptButton addTarget:self action:@selector(acceptButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelButton];
    [self addSubview:self.acceptButton];
}


-(void)cancelButtonSelected:(UIButton *) button{
    [self.delegate cancelCreation];
}

-(void)acceptButtonSelected:(UIButton *) button{
    
    if(![self stringHasCharacters:self.channelNameField.text])return;
    
    [self.delegate createChannelWithName:self.channelNameField.text];
}

//checks if there are actually characters in the string not just spaces
-(BOOL)stringHasCharacters:(NSString *) text{
    NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
    return ![[text stringByTrimmingCharactersInSet:alphaSet] isEqualToString:text];
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
