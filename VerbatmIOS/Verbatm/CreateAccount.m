//
//  CreateAccount.m
//  Verbatm
//
//  Created by Iain Usiri on 7/8/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "CreateAccount.h"
#import <Crashlytics/Crashlytics.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "Icons.h"
#import "SizesAndPositions.h"
#import "Styles.h"


#import "UserManager.h"
#import "LoginKeyboardToolBar.h"

@interface CreateAccount () <FBSDKLoginButtonDelegate, UITextFieldDelegate,LoginKeyboardToolBarDelegate>
@property (strong, nonatomic) FBSDKLoginButton * facebookLoginButton;
@property (strong, nonatomic) LoginKeyboardToolBar *toolBar;

@property (nonatomic) UIButton * backButton;
@property (nonatomic) UITextField * phoneNumber;
@property (nonatomic) BOOL enteringPhoneNumber;
@property (nonatomic) BOOL nextButtonEnabled;

@property (nonatomic) UITextField * firstPassword;

@property (nonatomic) CGRect originalPhoneTextFrame;


#define ENTER_PHONE_NUMBER_PROMT @"Account with Phone Number"
#define ENTER_PASSWORD_PROMPT @"Enter Password"

@end

@implementation CreateAccount




-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self addFacebookLoginButton];
        [self createPhoneNumebrField];
        [self addSubview:self.backButton];
        [self registerForKeyboardNotifications];
    }
    return self;
    
}

- (void) addFacebookLoginButton {
    self.facebookLoginButton = [[FBSDKLoginButton alloc] init];
    float buttonWidth = self.facebookLoginButton.frame.size.width*1.5;
    float buttonHeight = self.facebookLoginButton.frame.size.height*1.5;
    self.facebookLoginButton.frame = CGRectMake(self.center.x - buttonWidth/2.f, TOP_BUTTON_YOFFSET,
                                        buttonWidth, buttonHeight);
    self.facebookLoginButton.delegate = self;
    self.facebookLoginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    [self addSubview:self.facebookLoginButton];
    [self bringSubviewToFront:self.facebookLoginButton];
}


-(void)createPhoneNumebrField{
    [self addSubview:self.phoneNumber];
}

-(void)createNextButton{
    CGFloat loginToolBarHeight = TEXT_TOOLBAR_HEIGHT*1.5;
    CGRect toolBarFrame = CGRectMake(0, self.frame.size.height - loginToolBarHeight,
                                     self.frame.size.width, loginToolBarHeight);
    self.toolBar = [[LoginKeyboardToolBar alloc] initWithFrame:toolBarFrame];
    self.toolBar.delegate = self;
    [self.toolBar setNextButtonText:@"Next"];
    self.nextButtonEnabled = YES;
    self.firstPassword.inputAccessoryView = self.toolBar;
}

#pragma mark -TOOLBAR NEXT BUTTON-
-(void) nextButtonPressed{
    [self removeKeyBoardOnScreen];
    if([self sanityCheckString:self.phoneNumber.text] && [self sanityCheckString:self.firstPassword.text]){
        [self.delegate signUpWithPhoneNumberSelectedWithNumber:self.phoneNumber.text andPassword:self.firstPassword.text];
        [self removeKeyBoardOnScreen];
    }else{
        [self.delegate textNotAlphaNumericaCreateAccount];
    }
}


-(void)removeKeyBoardOnScreen{
    [self.firstPassword resignFirstResponder];
    [self.phoneNumber resignFirstResponder];
}


-(BOOL)sanityCheckString:(NSString *)text{
    NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
    
    s = [s invertedSet];
    NSRange r = [text rangeOfCharacterFromSet:s];
    if (r.location != NSNotFound) {
        //string contains illegal characters
        return NO;
    }
    return YES;
}

#pragma mark - Facebook Button Delegate  -

- (void)  loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
                error:(NSError *)error {
    
    if (error || result.isCancelled) {
        [[Crashlytics sharedInstance] recordError:error];
        [self.delegate errorInSignInWithError: @"Facebook login failed."];
        return;
    }
    
    //TODO(sierrakn): If any declined permissions are essential
    //explain to user why and ask them to agree to each individually
    //	NSSet* declinedPermissions = result.declinedPermissions;
    
    //batch request for user info as well as friends
    if ([FBSDKAccessToken currentAccessToken]) {
        [[UserManager sharedInstance] signUpOrLoginUserFromFacebookToken: [FBSDKAccessToken currentAccessToken]];
    } else {
        [self.delegate errorInSignInWithError: @"Facebook login failed."];
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    [[UserManager sharedInstance] logOutUser];
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

#pragma mark - Keyboard moving up and down -

-(void) keyboardWillShow:(NSNotification*)notification {
    [self.facebookLoginButton setHidden:YES];
    
    CGFloat keyboardOffset = 0.f;
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];
    
    CGFloat newYOrigin = (self.frame.size.height - keyboardBounds.size.height -
                          self.phoneNumber.frame.size.height - TEXT_TOOLBAR_HEIGHT - 50.f);
    if (newYOrigin < self.phoneNumber.frame.origin.y) {
        keyboardOffset = self.phoneNumber.frame.origin.y - newYOrigin;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [self shiftPhoneFieldUp:YES];
    }completion:^(BOOL finished) {
        if(finished){
             [self.firstPassword setHidden:NO];
            [self bringSubviewToFront:self.firstPassword];
        }
    }];
}

