//
//  verbatmUserLoginViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 12/27/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "SignIn.h"
#import "Notifications.h"
#import "SizesAndPositions.h"
#import "Durations.h"
#import "Styles.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SegueIDs.h"

#import "UserManager.h"

@interface SignIn () <UITextFieldDelegate, FBSDKLoginButtonDelegate, UserManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *createAccountRedirectButton;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;

@property (strong, nonatomic) UIView *animationView;
@property (strong, nonatomic) UILabel* animationLabel;
@property (strong, nonatomic) NSTimer * animationTimer;

@property (strong, nonatomic) UserManager* userManager;

#define BRING_UP_CREATE_ACCOUNT_SEGUE @"create_account_segue"

@end

@implementation SignIn

- (void)viewDidLoad {
	[super viewDidLoad];

	self.emailField.delegate = self;
	self.passwordField.delegate = self;
	[self centerAllframes];
	[self setCursorColor];

	[self addFacebookLoginButton];
    [self addTapGestureToRemoveKeyboard];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

# pragma mark - Format views -

//dynamically centers all our frames depending on phone screen dimensions
-(void) centerAllframes {

    
    self.orLabel.frame = CGRectMake(self.view.center.x - (self.orLabel.frame.size.width/2), self.orLabel.frame.origin.y, self.orLabel.frame.size.width, self.orLabel.frame.size.height);
    
	self.emailField.frame= CGRectMake((self.view.frame.size.width/2 - self.emailField.frame.size.width/2), self.orLabel.frame.origin.y + self.orLabel.frame.size.height + DISTANCE_BETWEEN_FIELDS,
                                      self.emailField.frame.size.width, self.emailField.frame.size.height);

	self.passwordField.frame = CGRectMake((self.view.frame.size.width/2 - self.passwordField.frame.size.width/2), self.emailField.frame.origin.y + self.emailField.frame.size.height + DISTANCE_BETWEEN_FIELDS,
                                          self.passwordField.frame.size.width, self.passwordField.frame.size.height);

	self.signInButton.frame =CGRectMake((self.view.frame.size.width/2 - self.signInButton.frame.size.width/2),self.passwordField.frame.origin.y + self.passwordField.frame.size.height + DISTANCE_BETWEEN_FIELDS,
                                        self.signInButton.frame.size.width, self.signInButton.frame.size.height);
    
	[self.signInButton addTarget:self action:@selector(completeLogin) forControlEvents:UIControlEventTouchUpInside];
    
    self.createAccountRedirectButton.frame = CGRectMake((self.view.center.x - (self.createAccountRedirectButton.frame.size.width/2)),
                                                        self.createAccountRedirectButton.frame.origin.y,
                                                        self.createAccountRedirectButton.frame.size.width,
                                                        self.createAccountRedirectButton.frame.size.height);
    
    
}

-(void) setCursorColor {
	self.emailField.tintColor = [UIColor colorWithRed:98.0/255.0f green:98.0/255.0f blue:98.0/255.0f alpha:1.0];
	self.passwordField.tintColor = [UIColor colorWithRed:98.0/255.0f green:98.0/255.0f blue:98.0/255.0f alpha:1.0];
}

- (void) addFacebookLoginButton {
	FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
	float buttonWidth = loginButton.frame.size.width*1.2;
	float buttonHeight = loginButton.frame.size.height*1.2;
	loginButton.frame = CGRectMake(self.view.center.x - buttonWidth/2, self.orLabel.frame.origin.y - buttonHeight - DISTANCE_BETWEEN_FIELDS, buttonWidth, buttonHeight);
	loginButton.delegate = self;
	loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
	[self.view addSubview:loginButton];
}

#pragma mark - Remove Keyboard -

-(void)addTapGestureToRemoveKeyboard{
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeKeyboardTap)];
    [self.view addGestureRecognizer:tapGesture];
}

-(void) removeKeyboardTap {
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

#pragma mark - Completing login -

- (void) completeLogin {
	NSString* email = self.emailField.text;
	NSString* password = self.passwordField.text;

	if (email.length > 0 &&
		password.length > 0) {

		[self.userManager loginUserFromEmail: email andPassword: password];

	} else {
		[self errorInSignInAnimation: @"Please enter all required fields"];
	}
}

#pragma mark - Facebook Button Delegate  -

- (void)  loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
				error:(NSError *)error {

	if (error || result.isCancelled) {
		[self errorInSignInAnimation: @"Facebook login failed."];
		return;
	}

	//TODO(sierrakn): If any declined permissions are essential
	//explain to user why and ask them to agree to each individually
//	NSSet* declinedPermissions = result.declinedPermissions;

	//batch request for user info as well as friends
	if ([FBSDKAccessToken currentAccessToken]) {
		[self.userManager signUpOrLoginUserFromFacebookToken: [FBSDKAccessToken currentAccessToken]];
	} else {
		[self errorInSignInAnimation: @"Facebook login failed."];
	}
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
	[self.userManager logOutUser];
}


#pragma mark - User Manager Delegate methods -

-(void) successfullyLoggedInUser: (GTLVerbatmAppVerbatmUser*) user {
	[self unwindToMasterVC];
}

-(void) errorLoggingInUser: (NSError*) error {
	NSString* errorMessage;
	//TODO: offer to reset password
	switch ([error code]) {
		case kPFErrorUserWithEmailNotFound: {
			errorMessage = @"We're sorry we couldn't find an account with that email.";
			break;
		}
		case kPFErrorObjectNotFound: {
			errorMessage = @"We're sorry either the email or password is incorrect.";
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
	[self performSegueWithIdentifier:UNWIND_SEGUE_FROM_LOGIN_TO_MASTER sender:self];
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
	}completion:^(BOOL finished) {
		if (!show) {
			[self.animationTimer invalidate];
			self.animationTimer = nil;
			[self.animationView removeFromSuperview];
		}
	}];
}

//for ios8- To hide the status bar
-(BOOL)prefersStatusBarHidden {
	return YES;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - UITextField delegate methods -

// Enter button should navigate between fields
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
	if (textField == self.emailField){
		[self.passwordField becomeFirstResponder];
		return YES;
	}
	if (textField == self.passwordField){
		//TODO: trigger login button
		[self.passwordField resignFirstResponder];
		return YES;
	}
	return NO;
}


#pragma mark - Navigation

// Segue back to the MasterNavigationVC after logging in
// Or segue to create account
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.
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
