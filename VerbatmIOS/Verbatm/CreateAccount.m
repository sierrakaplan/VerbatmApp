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
@property (nonatomic) UITextField * phoneNumberField;
@property (nonatomic) BOOL enteringPhoneNumber;
@property (nonatomic) BOOL nextButtonEnabled;

@property (nonatomic) UITextField * createName;
@property (nonatomic) CGRect originalPhoneTextFrame;

@property (nonatomic) UILabel * orLabel;

#define ENTER_PHONE_NUMBER_PROMT @"Enter Phone Number"
#define CREATE_USERNAME @"Enter a Name"
@end

@implementation CreateAccount


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self addFacebookLoginButton];
        [self createPhoneNumberField];
        [self addSubview:self.backButton];
        [self addSubview:self.orLabel];
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


-(void)createPhoneNumberField{
    [self addSubview:self.phoneNumberField];
}

-(void)createNextButton {
    CGRect toolBarFrame = CGRectMake(0, self.frame.size.height - LOGIN_TOOLBAR_HEIGHT,
                                     self.frame.size.width, LOGIN_TOOLBAR_HEIGHT);
    self.toolBar = [[LoginKeyboardToolBar alloc] initWithFrame:toolBarFrame];
    self.toolBar.delegate = self;
    [self.toolBar setNextButtonText:@"Next"];
    self.nextButtonEnabled = YES;
}

#pragma mark - TOOLBAR NEXT BUTTON -

-(void) nextButtonPressed {
	NSString *simplePhoneNumber = [self getSimpleNumberFromFormattedPhoneNumber: self.phoneNumberField.text];
	if([self sanityCheckPhoneNumberString: simplePhoneNumber]
       && [self sanityCheckName:self.createName.text] ) {
        [self.delegate signUpWithPhoneNumberSelectedWithNumber:[self removeSpaces:simplePhoneNumber]
												   andName:self.createName.text];
        [self removeKeyBoardOnScreen];
    }
}

-(BOOL)sanityCheckName:(NSString *)creatorName{
    
    if ([[self removeSpaces:creatorName] isEqualToString:@""]){
        //string is just space characters
        [self.delegate verbatmNameWrongFormatCreateAccount];
        return NO;
    }
    return YES;
}

-(NSString *)removeSpaces:(NSString *)text {
    return  [text stringByReplacingOccurrencesOfString:@" " withString:@""];
}

-(BOOL)sanityCheckPhoneNumberString:(NSString *)text {
//    NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
//    s = [s invertedSet];
//    NSRange r = [[self removeSpaces:text] rangeOfCharacterFromSet:s];
//    
//    if (r.location != NSNotFound || text.length != 10) {
//        //string contains illegal characters
//        [self.delegate phoneNumberWrongFormatCreateAccount];
//        return NO;
//    }
    return YES;
}


-(void)removeKeyBoardOnScreen {
    [self.phoneNumberField resignFirstResponder];
    [self.createName resignFirstResponder];
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
    [self.orLabel setHidden:YES];
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];
	CGFloat keyboardOffset = 0.f;
	CGFloat padding = 20.f;
    CGFloat newYOrigin = (self.frame.size.height - keyboardBounds.size.height -
                          self.phoneNumberField.frame.size.height - LOGIN_TOOLBAR_HEIGHT - padding);
    if (newYOrigin < self.phoneNumberField.frame.origin.y) {
        keyboardOffset = self.phoneNumberField.frame.origin.y - newYOrigin;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [self shiftPhoneFieldUp:YES];
    }completion:^(BOOL finished) {
        if(finished){
            [self.createName setHidden:NO];
            [self bringSubviewToFront:self.createName];
        }
    }];
}

-(void)shiftPhoneFieldUp:(BOOL) up{
    if(up) {
        self.phoneNumberField.frame = CGRectOffset(self.phoneNumberField.frame, 0, self.facebookLoginButton.frame.origin.y -
												   self.phoneNumberField.frame.origin.y - LOGIN_TOOLBAR_HEIGHT); // make room for next button
        [self.createName setHidden:NO];
    }else{
        self.phoneNumberField.frame = self.originalPhoneTextFrame;
        [self.createName setHidden:YES];
        [self.orLabel setHidden:NO];
    }
}
-(void) keyboardWillHide:(NSNotification*)notification {
    [self.facebookLoginButton setHidden:NO];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self shiftPhoneFieldUp:NO];
        [self.createName setHidden:YES];
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
    if(textField == self.phoneNumberField) {
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
    self.phoneNumberField.text = @"";
    self.phoneNumberField.placeholder = @"Enter your phone number";
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


-(UITextField *)phoneNumberField {
    
    if(!_phoneNumberField){
    
        CGRect frame = CGRectMake(self.facebookLoginButton.frame.origin.x, self.orLabel.frame.origin.y + self.orLabel.frame.size.height
								  + SIGN_UP_BUTTON_GAP,
                              self.facebookLoginButton.frame.size.width, PHONE_NUMBER_FIELD_HEIGHT);
        _phoneNumberField = [[UITextField alloc] initWithFrame:frame];
        self.originalPhoneTextFrame = frame;
        _phoneNumberField.backgroundColor = [UIColor whiteColor];
        _phoneNumberField.delegate = self;
        _phoneNumberField.layer.cornerRadius = TEXTFIELDS_CORNER_RADIUS;
        [_phoneNumberField setPlaceholder:ENTER_PHONE_NUMBER_PROMT];
        _phoneNumberField.keyboardType = UIKeyboardTypePhonePad;
        _phoneNumberField.textAlignment = NSTextAlignmentCenter;

    }
    return _phoneNumberField;
}

-(UITextField *)createName{
    if(!_createName){
        CGRect frame = CGRectMake(self.phoneNumberField.frame.origin.x, self.phoneNumberField.frame.origin.y +
								  self.phoneNumberField.frame.size.height + 5.f, self.phoneNumberField.frame.size.width,
								  self.phoneNumberField.frame.size.height);
        _createName = [[UITextField alloc] initWithFrame:frame];
        _createName.backgroundColor = [UIColor whiteColor];
        _createName.delegate = self;
        [_createName setPlaceholder:CREATE_USERNAME];
        _createName.layer.cornerRadius = TEXTFIELDS_CORNER_RADIUS;
        _createName.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_createName];
    }
    return _createName;
}

-(UILabel *)orLabel{
    if(!_orLabel){
        
        CGFloat yPos = self.facebookLoginButton.frame.origin.y + self.facebookLoginButton.frame.size.height;
        _orLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.center.x - OR_LABEL_WIDTH/2.f, yPos + SIGN_UP_BUTTON_GAP,
															 OR_LABEL_WIDTH, OR_LABEL_WIDTH)];
        [_orLabel setText:@"OR"];
        [_orLabel setBackgroundColor:[UIColor clearColor]];
        [_orLabel setTextColor:[UIColor whiteColor]];
        [_orLabel setFont:[UIFont fontWithName:BOLD_FONT size:HEADER_TEXT_SIZE]];
    }
    return _orLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
