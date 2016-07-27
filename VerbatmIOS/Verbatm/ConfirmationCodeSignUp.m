//
//  ConfirmationCodeSignUp.m
//  Verbatm
//
//  Created by Iain Usiri on 7/9/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "ConfirmationCodeSignUp.h"
#import "Icons.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "LoginKeyboardToolBar.h"
@interface ConfirmationCodeSignUp ()<UITextFieldDelegate,LoginKeyboardToolBarDelegate>
@property (nonatomic) UIButton * backButton;
@property (nonatomic) UILabel * numberDispaly;
@property (nonatomic) UITextField * confirmationCodeField;
@property (strong, nonatomic) LoginKeyboardToolBar *toolBar;
@property (nonatomic, strong) UIButton * resendCodeButton;

@end


#define CODE_CONFIRM_PROMPT @"Enter Code"
@implementation ConfirmationCodeSignUp



-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self addSubview:self.backButton];
        [self addSubview:self.numberDispaly];
        [self addSubview:self.confirmationCodeField];
        //[self addSubview:self.resendCodeButton];
        [self createNextButton];
        [self registerForKeyboardNotifications];
    }
    return self;
    
}


- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}



-(void)createNextButton{
    CGFloat loginToolBarHeight = TEXT_TOOLBAR_HEIGHT*(3.f/4.f);
    CGRect toolBarFrame = CGRectMake(0, self.frame.size.height - loginToolBarHeight,
                                     self.frame.size.width, loginToolBarHeight);
    self.toolBar = [[LoginKeyboardToolBar alloc] initWithFrame:toolBarFrame];
    self.toolBar.delegate = self;
    [self.toolBar setNextButtonText:@"Submit Code"];
    self.confirmationCodeField.inputAccessoryView = self.toolBar;
}
-(void) nextButtonPressed{
    [self.delagate codeSubmittedConfirmationCode:self.confirmationCodeField.text];
}

#pragma mark - Keyboard moving up and down -

-(void) keyboardWillShow:(NSNotification*)notification {

    
    [UIView animateWithDuration:0.2 animations:^{
        [self shiftPhoneFieldUp:YES];
    }completion:^(BOOL finished) {
        if(finished){
        }
    }];
}

-(void)shiftPhoneFieldUp:(BOOL) up{
    if(up){
        
    }else{
    }
}
-(void) keyboardWillHide:(NSNotification*)notification {
    
    [UIView animateWithDuration:0.2 animations:^{
        [self shiftPhoneFieldUp:NO];
    }];
}


-(void)resendCodeSelected{
    [self.delagate resendCodeSelectedConfirmationCode];
}

-(void)backButtonSelected{
    [self.confirmationCodeField resignFirstResponder];
    [self.delagate goBackSelectedConfirmationCode];
}

-(void)setPhoneNumberEntered:(NSString *)phoneNumberEntered{
    _phoneNumberEntered = phoneNumberEntered;
    self.numberDispaly.text = [@"Code sent to: " stringByAppendingString:self.phoneNumberEntered] ;
}


-(UILabel *)numberDispaly{
    if(!_numberDispaly){
        CGFloat buttonWidth = PHONE_NUMBER_FIELD_HEIGHT * 9.f;
        _numberDispaly = [[UILabel alloc]initWithFrame:CGRectMake(self.center.x - buttonWidth/2.f, TOP_BUTTON_YOFFSET,
                                                                  buttonWidth, PHONE_NUMBER_FIELD_HEIGHT)];
        _numberDispaly.backgroundColor = PROFILE_INFO_BAR_BACKGROUND_COLRO;
        _numberDispaly.textColor = [UIColor whiteColor];
        _numberDispaly.layer.borderColor = [UIColor whiteColor].CGColor;
        _numberDispaly.layer.cornerRadius = TEXTFIELDS_CORNER_RADIUS;
        _numberDispaly.adjustsFontSizeToFitWidth = YES;
        _numberDispaly.textAlignment = NSTextAlignmentCenter;
        [_numberDispaly setFont:[UIFont fontWithName:BOLD_FONT size:USER_CHANNEL_LIST_FONT_SIZE]];
        
        [_numberDispaly setUserInteractionEnabled:NO];
        [self addSubview:_numberDispaly];
    }
    return _numberDispaly;
}

-(UITextField*) confirmationCodeField {
    if(!_confirmationCodeField) {
        CGFloat width = self.numberDispaly.frame.size.width/2.f;
        
        CGRect frame = CGRectMake(self.center.x - width/2.f , self.numberDispaly.frame.origin.y + self.numberDispaly.frame.size.height + 10.f,width, PHONE_NUMBER_FIELD_HEIGHT);
        _confirmationCodeField = [[UITextField alloc] initWithFrame:frame];
        _confirmationCodeField.backgroundColor = [UIColor whiteColor];
        _confirmationCodeField.delegate = self;
        _confirmationCodeField.layer.cornerRadius = TEXTFIELDS_CORNER_RADIUS;
        [_confirmationCodeField setPlaceholder:CODE_CONFIRM_PROMPT];
        _confirmationCodeField.keyboardType = UIKeyboardTypePhonePad;
    }
    return _confirmationCodeField;
}


-(UIButton *)resendCodeButton{
    if(!_resendCodeButton){
        CGFloat width = self.numberDispaly.frame.size.width/2.f;
        CGRect frame = CGRectMake(self.confirmationCodeField.frame.origin.x,self.confirmationCodeField.frame.origin.y +
                                  self.confirmationCodeField.frame.size.height+ 10.f,
                                  width, SIGNUP_BACK_BUTTON_SIZE);
        _resendCodeButton =[[UIButton alloc] initWithFrame:frame];
        [_resendCodeButton setTitle:@"Send new code" forState:UIControlStateNormal];
        [_resendCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_resendCodeButton setBackgroundColor:[UIColor redColor]];
        [_resendCodeButton addTarget:self action:@selector(resendCodeSelected) forControlEvents:UIControlEventTouchDown];
    }
    return _resendCodeButton;
}
-(UIButton *)backButton{
    if(!_backButton){
        CGRect frame = CGRectMake(BACK_BUTTON_OFFSET, BACK_BUTTON_OFFSET, SIGNUP_BACK_BUTTON_SIZE, SIGNUP_BACK_BUTTON_SIZE);
        _backButton =[[UIButton alloc] initWithFrame:frame];
        [_backButton setImage:[UIImage imageNamed:PROFILE_BACK_BUTTON_ICON] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonSelected) forControlEvents:UIControlEventTouchDown];
    }
    return _backButton;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
