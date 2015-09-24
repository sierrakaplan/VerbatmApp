//
//  CreateAccount.m
//  Verbatm
//
//  Created by Iain Usiri on 9/11/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "CreateAccount.h"
#import "GTLQueryVerbatmApp.h"
#import "GTLServiceVerbatmApp.h"
#import "GTLVerbatmAppVerbatmUser.h"
#import "GTLVerbatmAppEmail.h"
#import "GTMHTTPFetcherLogging.h"

#import "SegueIDs.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface CreateAccount ()<FBSDKLoginButtonDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *fullnameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (strong, nonatomic) UIButton* signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *loginRedirectButton;

@property (nonatomic) BOOL signUpButtonOnScreen;

@property(nonatomic, strong) GTLServiceVerbatmApp *service;

#define FACEBOOK_BUTTON_YOFFSET 40
#define SIGN_UP_BUTTON_TEXT @"Sign Up"
#define BRING_UP_SIGNIN_SEGUE @"login_segue"

@end

@implementation CreateAccount

-(void) viewDidLoad {
    [super viewDidLoad];
    if (self) {
		self.signUpButtonOnScreen = NO;
        [self setTextFieldFrames];
        [self setTextFieldDelegates];
        [self addFacebookLoginButton];
    }
}

-(void) setTextFieldFrames {

	self.emailField.frame = CGRectMake((self.view.frame.size.width/2) - (self.emailField.frame.size.width/2) , self.emailField.frame.origin.y, self.emailField.frame.size.width, self.emailField.frame.size.height);
	self.fullnameField.frame = CGRectMake((self.view.frame.size.width/2) - (self.fullnameField.frame.size.width/2) , self.fullnameField.frame.origin.y, self.fullnameField.frame.size.width, self.fullnameField.frame.size.height);
	self.passwordField.frame = CGRectMake((self.view.frame.size.width/2) - (self.passwordField.frame.size.width/2) , self.passwordField.frame.origin.y, self.passwordField.frame.size.width, self.passwordField.frame.size.height);
	self.phoneNumberField.frame = CGRectMake((self.view.frame.size.width/2) - (self.phoneNumberField.frame.size.width/2) , self.phoneNumberField.frame.origin.y, self.phoneNumberField.frame.size.width, self.phoneNumberField.frame.size.height);
	self.orLabel.frame = CGRectMake((self.view.frame.size.width/2) - (self.orLabel.frame.size.width/2) , self.orLabel.frame.origin.y, self.orLabel.frame.size.width, self.orLabel.frame.size.height);

}

-(void) setTextFieldDelegates {
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    self.fullnameField.delegate = self;
    self.phoneNumberField.delegate = self;
}

- (void) addFacebookLoginButton {
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    float buttonWidth = loginButton.frame.size.width*1.5;
    float buttonHeight = loginButton.frame.size.height*1.5;
    loginButton.frame = CGRectMake(self.view.center.x - buttonWidth/2, self.orLabel.frame.origin.y + self.orLabel.frame.size.height +FACEBOOK_BUTTON_YOFFSET, buttonWidth, buttonHeight);
    loginButton.delegate = self;
    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    [self.view addSubview:loginButton];
}


//We add a sign up button to the screen once user starts typing in
//any of the create account fields (once they don't sign up with FB)
-(void)replaceOrFBWithSignUpButton {
    if (self.signUpButtonOnScreen) {
		return;
	}

	float buttonWidth  = self.fullnameField.frame.size.width;
	float buttonX = self.view.center.x - buttonWidth/2;
	float buttonY = self.orLabel.frame.origin.y;
	float buttonHeight = self.fullnameField.frame.size.height;
    self.signUpButton = [[UIButton alloc] initWithFrame: CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight)];
    [self.signUpButton setTitle: SIGN_UP_BUTTON_TEXT forState:UIControlStateNormal];
    self.signUpButton.backgroundColor = [UIColor lightGrayColor];
    [self.signUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.signUpButton addTarget:self action:@selector(completeAccountCreation) forControlEvents:UIControlEventTouchUpInside];

	// replaces sign up with fb on screen
    [self.orLabel removeFromSuperview];
    [self.view addSubview: self.signUpButton];
	self.signUpButtonOnScreen = YES;
}