-(void)shiftPhoneFieldUp:(BOOL) up{
    if(up){
        self.phoneNumber.frame = CGRectOffset(self.phoneNumber.frame, 0, self.facebookLoginButton.frame.origin.y - self.phoneNumber.frame.origin.y);
    }else{
        self.phoneNumber.frame = self.originalPhoneTextFrame;
    }
}
-(void) keyboardWillHide:(NSNotification*)notification {
    [self.facebookLoginButton setHidden:NO];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self shiftPhoneFieldUp:NO];
        [self.firstPassword setHidden:YES];
    }];
}



#pragma mark - Formatting phone number -

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.enteringPhoneNumber) {
        [self setEnteringPhone];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* totalString = [NSString stringWithFormat:@"%@%@",textField.text,string];
    
    // if it's the phone number textfield format it.
    if(textField == self.phoneNumber && self.enteringPhoneNumber) {
        if (range.length == 1) {
            // Delete button was hit.. so tell the method to delete the last char.
            textField.text = [self formatPhoneNumber:totalString deleteLastChar:YES];
        } else {
            textField.text = [self formatPhoneNumber:totalString deleteLastChar:NO];
        }
        return NO;
    }
    return YES;
}

-(NSString*) formatPhoneNumber:(NSString*) number deleteLastChar:(BOOL)deleteLastChar {
    
    if(number.length==0) return @"";
    NSString *simpleNumber = [self getSimpleNumberFromFormattedPhoneNumber:number];
    
    // check if the number is too long
    if(simpleNumber.length > 10) {
        simpleNumber = [simpleNumber substringToIndex:10];
    }
    
    // should we delete the last digit?
    if(deleteLastChar) {
        simpleNumber = [simpleNumber substringToIndex:[simpleNumber length] - 1];
    }
    
    // 123 456 7890
    // format the number.. if it's less then 7 digits.. then use this regex.
    if(simpleNumber.length < 7) {
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d+)"
                                                               withString:@"($1) $2"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
        
    } else {  // else do this one..
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d+)"
                                                               withString:@"($1) $2-$3"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    }
    return simpleNumber;
}

-(NSString*) getSimpleNumberFromFormattedPhoneNumber:(NSString*)formattedPhoneNumber {
    // use regex to remove non-digits(including spaces) so we are left with just the numbers
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString* simpleNumber = [regex stringByReplacingMatchesInString:formattedPhoneNumber options:0 range:NSMakeRange(0, [formattedPhoneNumber length]) withTemplate:@""];
    return simpleNumber;
}

-(void) setEnteringPhone {
    self.enteringPhoneNumber = YES;
    self.phoneNumber.text = @"";
    self.phoneNumber.placeholder = @"Enter your phone number";
}



-(void)backButtonSelected{
    [self removeKeyBoardOnScreen];
    [self shiftPhoneFieldUp:NO];
    [self.delegate goBackSelectedCreateAccount];
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


-(UITextField *)phoneNumber{
    
    if(!_phoneNumber){
    
        CGRect frame = CGRectMake(self.facebookLoginButton.frame.origin.x, self.facebookLoginButton.frame.origin.y + self.facebookLoginButton.frame.size.height + SIGN_UP_BUTTON_GAP,
                              self.facebookLoginButton.frame.size.width, PHONE_NUMBER_FIELD_HEIGHT);
        _phoneNumber = [[UITextField alloc] initWithFrame:frame];
        self.originalPhoneTextFrame = frame;
        _phoneNumber.backgroundColor = [UIColor whiteColor];
        _phoneNumber.delegate = self;
        _phoneNumber.layer.cornerRadius = TEXTFIELDS_CORNER_RADIUS;
        [_phoneNumber setPlaceholder:ENTER_PHONE_NUMBER_PROMT];
        _phoneNumber.keyboardType = UIKeyboardTypePhonePad;

    }
    return _phoneNumber;
}
-(UITextField *)firstPassword{
    if(!_firstPassword){
        CGRect frame = CGRectMake(self.phoneNumber.frame.origin.x, self.facebookLoginButton.frame.origin.y + self.phoneNumber.frame.size.height + 5.f, self.phoneNumber.frame.size.width, self.phoneNumber.frame.size.height);
        _firstPassword = [[UITextField alloc] initWithFrame:frame];
        _firstPassword.backgroundColor = [UIColor whiteColor];
        _firstPassword.delegate = self;
        [_firstPassword setPlaceholder:ENTER_PASSWORD_PROMPT];
        _firstPassword.layer.cornerRadius = TEXTFIELDS_CORNER_RADIUS;
        [self addSubview:_firstPassword];
         [self createNextButton];
    }
    return _firstPassword;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
