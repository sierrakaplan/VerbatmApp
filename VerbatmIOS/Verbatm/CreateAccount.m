//
//  CreateAccount.m
//  Verbatm
//
//  Created by Iain Usiri on 9/11/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "CreateAccount.h"
#import "Durations.h"

#import "SegueIDs.h"
#import "SizesAndPositions.h"
#import "Styles.h"

#import "UserManager.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/PFUser.h>
#import <ParseFacebookutilsV4/PFFacebookUtils.h>


@interface CreateAccount () <FBSDKLoginButtonDelegate, UITextFieldDelegate, UserManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *fullnameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (strong, nonatomic) UIButton* signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *loginRedirectButton;
@property (strong, nonatomic) FBSDKLoginButton * loginButton;

@property (nonatomic) BOOL signUpButtonOnScreen;

@property (strong, nonatomic) UIView *animationView;
@property (strong, nonatomic) UILabel* animationLabel;
@property (strong, nonatomic) NSTimer * animationTimer;

@property (strong, nonatomic) UserManager* userManager;

#define FACEBOOK_BUTTON_YOFFSET 60
#define SIGN_UP_BUTTON_TEXT @"Sign Up"
#define BRING_UP_SIGNIN_SEGUE @"login_segue"

@end

@implementation CreateAccount

-(void) viewDidLoad {
	[super viewDidLoad];
	if (self) {
		self.signUpButtonOnScreen = NO;
        [self addFacebookLoginButton];
		[self formatTextFields];
        [self addTapGestureToRemoveKeyboard];
		
	}
}

-(void) formatTextFields {
	[self setTextFieldFrames];
	[self setTextFieldDelegates];
}

-(void) setTextFieldFrames {
    self.orLabel.frame = CGRectMake((self.view.center.x) - (self.orLabel.frame.size.width/2.f), self.loginButton.frame.origin.y +
                                    self.loginButton.frame.size.height + DISTANCE_BETWEEN_FIELDS,
                                    self.orLabel.frame.size.width, self.orLabel.frame.size.height);
    
    self.emailField.frame = CGRectMake((self.view.frame.size.width/2.f) - (self.emailField.frame.size.width/2.f) , self.orLabel.frame.origin.y +
                                       self.orLabel.frame.size.height + DISTANCE_BETWEEN_FIELDS,
                                       self.emailField.frame.size.width, self.emailField.frame.size.height);
    
	self.fullnameField.frame = CGRectMake((self.view.center.x) - (self.fullnameField.frame.size.width/2.f) ,
                                          self.emailField.frame.origin.y +
                                          self.emailField.frame.size.height + DISTANCE_BETWEEN_FIELDS,
                                          self.fullnameField.frame.size.width, self.fullnameField.frame.size.height);
	self.passwordField.frame = CGRectMake((self.view.center.x) - (self.passwordField.frame.size.width/2.f) ,
                                          self.fullnameField.frame.origin.y +
                                          self.fullnameField.frame.size.height + DISTANCE_BETWEEN_FIELDS,
                                          self.passwordField.frame.size.width, self.passwordField.frame.size.height);
	self.phoneNumberField.frame = CGRectMake((self.view.center.x) - (self.phoneNumberField.frame.size.width/2.f) ,
                                             self.passwordField.frame.origin.y +
                                             self.passwordField.frame.size.height + DISTANCE_BETWEEN_FIELDS,
                                             self.phoneNumberField.frame.size.width, self.phoneNumberField.frame.size.height);
    self.loginRedirectButton.frame = CGRectMake((self.view.center.x) - (self.loginRedirectButton.frame.size.width/2.f) ,
                                                self.loginRedirectButton.frame.origin.y,
                                                self.loginRedirectButton.frame.size.width, self.loginRedirectButton.frame.size.height);
}

-(void) setTextFieldDelegates {
	self.emailField.delegate = self;
	self.passwordField.delegate = self;
	self.fullnameField.delegate = self;
	self.phoneNumberField.delegate = self;
}

