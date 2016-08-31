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

#import "UserSetupParameters.h"
#import "UserManager.h"
#import "VerbatmNavigationController.h"

@interface LoginVC ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoTextView;

@property (nonatomic) UIButton *loginButton;
@property (nonatomic) UIButton *signUpButton;

#define Y_OFFSET 50.f
#define LOGIN_BUTTON_HEIGHT 120.f
#define LOGO_TEXT_Y_OFFSET 30.f
#define LOGO_TEXT_WIDTH 200.f

@end

@implementation LoginVC

- (void)viewDidLoad {
	[super viewDidLoad];
	[self formatNavigationItem];
	[self.backgroundImageView setFrame:self.view.bounds];
	[self.view addSubview: self.loginButton];
	[self.view addSubview: self.signUpButton];
	self.logoTextView.frame = CGRectMake(self.view.center.x - LOGO_TEXT_WIDTH/2.f, LOGO_TEXT_Y_OFFSET,
										 LOGO_TEXT_WIDTH, 100.f);
	[self.view sendSubviewToBack:self.backgroundImageView];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO];
	[(VerbatmNavigationController*)self.navigationController setNavigationBarBackgroundClear];
	[(VerbatmNavigationController*)self.navigationController setNavigationBarTextColor:[UIColor whiteColor]];
}

-(BOOL) prefersStatusBarHidden {
	return YES;
}

-(void) formatNavigationItem {
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
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

-(UIButton*) loginButton {
	if (!_loginButton) {
		CGFloat xPos = (self.view.frame.size.width - LOGIN_BUTTON_HEIGHT*2)/3.f;
		CGRect frame = CGRectMake(xPos, self.view.frame.size.height - LOGIN_BUTTON_HEIGHT - Y_OFFSET,
								  LOGIN_BUTTON_HEIGHT, LOGIN_BUTTON_HEIGHT);
		_loginButton = [[UIButton alloc] initWithFrame: frame];
		[self formatLoginButton: _loginButton];
		[_loginButton setAttributedTitle:[self attributedLoginTitle:@"Log in"] forState:UIControlStateNormal];
		[_loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _loginButton;
}

-(UIButton*) signUpButton {
	if (!_signUpButton) {
		CGFloat xOffset = (self.view.frame.size.width - LOGIN_BUTTON_HEIGHT*2)/3.f;
		CGFloat xPos = self.loginButton.frame.origin.x + self.loginButton.frame.size.width + xOffset;
		CGRect frame = CGRectMake(xPos, self.view.frame.size.height - LOGIN_BUTTON_HEIGHT - Y_OFFSET,
								  LOGIN_BUTTON_HEIGHT, LOGIN_BUTTON_HEIGHT);
		_signUpButton = [[UIButton alloc] initWithFrame:frame];
		[self formatLoginButton: _signUpButton];
		[_signUpButton setBackgroundColor:VERBATM_GOLD_COLOR_TRANSLUCENT];
		[_signUpButton setAttributedTitle:[self attributedLoginTitle:@"Sign up"] forState:UIControlStateNormal];
		[_signUpButton addTarget:self action:@selector(signUpButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _signUpButton;
}

-(void) formatLoginButton:(UIButton*)loginButton {
	loginButton.backgroundColor = [UIColor clearColor];
	loginButton.layer.borderColor = [UIColor whiteColor].CGColor;
	loginButton.layer.borderWidth = 2.f;
	loginButton.layer.cornerRadius = 2.f;
}

-(NSAttributedString*) attributedLoginTitle:(NSString*)text {
	NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
									  NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:20.f]}; //todo
	NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:text attributes:titleAttributes];
	return attributedTitle;
}

@end
