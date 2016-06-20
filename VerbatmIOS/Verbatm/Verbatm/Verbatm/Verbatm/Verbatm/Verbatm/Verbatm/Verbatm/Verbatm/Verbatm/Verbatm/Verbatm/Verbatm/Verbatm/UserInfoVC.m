//
//  UserInfoVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/24/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "CustomNavigationBar.h"
#import "Icons.h"
#import "Notifications.h"
#import "SegueIDs.h"
#import "UserInfoVC.h"
#import "ParseBackendKeys.h"
#import "Parse/PFUser.h"
#import "SizesAndPositions.h"
#import "Styles.h"

@interface UserInfoVC() <UITextFieldDelegate, CustomNavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (nonatomic) CustomNavigationBar * navigationBar;

@end

@implementation UserInfoVC

-(void) viewDidLoad {
	self.successfullyLoggedIn = NO;
	[self.backgroundImageView setFrame:self.view.bounds];
	[self centerViews];
	[self createNavigationBar];
	[self.nameTextField setReturnKeyType:UIReturnKeyNext];
	self.nameTextField.delegate = self;
	[self.passwordTextField setReturnKeyType:UIReturnKeyDone];
	self.passwordTextField.delegate = self;
	self.passwordTextField.secureTextEntry = YES;
	[self.logInButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (!self.firstTimeLoggingIn) {
		[self.nameTextField removeFromSuperview];
		[self.passwordTextField setPlaceholder:@"Please enter your password."];
	}
    [self.view sendSubviewToBack:self.backgroundImageView];
}

-(BOOL) prefersStatusBarHidden {
	return YES;
}

-(void) centerViews {
	self.logoImageView.center = CGPointMake(self.view.center.x, self.logoImageView.center.y);
	self.nameTextField.center = CGPointMake(self.view.center.x, self.nameTextField.center.y);
	self.passwordTextField.center = CGPointMake(self.view.center.x, self.passwordTextField.center.y);
	self.logInButton.center = CGPointMake(self.view.center.x, self.logInButton.center.y);
}

-(void)createNavigationBar{
	CGRect navBarFrame = CGRectMake(0.f, 0.f, self.view.frame.size.width, CUSTOM_NAV_BAR_HEIGHT);
	self.navigationBar = [[CustomNavigationBar alloc] initWithFrame:navBarFrame andBackgroundColor: [UIColor clearColor]];
	self.navigationBar.delegate = self;
	[self.navigationBar createLeftButtonWithTitle:nil orImage:[UIImage imageNamed:BACK_BUTTON_ICON]];
	[self.view addSubview:self.navigationBar];
}

-(void) leftButtonPressed {
	[self performSegueWithIdentifier:UNWIND_SEGUE_FROM_USER_SETTINGS_TO_LOGIN sender:self];
}

-(void) loginButtonPressed {
	if (!self.firstTimeLoggingIn) {
		[self logInCurrentUser];
		return;
	}
	NSString *name = self.nameTextField.text;
	NSString *password = self.passwordTextField.text;
	if (name.length < 1) {
		[self showAlertWithTitle:@"Enter name" andMessage:@"Please enter a name for yourself on Verbatm."];
		return;
	}
	if (password.length < 6) {
		[self showAlertWithTitle:@"Enter password" andMessage:@"Your password must be at least 6 characters long."];
		return;
	}
	PFUser *newUser = [PFUser user];
	newUser.username = self.phoneNumber;
	newUser.password = password;
	[newUser setObject:name forKey:VERBATM_USER_NAME_KEY];
	[newUser setObject:[NSNumber numberWithBool:NO] forKey:USER_FTUE];
	[newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
		if (error || !succeeded) {
			[self showAlertWithTitle:@"Error signing up" andMessage: error.localizedDescription];
		} else {
			[self successfullyLoggedInAndUnwind];
		}
	}];
}

-(void) logInCurrentUser {
	NSString *password = self.passwordTextField.text;
	[PFUser logInWithUsernameInBackground:self.phoneNumber password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
		if (error || !user) {
			[self showAlertWithTitle:@"Error logging in" andMessage: @"Incorrect passoword. Please contact us if you need to reset it at feedback@verbatm.io"];
		} else {
			[self successfullyLoggedInAndUnwind];
		}
	}];
}

-(void) showAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
	UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:title message:message
																preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction * action) {}];
	[newAlert addAction:defaultAction];
	[self presentViewController:newAlert animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.nameTextField) {
		[textField resignFirstResponder];
		[self.passwordTextField becomeFirstResponder];
	} else if(textField == self.passwordTextField) {
		[self.passwordTextField resignFirstResponder];
		[self loginButtonPressed];
	}
	return NO;
}

// Unwind segue back to master vc
-(void) successfullyLoggedInAndUnwind {
	self.successfullyLoggedIn = YES;
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGIN_SUCCEEDED object:[PFUser currentUser]];
	[self performSegueWithIdentifier:UNWIND_SEGUE_FROM_USER_SETTINGS_TO_LOGIN sender:self];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
