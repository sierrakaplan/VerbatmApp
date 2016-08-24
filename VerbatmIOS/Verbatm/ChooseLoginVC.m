//
//  ChooseLoginVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/23/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "EnterCodeVC.h"
#import "ChooseLoginVC.h"
#import <Crashlytics/Crashlytics.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "LoginKeyboardToolBar.h"
#import "Notifications.h"
#import "Styles.h"
#import "SegueIDs.h"
#import "SizesAndPositions.h"
#import "UserManager.h"
#import "UtilityFunctions.h"

@interface ChooseLoginVC() <UITextFieldDelegate, LoginKeyboardToolBarDelegate, FBSDKLoginButtonDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) FBSDKLoginButton *facebookLoginButton;
@property (nonatomic) UILabel *orLabel;
@property (strong, nonatomic) UITextField *phoneLoginField;
@property (nonatomic) UILabel *sendTextLabel;
@property (nonatomic) CGRect originalPhoneTextFrame;

#define PHONE_FIELD_WIDTH 200.f
#define PHONE_FIELD_HEIGHT 50.f
#define VERTICAL_SPACING 25.f
#define OR_TEXT_WIDTH 280.f
#define KEYBOARD_HEIGHT 100.f

@end

@implementation ChooseLoginVC

-(void) viewDidLoad {
	[super viewDidLoad];
	[self formatNavigationBar];
	[self.backgroundImageView setFrame: self.view.bounds];
	[self.view addSubview: self.facebookLoginButton];
	[self.view addSubview: self.orLabel];
	[self.view addSubview: self.phoneLoginField];
	[self.view addSubview: self.sendTextLabel];
	[self.view sendSubviewToBack:self.backgroundImageView];
	[self registerForNotifications];
}

-(BOOL) prefersStatusBarHidden {
	return YES;
}

-(void) formatNavigationBar {
//	self.navigationController.navigationBar.hidden = NO;
//	self.navigationController.navigationBar.left
//	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
	if (self.creatingAccount) {
		self.navigationItem.title = @"Sign Up";
	} else {
		self.navigationItem.title = @"Log In";
	}
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
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
	NSString *simpleNumber = [UtilityFunctions removeAllNonNumbersFromString: number];

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
	NSString *simplePhoneNumber = [UtilityFunctions removeAllNonNumbersFromString: self.phoneLoginField.text];
	if (simplePhoneNumber.length < 10) return;
	[self.phoneLoginField resignFirstResponder];
	[self performSegueWithIdentifier:SEGUE_ENTER_PHONE_CONFIRMATION_CODE sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:SEGUE_ENTER_PHONE_CONFIRMATION_CODE]) {
		// Get reference to the destination view controller
		EnterCodeVC *enterCodeVC = [segue destinationViewController];
		enterCodeVC.phoneNumber = self.phoneLoginField.text;
		enterCodeVC.creatingAccount = self.creatingAccount;
	}
}

-(NSString *)removeSpaces:(NSString *)text{
	return  [text stringByReplacingOccurrencesOfString:@" " withString:@""];
}

#pragma mark - Login Succeeded/Failed -

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

-(void) loginSucceeded: (NSNotification*) notification {
	[self performSegueWithIdentifier:UNWIND_SEGUE_FACEBOOK_LOGIN_TO_MASTER sender:self];
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
		CGFloat yPosition = (self.view.frame.size.height - PHONE_FIELD_HEIGHT*2 - VERTICAL_SPACING*2 - OR_LABEL_WIDTH)/2.f - KEYBOARD_HEIGHT;
		CGRect frame = CGRectMake(self.view.center.x - PHONE_FIELD_WIDTH/2.f, yPosition, PHONE_FIELD_WIDTH, PHONE_FIELD_HEIGHT);
		_facebookLoginButton = [[FBSDKLoginButton alloc] initWithFrame:frame];
		_facebookLoginButton.delegate = self;
	}
	return _facebookLoginButton;
}

-(UILabel *)orLabel {
	if(!_orLabel) {
		CGFloat yPos = self.facebookLoginButton.frame.origin.y + self.facebookLoginButton.frame.size.height + VERTICAL_SPACING;
		_orLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x - OR_TEXT_WIDTH/2.f, yPos,
															 OR_TEXT_WIDTH, 30.f)];
		if (self.creatingAccount) {
			[_orLabel setText:@"Or, sign up with phone number"];
		} else {
			[_orLabel setText:@"Or, log in with phone number"];
		}
		_orLabel.textAlignment = NSTextAlignmentCenter;
		[_orLabel setBackgroundColor:[UIColor clearColor]];
		[_orLabel setTextColor:[UIColor whiteColor]];
		[_orLabel setFont:[UIFont fontWithName:REGULAR_FONT size:16.f]];
	}
	return _orLabel;
}

-(UILabel*)sendTextLabel {
	if(!_sendTextLabel) {
		CGFloat yPos = self.phoneLoginField.frame.origin.y + self.phoneLoginField.frame.size.height;
		_sendTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x - OR_TEXT_WIDTH/2.f, yPos,
																   OR_TEXT_WIDTH, 30.f)];
		_sendTextLabel.text = @"We'll send a text to verify your phone.";
		_sendTextLabel.textAlignment = NSTextAlignmentCenter;
		[_sendTextLabel setBackgroundColor:[UIColor clearColor]];
		[_sendTextLabel setTextColor:[UIColor whiteColor]];
		[_sendTextLabel setFont:[UIFont fontWithName:REGULAR_FONT size:16.f]];

	}
	return _sendTextLabel;
}

-(UITextField*) phoneLoginField {
	if (!_phoneLoginField) {
		CGFloat yPosition = self.orLabel.frame.origin.y + self.orLabel.frame.size.height;
		self.originalPhoneTextFrame = CGRectMake(self.view.center.x - PHONE_FIELD_WIDTH/2.f, yPosition, PHONE_FIELD_WIDTH, PHONE_FIELD_HEIGHT);
		_phoneLoginField = [[UITextField alloc] initWithFrame: self.originalPhoneTextFrame];
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
