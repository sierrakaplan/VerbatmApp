//
//  verbatmUserLoginViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 12/27/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "ChooseLoginVC.h"
#import "Icons.h"

#import <Crashlytics/Crashlytics.h>
#import "Durations.h"

#import "Notifications.h"

#import "LoginKeyboardToolBar.h"
#import "LogIntoAccount.h"

#import "SegueIDs.h"
#import "LoginVC.h"
#import "SizesAndPositions.h"
#import "Styles.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "ParseBackendKeys.h"
#import <Parse/PFCloud.h>
#import <Parse/PFUser.h>
#import <Parse/PFObject.h>
#import <Parse/PFQuery.h>

#import "TermsAndConditionsVC.h"

#import "SignUpVC.h"
#import "UserSetupParameters.h"
#import "UserManager.h"

#import "ChooseLoginOrSignup.h"
#import "CreateAccount.h"
#import "ConfirmationCodeSignUp.h"


@interface LoginVC ()

//@property (nonatomic) BOOL loginFirstTimeDone;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *verbatmLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobileBloggingLabel;

//@property (strong, nonatomic) FBSDKLoginButton *loginButton;
//
//@property (weak, nonatomic) IBOutlet UILabel *orLabel;

@property (nonatomic) UIButton *loginButton;
@property (nonatomic) UIButton *signUpButton;
@property (nonatomic) UILabel *orLabel;

//@property (nonatomic) BOOL nextButtonEnabled;
//@property (weak, nonatomic) IBOutlet UITextField *phoneLoginField;
//@property (nonatomic) CGRect originalPhoneTextFrame;
//@property (nonatomic) BOOL enteringPhoneNumber;
//@property (strong, nonatomic) NSString * phoneNumber;
//@property (strong, nonatomic) NSString * verbatmName;
//@property (nonatomic) BOOL firstTimeLoggingIn;
//
//@property (nonatomic) BOOL createdUserWithLoginCode;
//
//@property (nonatomic) LogIntoAccount * loginToAccountView;
//@property (nonatomic) ConfirmationCodeSignUp * confirmationCodeEntry;
//
//@property (nonatomic) ChooseLoginOrSignup * chooseLoginOrSignUpView;
//@property (nonatomic) CreateAccount * createAccountView;
//
//#define BRING_UP_CREATE_ACCOUNT_SEGUE @"create_account_segue"

@end

@implementation LoginVC

- (void)viewDidLoad {
	[super viewDidLoad];
	[self formatNavigationBar];
	[self.backgroundImageView setFrame:self.view.bounds];
	[self createActionButtions];
	[self centerViews];
//	[self registerForNotifications];
//	self.loginFirstTimeDone = NO;
//	self.enteringPhoneNumber = YES;
//	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
//																		  action:@selector(keyboardDidHide:)];

//	[self.view addGestureRecognizer:tap];
//	[self presentLoginSignUpOption];
	[self.view sendSubviewToBack:self.backgroundImageView];
}

-(BOOL) prefersStatusBarHidden {
	return YES;
}

-(void) formatNavigationBar {
	[self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
	self.navigationController.navigationBar.shadowImage = [UIImage new];
	self.navigationController.navigationBar.translucent = YES;
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
																	 [UIColor whiteColor], NSForegroundColorAttributeName,
																	 [UIFont fontWithName:BOLD_FONT size:21.0], NSFontAttributeName, nil]];
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];

}

-(void) centerViews {
	self.verbatmLogoImageView.center = CGPointMake(self.view.center.x, self.verbatmLogoImageView.center.y);
	self.welcomeLabel.center = CGPointMake(self.view.center.x, self.welcomeLabel.center.y);
	self.mobileBloggingLabel.center = CGPointMake(self.view.center.x, self.mobileBloggingLabel.center.y);
	self.orLabel.center = CGPointMake(self.view.center.x, self.orLabel.center.y);
//	self.phoneLoginField.center = CGPointMake(self.view.center.x, self.phoneLoginField.center.y);
//	self.originalPhoneTextFrame = self.phoneLoginField.frame;
}

