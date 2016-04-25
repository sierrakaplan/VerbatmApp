//
//  verbatmUserLoginViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 12/27/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//


#import "Durations.h"

#import "Notifications.h"

#import "LoginKeyboardToolBar.h"

#import "SegueIDs.h"
#import "SignInVC.h"
#import "SizesAndPositions.h"
#import "Styles.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <Parse/PFCloud.h>

#import "TermsAndConditionsVC.h"

#import "UserSetupParameters.h"
#import "UserManager.h"

@interface SignInVC () <UITextFieldDelegate, FBSDKLoginButtonDelegate, LoginKeyboardToolBarDelegate>
@property (nonatomic) BOOL loginFirstTimeDone;
@property (strong, nonatomic) UIView* animationView;
@property (strong, nonatomic) UILabel* animationLabel;
@property (strong, nonatomic) NSTimer* animationTimer;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *verbatmLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobileBloggingLabel;

@property (strong, nonatomic) FBSDKLoginButton *loginButton;

@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (strong, nonatomic) LoginKeyboardToolBar *toolBar;
@property (weak, nonatomic) IBOutlet UITextField *phoneLoginField;
@property (nonatomic) BOOL enteringPhoneNumber;
@property (strong, nonatomic) NSString *phoneNumber;

#define BRING_UP_CREATE_ACCOUNT_SEGUE @"create_account_segue"

@end

@implementation SignInVC

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.backgroundImageView setFrame:self.view.bounds];
	[self centerViews];
	[self registerForNotifications];
	[self addFacebookLoginButton];
	self.loginFirstTimeDone = NO;
	self.enteringPhoneNumber = YES;
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if(![[UserSetupParameters sharedInstance] isTermsAccept_InstructionShown] && !self.loginFirstTimeDone){
		self.loginFirstTimeDone = YES;
		[self performSegueWithIdentifier:TERMS_CONDITIONS_VC_SEGUE_ID sender:self];
	}
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(BOOL) prefersStatusBarHidden {
	return YES;
}

-(void) centerViews {
	self.verbatmLogoImageView.center = CGPointMake(self.view.center.x, self.verbatmLogoImageView.center.y);
	self.welcomeLabel.center = CGPointMake(self.view.center.x, self.welcomeLabel.center.y);
	self.mobileBloggingLabel.center = CGPointMake(self.view.center.x, self.mobileBloggingLabel.center.y);
	self.orLabel.center = CGPointMake(self.view.center.x, self.orLabel.center.y);
	self.phoneLoginField.center = CGPointMake(self.view.center.x, self.phoneLoginField.center.y);

	CGFloat loginToolBarHeight = TEXT_TOOLBAR_HEIGHT*1.3;
	CGRect toolBarFrame = CGRectMake(0, self.view.frame.size.height - loginToolBarHeight,
									 self.view.frame.size.width, loginToolBarHeight);
	self.toolBar = [[LoginKeyboardToolBar alloc] initWithFrame:toolBarFrame];
	self.toolBar.delegate = self;
	[self.toolBar setNextButtonText:@"Next"];
	self.phoneLoginField.inputAccessoryView = self.toolBar;
	self.phoneLoginField.keyboardType = UIKeyboardTypePhonePad;
	self.phoneLoginField.delegate = self;
}

-(void) registerForNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loginFailed:)
												 name:NOTIFICATION_USER_LOGIN_FAILED
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loginSucceeded:)
												 name:NOTIFICATION_USER_LOGIN_SUCCEEDED
											   object:nil];
}


# pragma mark - Format views -

- (void) addFacebookLoginButton {
	self.loginButton = [[FBSDKLoginButton alloc] init];
	float buttonWidth = self.loginButton.frame.size.width*1.2;
	float buttonHeight = self.loginButton.frame.size.height*1.2;
	self.loginButton.frame = CGRectMake(self.view.center.x - buttonWidth/2.f, (self.view.frame.size.height/3.f) + 20.f,
										buttonWidth, buttonHeight);
	self.loginButton.delegate = self;
	self.loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
	[self.view addSubview:self.loginButton];
	[self.view bringSubviewToFront:self.loginButton];
}