- (void) addFacebookLoginButton {
	self.loginButton = [[FBSDKLoginButton alloc] init];
	float buttonWidth = self.loginButton.frame.size.width*1.5;
	float buttonHeight = self.loginButton.frame.size.height*1.5;
	self.loginButton.frame = CGRectMake(self.view.center.x - buttonWidth/2, FACEBOOK_BUTTON_YOFFSET, buttonWidth, buttonHeight);
	self.loginButton.delegate = self;
	self.loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
	[self.view addSubview:self.loginButton];
}


//We add a sign up button to the screen once user starts typing in
//any of the create account fields (once they don't sign up with FB)
-(void)replaceOrFBWithSignUpButton {
	if (self.signUpButtonOnScreen) {
		return;
	}

	float buttonWidth  = self.fullnameField.frame.size.width;
	float buttonX = self.view.center.x - buttonWidth/2;
	float buttonY = self.phoneNumberField.frame.origin.y + FACEBOOK_BUTTON_YOFFSET;
	float buttonHeight = self.fullnameField.frame.size.height;
	self.signUpButton = [[UIButton alloc] initWithFrame: CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight)];
	[self.signUpButton setTitle: SIGN_UP_BUTTON_TEXT forState:UIControlStateNormal];
	self.signUpButton.backgroundColor = [UIColor lightGrayColor];
	[self.signUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[self.signUpButton addTarget:self action:@selector(completeAccountCreation) forControlEvents:UIControlEventTouchUpInside];


	[self.view addSubview: self.signUpButton];
	self.signUpButtonOnScreen = YES;
}

#pragma mark - Completing account creation -

//Called when user presses signUp
-(void) completeAccountCreation {

	NSString* email = self.emailField.text;
	NSString* phoneNumber = self.phoneNumberField.text;
	NSString* password = self.passwordField.text;
	NSString* name = self.fullnameField.text;

	if (email.length > 0 &&
		password.length > 0 &&
		name.length > 0) {

		[self.userManager signUpUserFromEmail: email andName: name andPassword:password andPhoneNumber: phoneNumber];
	} else {
		[self errorInSignInAnimation: @"Please enter all required fields"];
	}
}

#pragma mark - Facebook Button Delegate -

/*!
 @abstract Sent to the delegate when the button was used to login.
 @param loginButton the sender
 @param result The results of the login
 @param error The error (if any) from the login
 */
- (void)  loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
				error:(NSError *)error {

	if (error || result.isCancelled) {
		NSLog(@"Error in facebook login: %@", error.description);
		[self errorInSignInAnimation: @"Facebook login failed."];
		return;
	}

	//TODO(sierrakn): If any declined permissions are essential
	//explain to user why and ask them to agree to each individually
	NSSet* declinedPermissions = result.declinedPermissions;
	NSLog(@"User declined fb permissions for %@", declinedPermissions);

	//batch request for user info as well as friends
	if ([FBSDKAccessToken currentAccessToken]) {
		NSLog(@"Successfully logged in with Facebook");
		[self.userManager signUpOrLoginUserFromFacebookToken: [FBSDKAccessToken currentAccessToken]];
	} else {
		[self errorInSignInAnimation: @"Facebook login failed."];
	}
}

/*!
 @abstract Sent to the delegate when the button was used to logout.
 @param loginButton The button that was clicked.
 */
- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
	[self.userManager logOutUser];
}

#pragma mark - User Manager Delegate methods -

-(void) successfullyLoggedInUser: (GTLVerbatmAppVerbatmUser*) user {
	[self unwindToMasterVC];
}