-(void)createActionButtions {

	CGRect topFrame = CGRectMake((self.view.frame.size.width - LOGIN_BUTTON_WIDTH)/2.f,
								 TOP_BUTTON_YOFFSET, LOGIN_BUTTON_WIDTH, LOGIN_BUTTON_HEIGHT);

	CGRect bottomFrame = CGRectMake((self.view.frame.size.width - LOGIN_BUTTON_WIDTH)/2.f, topFrame.origin.y +
									topFrame.size.height + SIGN_UP_BUTTON_GAP, LOGIN_BUTTON_WIDTH, LOGIN_BUTTON_HEIGHT);

	self.loginButton = [[UIButton alloc] initWithFrame:topFrame];
	self.signUpButton = [[UIButton alloc] initWithFrame:bottomFrame];

	[self.loginButton setImage:[UIImage imageNamed:LOGIN_ICON] forState:UIControlStateNormal];
	[self.signUpButton setImage:[UIImage imageNamed:CREATE_ACCOUNT] forState:UIControlStateNormal];

	[self.loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchDown];
	[self.signUpButton addTarget:self action:@selector(signUpButtonPressed) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview: self.loginButton];
	[self.view addSubview: self.orLabel];
	[self.view addSubview: self.signUpButton];
}

-(void)loginButtonPressed {
	[self performSegueWithIdentifier:SEGUE_LOGIN sender:self];
}

-(void)signUpButtonPressed {
	[self performSegueWithIdentifier:SEGUE_WELCOME sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:SEGUE_LOGIN]) {
		// Get reference to the destination view controller
		ChooseLoginVC *chooseLoginVC = [segue destinationViewController];
		chooseLoginVC.creatingAccount = NO;
	}
}

#pragma mark - Lazy Instantiation -

-(UILabel *)orLabel{
	if(!_orLabel) {
		CGFloat yPos = self.loginButton.frame.origin.y + self.loginButton.frame.size.height + SIGN_UP_BUTTON_GAP/2.f - OR_LABEL_WIDTH/2.f;
		_orLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x - OR_LABEL_WIDTH/2.f, yPos,
															 OR_LABEL_WIDTH, OR_LABEL_WIDTH)];
		[_orLabel setText:@"OR"];
		[_orLabel setBackgroundColor:[UIColor clearColor]];
		[_orLabel setTextColor:[UIColor whiteColor]];
		[_orLabel setFont:[UIFont fontWithName:BOLD_FONT size:HEADER_TEXT_SIZE]];
	}
	return _orLabel;
}