//called when the user is done inputting their information
-(void) completeAccountCreation {
    /*To do*/
    if (self.emailField.text.length > 0 &&
       self.phoneNumberField.text.length > 0 &&
       self.passwordField.text.length > 0 &&
       self.fullnameField.text.length > 0) {
        /*Do some login stuff */

    } else {
        /*Give them some sort of prompt
         for what's missing
         */
        
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
		//TODO(sierrakn): Do something with error
		return;
	}

	//TODO(sierrakn): If any declined permissions are essential (like email)
	//explain to user why and ask them to agree to each individually
	NSSet* declinedPermissions = result.declinedPermissions;

	//batch request for user info as well as friends
	if ([FBSDKAccessToken currentAccessToken]) {

		FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
		//get current signed-in user info
		NSDictionary* userFields =  [NSDictionary dictionaryWithObject: @"id,name,email,picture,friends" forKey:@"fields"];
		FBSDKGraphRequest *requestMe = [[FBSDKGraphRequest alloc]
								  initWithGraphPath:@"me" parameters:userFields];
		[connection addRequest:requestMe
			 completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
				 if (!error) {
					 NSLog(@"Fetched User: %@", result);

					 NSString* name = result[@"name"];
					 NSString* email = result[@"email"];
					 NSString* pictureURL = result[@"picture"][@"data"][@"url"];
					 //will only show friends who have signed up for the app with fb
					 NSArray* friends = nil;
					 if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"user_friends"]) {
					 	friends = result[@"friends"][@"data"];
					 }
					 GTLVerbatmAppVerbatmUser* verbatmUser = [GTLVerbatmAppVerbatmUser alloc];
					 GTLVerbatmAppEmail* verbatmEmail = [GTLVerbatmAppEmail alloc];
					 verbatmEmail.email = email;

					 verbatmUser.name = name;
					 verbatmUser.email = verbatmEmail;
					 [self signUpUser:verbatmUser];
				 }
			 }];

		[connection start];
	}
}

/*!
 @abstract Sent to the delegate when the button was used to logout.
 @param loginButton The button that was clicked.
 */
- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {

}

#pragma mark - Sign Up User Logic -

- (void) signUpUser:(GTLVerbatmAppVerbatmUser*) user {
	GTLQueryVerbatmApp* query = [GTLQueryVerbatmApp queryForVerbatmuserInsertUserWithObject:user];
	[self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppVerbatmUser *object, NSError *error) {
		if (!error) {
			// Do something with user info
			//Send a notification that the user is logged in
			// unwind segue
//			[self performSegueWithIdentifier:EXIT_SIGNIN_SEGUE sender:self];
		} else {
			NSLog(@"Error signing up user: %@", error.description);
			//TODO:Error handling
		}
	}];
	/*removes the current VC by going two layers deep */
	[self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
	}];
}

#pragma mark - Navigation

// Segue back to the MasterNavigationVC after logging in
// Or segue to Sign In
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.
}

#pragma mark - Text field Delegate -

- (void)textFieldDidBeginEditing: (UITextField *)textField {
	if (!self.signUpButtonOnScreen) {
		[self replaceOrFBWithSignUpButton];
	}
}

#pragma mark - Lazy Instantiation -

- (GTLServiceVerbatmApp *)service {
	if (!_service) {
		_service = [[GTLServiceVerbatmApp alloc] init];
		_service.retryEnabled = YES;
		// Development only
		[GTMHTTPFetcher setLoggingEnabled:YES];
	}
	return _service;
}

@end
