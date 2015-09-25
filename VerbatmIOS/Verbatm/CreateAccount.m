//
//  CreateAccount.m
//  Verbatm
//
//  Created by Iain Usiri on 9/11/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "CreateAccount.h"
#import "Durations.h"
#import "GTLQueryVerbatmApp.h"
#import "GTLServiceVerbatmApp.h"
#import "GTLVerbatmAppVerbatmUser.h"
#import "GTLVerbatmAppPhoneNumber.h"
#import "GTLVerbatmAppEmail.h"
#import "GTMHTTPFetcherLogging.h"

#import "SegueIDs.h"
#import "SizesAndPositions.h"
#import "Styles.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/PFUser.h>
#import <ParseFacebookutilsV4/PFFacebookUtils.h>


@interface CreateAccount () <FBSDKLoginButtonDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *fullnameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (strong, nonatomic) UIButton* signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *loginRedirectButton;

@property (nonatomic) BOOL signUpButtonOnScreen;

@property(nonatomic, strong) GTLServiceVerbatmApp *service;

@property (strong, nonatomic) UIView *animationView;
@property (strong, nonatomic) UILabel* animationLabel;
@property (strong, nonatomic) NSTimer * animationTimer;

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

		[PFFacebookUtils logInInBackgroundWithAccessToken:[FBSDKAccessToken currentAccessToken] block:^(PFUser * _Nullable user, NSError * _Nullable error) {
			if (error) {
				//TODO:
			}
		}];

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

#pragma mark - Parse Authentication -

//Called when user presses signUp
-(void) completeAccountCreation {

	NSString* email = self.emailField.text;
	NSString* phoneNumber = self.phoneNumberField.text;
	NSString* password = self.passwordField.text;
	NSString* name = self.fullnameField.text;

	if (email.length > 0 &&
		password.length > 0 &&
		name.length > 0) {

		PFUser* newUser = [[PFUser alloc] init];
		// TODO: send confirmation email (must be unique)
		newUser.username = email;
		newUser.password = password;
		[newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
			if(succeeded) {
				GTLVerbatmAppVerbatmUser* verbatmUser = [GTLVerbatmAppVerbatmUser alloc];

				verbatmUser.name = name;

				GTLVerbatmAppEmail* verbatmEmail = [GTLVerbatmAppEmail alloc];
				verbatmEmail.email = email;
				verbatmUser.email = verbatmEmail;

				if (phoneNumber.length) {
					GTLVerbatmAppPhoneNumber* verbatmPhoneNumber = [GTLVerbatmAppPhoneNumber alloc];
					verbatmPhoneNumber.number = phoneNumber;
					verbatmUser.phoneNumber = verbatmPhoneNumber;
				}
				
				[self signUpUser:verbatmUser];

			} else {
				NSString* errorMessage;
				if([error code] == kPFErrorUsernameTaken) {
					errorMessage = @"An account with that email already exists. Try logging in.";
				} else {
					errorMessage = @"We're sorry, something went wrong!";
				}
				[self errorInSignInAnimation:errorMessage];
			}
		}];

	} else {
		/*Give them some sort of prompt
		 for what's missing
		 */

	}
}


#pragma mark - Sign Up User Logic -

- (void) signUpUser:(GTLVerbatmAppVerbatmUser*) user {
	GTLQueryVerbatmApp* query = [GTLQueryVerbatmApp queryForVerbatmuserInsertUserWithObject:user];
	[self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppVerbatmUser *object, NSError *error) {
		if (!error) {
			NSLog(@"Successfully inserted user object");
		} else {
			NSLog(@"Error signing up user: %@", error.description);
			//TODO:Error handling
		}
	}];
	/*removes the current VC by going two layers deep */
	[self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
	}];
}

#pragma mark Error message

//article publsihed sucessfully
-(void)errorInSignInAnimation:(NSString*)error {
	if(self.animationView.alpha > 0) return;
	[self.animationLabel setText:error];
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
