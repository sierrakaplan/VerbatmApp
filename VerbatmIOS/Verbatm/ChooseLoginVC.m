//
//  ChooseLoginVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/23/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//


#import "ChooseLoginVC.h"
#import <Crashlytics/Crashlytics.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "LoginKeyboardToolBar.h"
#import "Styles.h"
#import "SizesAndPositions.h"
#import "UserManager.h"

@interface ChooseLoginVC() <UITextFieldDelegate, LoginKeyboardToolBarDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) FBSDKLoginButton *facebookLoginButton;
@property (nonatomic) UILabel *orLabel;
@property (strong, nonatomic) UITextField *phoneLoginField;
@property (nonatomic) CGRect originalPhoneTextFrame;

#define PHONE_FIELD_WIDTH 200.f
#define PHONE_FIELD_HEIGHT 50.f
#define VERTICAL_SPACING 25.f
#define OR_TEXT_WIDTH 250.f

@end

@implementation ChooseLoginVC

-(void) viewDidLoad {
	[super viewDidLoad];
	[self formatNavigationBar];
	[self.backgroundImageView setFrame: self.view.bounds];
	[self.view addSubview: self.facebookLoginButton];
	[self.view addSubview: self.orLabel];
	[self.view addSubview: self.phoneLoginField];
	[self.view sendSubviewToBack:self.backgroundImageView];
	[self registerForKeyboardNotifications];
}

-(void) formatNavigationBar {
//	self.navigationController.navigationBar.hidden = NO;
//	self.navigationController.navigationBar.left
//	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
}

-(NSString*) getSimpleNumberFromFormattedPhoneNumber:(NSString*)formattedPhoneNumber {
	// use regex to remove non-digits(including spaces) so we are left with just the numbers
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
	NSString* simpleNumber = [regex stringByReplacingMatchesInString:formattedPhoneNumber options:0 range:NSMakeRange(0, [formattedPhoneNumber length]) withTemplate:@""];
	return simpleNumber;
}

#pragma mark - Keyboard moving up and down -

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