#pragma mark - Phone login Delegate -

-(void) nextButtonPressed {
	if (!self.enteringPhoneNumber) {
		[self codeEntered];
		return;
	}
	[self.phoneLoginField resignFirstResponder];
	NSString *simplePhoneNumber = [self getSimpleNumberFromFormattedPhoneNumber:self.phoneLoginField.text];
	//todo: accept more phone numbers
	if (simplePhoneNumber.length != 10) {
		[self showAlertWithTitle:@"Phone Login" andMessage:@"You must enter a 10-digit US phone number including area code."];
		return;
	}

	self.enteringPhoneNumber = NO;
	self.phoneNumber = simplePhoneNumber;
	self.phoneLoginField.text = @"";
	self.phoneLoginField.placeholder = @"Enter the 4-digit confirmation code:";
	//			[self.toolBar setNextButtonText:@"Next"];

	//todo: include more languages
	NSDictionary *params = @{@"phoneNumber" : simplePhoneNumber, @"language" : @"en"};
	[PFCloud callFunctionInBackground:@"sendCode" withParameters:params block:^(id  _Nullable response, NSError * _Nullable error) {
		if (error) {
			NSLog(@"Error sending code %@", error.description);
			[self showAlertWithTitle:@"Phone Login" andMessage:@"Something went wrong. Please try again."];
		} else {
			// Parse has now created an account with this phone number and generated a random code,
			// user must enter the correct code to be logged in

		}
	}];
}

-(void) codeEntered {
	NSString *code = self.phoneLoginField.text;
	if (code.length != 4) {
		NSString *message = @"You must enter a 4 digit confirmation code.\
		It was sent in an SMS message to +1";
		message = [message stringByAppendingString:self.phoneNumber];
		[self showAlertWithTitle:@"Phone Login" andMessage: message];
		return;
	}

	NSDictionary *params = @{@"phoneNumber": self.phoneNumber, @"codeEntry": code};
	[PFCloud callFunctionInBackground:@"logIn" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
		if (error) {
			[self showAlertWithTitle:@"Login Error" andMessage:error.description];
		} else {
			// This is the session token for the user
			NSString *token = (NSString*)object;
			[PFUser becomeInBackground:token block:^(PFUser * _Nullable user, NSError * _Nullable error) {
				if (error) {
					[self showAlertWithTitle:@"Login Error" andMessage:@"Something went wrong while trying to log in. Please try again."];
				} else {
					// Go to setting name and password
					[self performSegueWithIdentifier:USER_SETTINGS_SEGUE sender:self];
				}
			}];
		}
	}];
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
		[[UserManager sharedInstance] signUpOrLoginUserFromFacebookToken: [FBSDKAccessToken currentAccessToken]];
	} else {
		[self errorInSignInAnimation: @"Facebook login failed."];
	}
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
	[[UserManager sharedInstance] logOutUser];
}

#pragma mark - Notification methods -

-(void) loginSucceeded: (NSNotification*) notification {
	[self unwindToMasterVC];
}

-(void) loginFailed: (NSNotification*) notification {
	NSError* error = notification.object;
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
	[self showAlertWithTitle:@"Error signing in" andMessage:errorMessage];
}

-(void) showAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
	UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:title message:message
																preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction * action) {}];
	[newAlert addAction:defaultAction];
	[self presentViewController:newAlert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// Segue back to the MasterNavigationVC after logging in
// Or segue to create account
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	UIViewController * vc =  [segue destinationViewController];

	if([vc isKindOfClass:[TermsAndConditionsVC class]]){
		((TermsAndConditionsVC *)vc).userMustAcceptTerms = YES;
	}
}

#pragma mark - Formatting phone number -

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	if (self.enteringPhoneNumber) {
		//todo: remove other buttons
	}
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSString* totalString = [NSString stringWithFormat:@"%@%@",textField.text,string];

	// if it's the phone number textfield format it.
	if(textField == self.phoneLoginField && self.enteringPhoneNumber) {
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

#pragma mark - Unwind segue -

- (IBAction) unwindToSignIn: (UIStoryboardSegue *)segue {
	[self unwindToMasterVC];
}

#pragma mark - Lazy Instantiation -

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