//forward means animation should go right to left (next view is coming on to right)
//-(void)replaceView:(UIView *) currentView withView:(UIView *)nextView goingForward:(BOOL) forward {
//	CGRect nextFrame = self.view.frame;
//	CGRect newCurrentFrame = self.view.frame;
//	if(forward) {
//		nextFrame.origin.x = self.view.frame.size.width;
//		newCurrentFrame.origin.x = -self.view.frame.size.width;
//	} else {
//		nextFrame.origin.x = -self.view.frame.size.width;
//		newCurrentFrame.origin.x = self.view.frame.size.width;
//	}
//	nextView.frame = nextFrame;
//	[self.view addSubview:nextView];
//
//	[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
//		currentView.frame = newCurrentFrame;
//		nextView.frame = self.view.bounds;
//	}];
//}
//
//-(void)presentLoginSignUpOption{
//	self.chooseLoginOrSignUpView = [[ChooseLoginOrSignup alloc] initWithFrame:self.view.bounds];
//	self.chooseLoginOrSignUpView.delegate = self;
//	[self.view addSubview:self.chooseLoginOrSignUpView];
//}
//
//-(void)viewWillAppear:(BOOL)animated {
//	[super viewWillAppear:animated];
//	if(![[UserSetupParameters sharedInstance] checkTermsShown] && !self.loginFirstTimeDone){
//		self.loginFirstTimeDone = YES;
//		[self performSegueWithIdentifier:TERMS_CONDITIONS_VC_SEGUE_ID sender:self];
//	}
//}
//
//-(void)viewDidAppear:(BOOL)animated {
//	[super viewDidAppear:animated];
//}
//
//-(BOOL) prefersStatusBarHidden {
//	return YES;
//}
//
//-(void)textNotAlphaNumericaCreateAccount{
//	[self alertTextNotAcceptable];
//}
//
//-(void)alertTextNotAcceptable{
//	UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Text Must Be Alphanumeric and you must create a name" message:@"" preferredStyle:UIAlertControllerStyleAlert];
//
//	UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
//													handler:^(UIAlertAction * action) {}];
//	[newAlert addAction:action1];
//	[self presentViewController:newAlert animated:YES completion:nil];
//}
//
//
//-(void) registerForNotifications {
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(loginFailed:)
//												 name:NOTIFICATION_USER_LOGIN_FAILED
//											   object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(loginSucceeded:)
//												 name:NOTIFICATION_USER_LOGIN_SUCCEEDED
//											   object:nil];
//}
//
//# pragma mark - Format views -
//
//- (void) addFacebookLoginButton {
//	self.loginButton = [[FBSDKLoginButton alloc] init];
//	float buttonWidth = self.loginButton.frame.size.width*1.5;
//	float buttonHeight = self.loginButton.frame.size.height*1.5;
//	self.loginButton.frame = CGRectMake(self.view.center.x - buttonWidth/2.f, (self.view.frame.size.height/3.f) + 20.f,
//										buttonWidth, buttonHeight);
//	//self.loginButton.delegate = self;
//	self.loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
//	[self.view addSubview:self.loginButton];
//	[self.view bringSubviewToFront:self.loginButton];
//}
//
//
//
//#pragma mark - Phone login Delegate -
//
//-(void) sendCodeToUser {
//	[self.phoneLoginField resignFirstResponder];
//	NSString *simplePhoneNumber = self.phoneNumber;
//
//
//	self.nextButtonEnabled = NO;
//
//	PFQuery *findUserQuery = [PFUser query];
//	[findUserQuery whereKey:@"username" equalTo:simplePhoneNumber];
//	[findUserQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable user, NSError * _Nullable error) {
//		if (user && !error) {
//			[self showAlertWithTitle:@"An account with this phone already exists." andMessage:@"Use a different number."];
//			[self goBackFromEnteringConfirmation];
//		}else{
//
//			self.firstTimeLoggingIn = YES;
//			self.phoneNumber = simplePhoneNumber;
//
//			//todo: include more languages
//			NSDictionary *params = @{@"phoneNumber" : simplePhoneNumber, @"language" : @"en"};
//			[PFCloud callFunctionInBackground:@"sendCode" withParameters:params block:^(id  _Nullable response, NSError * _Nullable error) {
//				if (error) {
//					[[Crashlytics sharedInstance] recordError: error];
//					[self showAlertWithTitle:@"Error sending code" andMessage:@"Something went wrong. Please verify your phone number is correct."];
//				} else {
//					self.createdUserWithLoginCode = YES;
//					// Parse has now created an account with this phone number and generated a random code,
//					// user must enter the correct code to be logged in
//				}
//			}];
//		}
//
//	}];
//}
//
//-(void)deleteCreatedUser {
//	if (self.createdUserWithLoginCode) {
//		self.createdUserWithLoginCode = NO;
//		NSString * userNameToDelete = self.phoneNumber;
//		NSDictionary *params = @{@"phoneNumber" : userNameToDelete};
//		[PFCloud callFunctionInBackground:@"deleteCreatedUser" withParameters:params block:^(id  _Nullable response, NSError * _Nullable error) {
//			if (error) {
//				NSLog(@"Error deleting created user: %@", error.description);
//			} else {
//				NSLog(@"Success deleting created user.");
//			}
//		}];
//	}
//}
//
//-(void) wrongConfirmationNumberAlert:(NSString*)title andMessage:(NSString*)message {
//	UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:title message:message
//																preferredStyle:UIAlertControllerStyleAlert];
//	UIAlertAction* defaultAction1 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
//														   handler:^(UIAlertAction * action) {
//
//															   [self goBackFromEnteringConfirmation];
//															   [self deleteCreatedUser];
//
//														   }];
//	UIAlertAction* defaultAction2 = [UIAlertAction actionWithTitle:@"Resend" style:UIAlertActionStyleDefault
//														   handler:^(UIAlertAction * action) {
//
//															   [self sendCodeToUser];
//
//														   }];
//
//
//	[newAlert addAction:defaultAction1];
//	[newAlert addAction:defaultAction2];
//	[self presentViewController:newAlert animated:YES completion:nil];
//}
//
//-(void) codeEnteredWithPhoneNumber:(NSString *)number andCode:(NSString *)code{
//	self.nextButtonEnabled = NO;
//	if (code.length != 4) {
//		NSString *message = @"You must enter a 4 digit confirmation code.\
//		It was sent in an SMS message to +1";
//		message = [message stringByAppendingString:self.phoneNumber];
//		[self showAlertWithTitle:@"Phone Login" andMessage: message];
//		return;
//	}
//
//	NSDictionary *params = @{@"phoneNumber": number, @"codeEntry": code};
//
//	__weak LoginVC * weakSelf = self;
//
//	[PFCloud callFunctionInBackground:@"logIn" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
//		if (error) {
//
//			[weakSelf wrongConfirmationNumberAlert:@"Wrong Confirmation Code" andMessage:@"You can choose to resend it."];
//		} else {
//			// This is the session token for the user
//			NSString *token = (NSString*)object;
//
//			[PFUser becomeInBackground:token block:^(PFUser * _Nullable user, NSError * _Nullable error) {
//				if (error) {
//					[weakSelf showAlertWithTitle:@"Login Error" andMessage:error.localizedDescription];
//				} else {
//					user.username = number;
//					[user setObject:self.verbatmName forKey:VERBATM_USER_NAME_KEY];
//					[user setObject:[NSNumber numberWithBool:NO] forKey:USER_FTUE];
//					[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//						if(succeeded){
//							[self loginUpWithPhoneNumberSelectedWithNumber:number];
//						}
//					}];
//				}
//			}];
//		}
//	}];
//}
//
//
//
//#pragma mark - Notification methods -
//
//-(void) loginSucceeded: (NSNotification*) notification {
//	[self unwindToMasterVC];
//}
//
//// Only called for fb login errors now
//-(void) loginFailed: (NSNotification*) notification {
//	NSError* error = notification.object;
//	NSString* errorMessage;
//	switch ([error code]) {
//		case kPFErrorUserWithEmailNotFound: {
//			errorMessage = @"We're sorry we couldn't find an account with that email.";
//			break;
//		}
//		case kPFErrorObjectNotFound: {
//			errorMessage = @"We're sorry either the email or password is incorrect.";
//			break;
//		}
//		default: {
//			errorMessage = @"We're sorry, something went wrong!";
//		}
//	}
//	[self errorInSignInAnimation:errorMessage];
//}
//
//// Unwind segue back to master vc
//-(void) unwindToMasterVC {
//	[self performSegueWithIdentifier:UNWIND_SEGUE_FROM_LOGIN_TO_MASTER sender:self];
//}
//
//#pragma mark - CreateAccount Protocol-
//
//-(void)errorInSignInWithError:(NSString *)error{
//	[self errorInSignInAnimation: error.description];
//}
//
//-(void)signUpWithPhoneNumberSelectedWithNumber:(NSString *) phoneNumber
//								  andName:(NSString *) verbatmName {
//
//	self.phoneNumber = phoneNumber;
//	self.verbatmName = verbatmName;
//	self.confirmationCodeEntry.phoneNumberEntered = phoneNumber;
//	[self sendCodeToUser];
//	[self replaceView:self.createAccountView withView:self.confirmationCodeEntry goingForward:YES];
//
//}
//
//-(void)phoneNumberWrongFormatCreateAccount{
//	[self showAlertWithTitle:@"Phone Login" andMessage:@"You must enter a 10-digit US phone number including area code."];
//}
//
//-(void)verbatmNameWrongFormatCreateAccount{
//	[self showAlertWithTitle:@"Your name can only be letters, numbers and an underscore." andMessage:@""];
//}
//
//-(void)goBackSelectedCreateAccount{
//	[self replaceView:self.createAccountView withView:self.chooseLoginOrSignUpView goingForward:NO];
//
//}
//
//-(void)codeSubmitted:(NSString *) enteredCode{
//	[self codeEnteredWithPhoneNumber:self.phoneNumber andCode:enteredCode];
//}
//
//#pragma mark -LogIntoAccount Protocol-
//-(void)goBackSelectedLoginAccount{
//	[self replaceView:self.loginToAccountView withView:self.chooseLoginOrSignUpView goingForward:NO];
//}
//
//-(void)textNotAlphaNumericaLoginAccount{
//	[self alertTextNotAcceptable];
//}
//
//-(void)loginUpWithPhoneNumberSelectedWithNumber:(NSString *) phoneNumber {
//	[PFUser logInWithUsernameInBackground:phoneNumber password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
//		if (error || !user) {
//			[self showAlertWithTitle:@"Incorrect password" andMessage: @"Please try again"];
//		} else {
//			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGIN_SUCCEEDED object:[PFUser currentUser]];
//		}
//	}];
//}
//
//-(void)goBackFromEnteringConfirmation{
//
//	if(self.createdUserWithLoginCode){
//		[self deleteCreatedUser];
//	}
//	[self replaceView:self.confirmationCodeEntry  withView:self.createAccountView goingForward:NO];
//}
//
//#pragma mark -ConfirmationCodeSignup Protocol-
//
//-(void)goBackSelectedConfirmationCode{
//	[self goBackFromEnteringConfirmation];
//}
//
//-(void)resendCodeSelectedConfirmationCode{
//
//}
//
//-(void)codeSubmittedConfirmationCode:(NSString *) enteredCode{
//	[self codeEnteredWithPhoneNumber:self.phoneNumber andCode:enteredCode];
//}
//
//
//#pragma mark -ChooseLoginOrSignUp Protocol-
//
//-(void)signUpChosen{
//	[self replaceView:self.chooseLoginOrSignUpView withView:self.createAccountView goingForward:YES];
//}
//-(void)loginChosen{
//	[self replaceView:self.chooseLoginOrSignUpView withView:self.loginToAccountView goingForward:YES];
//}
//
//
//
//#pragma mark - Error message animation -
//
//-(void)errorInSignInAnimation:(NSString*) errorMessage {
//	NSLog(@"Error: \"%@\"", errorMessage);
//	[self showAlertWithTitle:@"Error signing in" andMessage:errorMessage];
//}
//
//-(void) showAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
//	UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:title message:message
//																preferredStyle:UIAlertControllerStyleAlert];
//	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//														  handler:^(UIAlertAction * action) {}];
//	[newAlert addAction:defaultAction];
//	[self presentViewController:newAlert animated:YES completion:nil];
//}
//
//- (void)didReceiveMemoryWarning {
//	[super didReceiveMemoryWarning];
//	// Dispose of any resources that can be recreated.
//}
//
//#pragma mark - Navigation
//
//// Set data on segue to user settings vc
//-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//	if ([[segue identifier] isEqualToString:USER_SETTINGS_SEGUE]) {
//		SignUpVC* userViewController = [segue destinationViewController];
//		userViewController.phoneNumber = self.phoneNumber;
//		userViewController.firstTimeLoggingIn = self.firstTimeLoggingIn;
//	} else {
//		UIViewController *destinationViewController =  [segue destinationViewController];
//
//		if([destinationViewController isKindOfClass:[TermsAndConditionsVC class]]){
//			((TermsAndConditionsVC *)destinationViewController).userMustAcceptTerms = YES;
//		}
//	}
//}
//
//- (IBAction) unwindToSignIn: (UIStoryboardSegue *)segue {
//	UIViewController *sourceViewController = [segue sourceViewController];
//	if ([sourceViewController isKindOfClass:[SignUpVC class]]) {
//		SignUpVC* userInfoVC = (SignUpVC*)sourceViewController;
//		if (userInfoVC.successfullyLoggedIn) {
//			[self unwindToMasterVC];
//		}
//	}
//}
//
//
//#pragma mark - Lazy Instantiation -
//
//-(LogIntoAccount *)loginToAccountView{
//	if(!_loginToAccountView){
//		_loginToAccountView = [[LogIntoAccount alloc] initWithFrame:self.view.bounds];
//		_loginToAccountView.delegate = self;
//	}
//	return _loginToAccountView;
//}
//
//-(CreateAccount *)createAccountView {
//	if(!_createAccountView){
//		_createAccountView = [[CreateAccount alloc] initWithFrame:self.view.bounds];
//		_createAccountView.delegate = self;
//	}
//	return _createAccountView;
//}
//
//
//-(ConfirmationCodeSignUp *)confirmationCodeEntry{
//	if(!_confirmationCodeEntry){
//		_confirmationCodeEntry = [[ConfirmationCodeSignUp alloc] initWithFrame:self.view.bounds];
//		_confirmationCodeEntry.delagate = self;
//	}
//	return _confirmationCodeEntry;
//}
//
//-(void)keyboardDidHide:(UITapGestureRecognizer *)gesture {
//	//todo:
////	if(self.onBoardingView.contentOffset.x == 0){
////		[UIView animateWithDuration:0.7 animations:^{
////			self.onBoardingView.contentOffset = CGPointMake(self.view.frame.size.width, 0);
////		}completion:^(BOOL finished) {
////			if(finished){
////				self.pageControlView.currentPage = self.onBoardingView.contentOffset.x/self.view.bounds.size.width;
////			}
////		}];
////	}else if (self.onBoardingView.contentOffset.x == self.view.frame.size.width * 3){
////		[self.phoneLoginField resignFirstResponder];
////	}
//
//}
//
//- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
//	//return supported orientation masks
//	return UIInterfaceOrientationMaskPortrait;
//}
//
//- (void)dealloc {
//	[[NSNotificationCenter defaultCenter] removeObserver:self];
//}

@end