-(void) keyboardWillShow:(NSNotification*)notification {
	[self.facebookLoginButton setHidden:YES];
	[self.orLabel setHidden:YES];
	CGRect keyboardBounds;
	[[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];
	CGFloat keyboardOffset = 0.f;
	CGFloat padding = 20.f;
	CGFloat newYOrigin = (self.view.frame.size.height - keyboardBounds.size.height -
						  self.phoneLoginField.frame.size.height - LOGIN_TOOLBAR_HEIGHT - padding);
	if (newYOrigin < self.phoneLoginField.frame.origin.y) {
		keyboardOffset = self.phoneLoginField.frame.origin.y - newYOrigin;
	}

	[UIView animateWithDuration:0.2 animations:^{
		[self shiftPhoneFieldUp:YES];
	}completion:^(BOOL finished) {}];
}

-(void)shiftPhoneFieldUp:(BOOL) up{
	if(up) {
		self.phoneLoginField.frame = CGRectOffset(self.phoneLoginField.frame, 0.f, self.facebookLoginButton.frame.origin.y -
												   self.phoneLoginField.frame.origin.y - LOGIN_TOOLBAR_HEIGHT); // make room for next button
	}else{
		self.phoneLoginField.frame = self.originalPhoneTextFrame;
		[self.orLabel setHidden:NO];
	}
}

-(void) keyboardWillHide:(NSNotification*)notification {
	[self.facebookLoginButton setHidden:NO];

	[UIView animateWithDuration:0.2 animations:^{
		[self shiftPhoneFieldUp:NO];
	}];
}

#pragma mark - Formatting phone number -

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSString* totalString = [NSString stringWithFormat:@"%@%@",textField.text,string];

	// if it's the phone number textfield format it.
	if(textField == self.phoneLoginField) {
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

#pragma mark - Facebook Button Delegate  -

- (void)  loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
				error:(NSError *)error {

	if (error || result.isCancelled) {
		[[Crashlytics sharedInstance] recordError:error];
		//   [self.delegate errorInSignInWithError: @"Facebook login failed."];
		return;
	}
	//	NSSet* declinedPermissions = result.declinedPermissions;
	//batch request for user info as well as friends
	if ([FBSDKAccessToken currentAccessToken]) {
		[[UserManager sharedInstance] signUpOrLoginUserFromFacebookToken: [FBSDKAccessToken currentAccessToken]];
	} else {
		//  [self.delegate errorInSignInWithError: @"Facebook login failed."];
	}
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
	[[UserManager sharedInstance] logOutUser];
}

#pragma mark - TOOLBAR NEXT BUTTON -

-(void) nextButtonPressed {
	NSString *simplePhoneNumber = [self getSimpleNumberFromFormattedPhoneNumber: self.phoneLoginField.text];
	[self.phoneLoginField resignFirstResponder];
	//todo: send code
}

-(NSString *)removeSpaces:(NSString *)text{
	return  [text stringByReplacingOccurrencesOfString:@" " withString:@""];
}

#pragma mark - Login Succeeded/Failed -

-(void) loginSucceeded: (NSNotification*) notification {
//	[self unwindToMasterVC];
}

// Only called for fb login errors now
-(void) loginFailed: (NSNotification*) notification {
	NSError* error = notification.object;
	NSString* errorMessage;
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


#pragma mark - Lazy Instantiation -

-(FBSDKLoginButton*) facebookLoginButton {
	if (!_facebookLoginButton) {
		CGFloat yPosition = (self.view.frame.size.height - PHONE_FIELD_HEIGHT*2 - VERTICAL_SPACING*2 - OR_LABEL_WIDTH)/2.f;
		CGRect frame = CGRectMake(self.view.center.x - PHONE_FIELD_WIDTH/2.f, yPosition, PHONE_FIELD_WIDTH, PHONE_FIELD_HEIGHT);
		_facebookLoginButton = [[FBSDKLoginButton alloc] initWithFrame:frame];
	}
	return _facebookLoginButton;
}

-(UILabel *)orLabel{
	if(!_orLabel) {
		CGFloat yPos = self.facebookLoginButton.frame.origin.y + self.facebookLoginButton.frame.size.height + VERTICAL_SPACING;
		_orLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x - OR_TEXT_WIDTH/2.f, yPos,
															 OR_TEXT_WIDTH, OR_LABEL_WIDTH)];
		[_orLabel setText:@"Or, log in with phone number"];
		[_orLabel setBackgroundColor:[UIColor clearColor]];
		[_orLabel setTextColor:[UIColor whiteColor]];
		[_orLabel setFont:[UIFont fontWithName:REGULAR_FONT size:18.f]];
	}
	return _orLabel;
}

-(UITextField*) phoneLoginField {
	if (!_phoneLoginField) {
		CGFloat yPosition = self.orLabel.frame.origin.y + self.orLabel.frame.size.height + VERTICAL_SPACING;
		CGRect frame = CGRectMake(self.view.center.x - PHONE_FIELD_WIDTH/2.f, yPosition, PHONE_FIELD_WIDTH, PHONE_FIELD_HEIGHT);
		_phoneLoginField = [[UITextField alloc] initWithFrame: frame];
		_phoneLoginField.backgroundColor = [UIColor whiteColor];
		_phoneLoginField.layer.borderColor = [UIColor blackColor].CGColor;
		_phoneLoginField.layer.borderWidth = 1.f;
		_phoneLoginField.font = [UIFont fontWithName:REGULAR_FONT size:16.f];
		_phoneLoginField.layer.cornerRadius = 5.f;
		_phoneLoginField.layer.sublayerTransform = CATransform3DMakeTranslation(20.f, 0, 0);
		_phoneLoginField.keyboardType = UIKeyboardTypePhonePad;
		_phoneLoginField.placeholder = @"(201) 555-0123";
		_phoneLoginField.delegate = self;

		CGRect toolBarFrame = CGRectMake(0, self.view.frame.size.height - LOGIN_TOOLBAR_HEIGHT,
										 self.view.frame.size.width, LOGIN_TOOLBAR_HEIGHT);
		LoginKeyboardToolBar *toolbar = [[LoginKeyboardToolBar alloc] initWithFrame:toolBarFrame];
		toolbar.delegate = self;
		[toolbar setNextButtonText:@"Next"];
		_phoneLoginField.inputAccessoryView = toolbar;
	}
	return _phoneLoginField;
}

@end