-(void) errorLoggingInUser: (NSError*) error {
	NSString* errorMessage;
	switch ([error code]) {
		case kPFErrorUsernameTaken:
		case kPFErrorUserEmailTaken: {
			errorMessage = @"An account with that email already exists. Try logging in (do you know if you logged in with Facebook last time?)";
			break;
		}
		default: {
			errorMessage = @"We're sorry, something went wrong!";
		}
	}
	[self errorInSignInAnimation:errorMessage];
}

// Unwind segue back to master vc
-(void) unwindToMasterVC {
	[self performSegueWithIdentifier:UNWIND_SEGUE_FROM_CREATE_ACCOUNT_TO_MASTER sender:self];
}

#pragma mark - Error message animation -

-(void)errorInSignInAnimation:(NSString*) errorMessage {
	NSLog(@"Error: \"%@\"", errorMessage);
	if(self.animationView.alpha > 0) return;
	[self.animationLabel setText:errorMessage];
	[self.view addSubview:self.animationView];
	[self.view bringSubviewToFront:self.animationView];
	[self showAnimationView:YES];
	self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:ERROR_MESSAGE_ANIMATION_TIME target:self selector:@selector(removeAnimationView) userInfo:nil repeats:YES];
}

-(void) removeAnimationView {
	[self showAnimationView:NO];
}

-(void)showAnimationView:(BOOL)show {
	[UIView animateWithDuration:REMOVE_SIGNIN_ERROR_VIEW_ANIMATION_DURATION animations:^{
		self.animationView.alpha= show ? 1.f : 0;
	} completion:^(BOOL finished) {
		if (!show) {
			[self.animationTimer invalidate];
			self.animationTimer = nil;
			[self.animationView removeFromSuperview];
		}
	}];
}

#pragma mark - Text field Delegate -

- (void)textFieldDidBeginEditing: (UITextField *)textField {
	if (!self.signUpButtonOnScreen) {
		[self replaceOrFBWithSignUpButton];
	}
}

//TODO:
// Enter button should navigate between fields
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
//	if (textField == self.emailField){
//		[self.passwordField becomeFirstResponder];
//		return YES;
//	}
//	if (textField == self.passwordField){
//		//TODO: trigger login button
//		[self.passwordField resignFirstResponder];
//		return YES;
//	}
	return NO;
}

#pragma mark - Navigation

// Segue back to the MasterNavigationVC after logging in
// Or segue to Sign In
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.
}




-(void)addTapGestureToRemoveKeyboard{
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeKeyboardTap)];
    [self.view addGestureRecognizer:tapGesture];
}

-(void) removeKeyboardTap {    
    [self.emailField resignFirstResponder];
    [self.fullnameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.phoneNumberField resignFirstResponder];
}


#pragma mark - Lazy Instantiation -

-(UserManager*) userManager {
	if (!_userManager) _userManager = [UserManager sharedInstance];
	_userManager.delegate = self;
	return _userManager;
}

//lazy instantiation
-(UIView *)animationView {
	if(!_animationView)_animationView = [[UIView alloc] initWithFrame:self.view.bounds];
	[_animationView addSubview:self.animationLabel];
	_animationView.alpha = 0;
	return _animationView;
}

//lazy instantiation
-(UILabel *)animationLabel {
	if(!_animationLabel)_animationLabel = [[UILabel alloc] init];

	_animationLabel.frame = CGRectMake(0, self.view.bounds.size.height/2.f - SIGN_IN_ERROR_VIEW_HEIGHT/2.f,
									   self.view.bounds.size.width, SIGN_IN_ERROR_VIEW_HEIGHT);
	_animationLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
	_animationLabel.font = [UIFont fontWithName:DEFAULT_FONT size:ERROR_ANIMATION_FONT_SIZE];
	_animationLabel.textColor = [UIColor ERROR_ANIMATION_TEXT_COLOR];
	_animationLabel.numberOfLines = 0;
	_animationLabel.lineBreakMode = NSLineBreakByWordWrapping;
	[_animationLabel setTextAlignment:NSTextAlignmentCenter];
	return _animationLabel;
}

@end
