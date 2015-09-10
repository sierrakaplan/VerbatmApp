//
//  verbatmUserLoginViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 12/27/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "UserLoginVC.h"
#import "Notifications.h"
#import "Identifiers.h"
#import "SizesAndPositions.h"
#import "Durations.h"
#import "Styles.h"
#import "UIEffects.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLServiceVerbatmApp.h"
#import "GTMHTTPFetcherLogging.h"

#import "GTLQueryVerbatmApp.h"
#import "GTLVerbatmAppVerbatmUser.h"
#import "GTLVerbatmAppEmail.h"
#import "GTLVerbatmAppImage.h"

@interface UserLoginVC () <UITextFieldDelegate, FBSDKLoginButtonDelegate>
#define TOAST_DURATION 1

@property (weak, nonatomic) IBOutlet UITextField *UserName_TextField;
@property (weak, nonatomic) IBOutlet UITextField *Password_TextField;
@property (weak, nonatomic) IBOutlet UILabel *verbatmTitle_label;

@property (weak, nonatomic) IBOutlet UIButton *signIn_button;
@property (weak, nonatomic) IBOutlet UIButton *signUp_button;
@property (strong, nonatomic) UIView *animationView;
@property (strong, nonatomic) UILabel* animationLabel;
@property (strong, nonatomic) NSTimer * animationTimer;


@property(nonatomic, strong) GTMOAuth2Authentication *auth;
@property(nonatomic, strong) GTLServiceVerbatmApp *service;

@end

@implementation UserLoginVC

@synthesize service = _service;

static NSString *const kKeychainItemName = @"VerbatmIOS";
NSString *kMyClientID = @"340461213452-vrmr2vt1v1adgkra963vomulfv449odv.apps.googleusercontent.com";
NSString *kMyClientSecret = @"H4jYylR_xFqh4EyX60wLdS20";



- (void)viewDidLoad {
    [super viewDidLoad];

    self.UserName_TextField.delegate = self;
    self.Password_TextField.delegate = self;
    [self centerAllframes];
    [self showCursor];
    [self formatTextFields];

	[self addFacebookLoginButton];
//	[self authenticateUser];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


#pragma mark - Google Auth -

- (GTLServiceVerbatmApp *)service {
	if (!_service) {
		_service = [[GTLServiceVerbatmApp alloc] init];
		_service.retryEnabled = YES;
		// Development only
//		[GTMHTTPFetcher setLoggingEnabled:YES];
	}

	return _service;
}

-(void)showGoogleUserLoginView {
	GTMOAuth2ViewControllerTouch *oauthViewController;
	oauthViewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:@"email profile"
																	 clientID:kMyClientID
																 clientSecret:kMyClientSecret
															 keychainItemName:kKeychainItemName
																	 delegate:self
															 finishedSelector:@selector(viewController:finishedWithAuth:error:)];

	[self presentViewController:oauthViewController animated:YES completion:nil];
}

// Callback method after user finished the login.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)oauthViewController
	  finishedWithAuth:(GTMOAuth2Authentication *)auth
				 error:(NSError *)error {
	[self dismissViewControllerAnimated:YES completion:nil];

	if (error) {
		//TODO: something
		NSLog(@"Auth error: %@", error);
	} else {
		//TODO: sign in succeeded
		self.auth = auth;
		[self resetAccessTokenForCloudEndpoint];
	}
}

// Reset access token value for authentication object for Cloud Endpoint.
- (void)resetAccessTokenForCloudEndpoint {
	GTMOAuth2Authentication *auth = self.auth;
	if (auth) {
		[self.service setAuthorizer:auth];

		//TODO:Add a sign out button
	}
}

- (void)authenticateUser {
	if (!self.auth) {
		// Instance doesn't have an authentication object, attempt to fetch from
		// keychain.  This method call always returns an authentication object.
		// If nothing is returned from keychain, this will return an invalid
		// authentication
		self.auth = [GTMOAuth2ViewControllerTouch
					 authForGoogleFromKeychainForName:kKeychainItemName
					 clientID:kMyClientID
					 clientSecret:kMyClientSecret];
	}

	// Now instance has an authentication object, check if it's valid
	if ([self.auth canAuthorize]) {
		// Looks like token is good, reset instance authentication object
		[self resetAccessTokenForCloudEndpoint];
	} else {
		// If there is some sort of error when validating the previous
		// authentication, reset the authentication and force user to login
		self.auth = nil;
		[self showGoogleUserLoginView];
	}
}

// Signing user out and revoke token
- (void)unAuthenticateUser {
	[GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
	[GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];
	[self.auth reset];
}


#pragma mark - Facebook Login Delegate Methods -

- (void) addFacebookLoginButton {
	FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
	float buttonWidth = loginButton.frame.size.width*1.2;
	float buttonHeight = loginButton.frame.size.height*1.2;
	loginButton.frame = CGRectMake(self.view.center.x - buttonWidth/2, self.UserName_TextField.frame.origin.y - buttonHeight - 20, buttonWidth, buttonHeight);
	loginButton.delegate = self;
	loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
	[self.view addSubview:loginButton];
}

- (void)  loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
				error:(NSError *)error {

	if (error || result.isCancelled) {
		//TODO(sierrakn): Do something with error
		return;
	}

	//TODO(sierrakn): If any declined permissions are essential (like email)
	//explain to user why and ask them to agree to each individually
//	NSSet* declinedPermissions = result.declinedPermissions;

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
					 //TODO: NSString* pictureURL = result[@"picture"][@"data"][@"url"];
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

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
	//TODO(sierrakn): do something?
}


# pragma mark - Centering other frames -

//dynamically centers all our frames depending on phone screen dimensions
-(void) centerAllframes
{
    self.verbatmTitle_label.frame = CGRectMake((self.view.frame.size.width/2 - self.verbatmTitle_label.frame.size.width/2), self.verbatmTitle_label.frame.origin.y, self.verbatmTitle_label.frame.size.width, self.verbatmTitle_label.frame.size.height);
    
    self.signIn_button.frame =CGRectMake((self.view.frame.size.width/2 - self.signIn_button.frame.size.width/2), self.signIn_button.frame.origin.y, self.signIn_button.frame.size.width, self.signIn_button.frame.size.height);
    
    self.signUp_button.frame= CGRectMake((self.view.frame.size.width/2 - self.signUp_button.frame.size.width/2), self.signUp_button.frame.origin.y, self.signUp_button.frame.size.width, self.signUp_button.frame.size.height);
    
    self.UserName_TextField.frame= CGRectMake((self.view.frame.size.width/2 - self.UserName_TextField.frame.size.width/2), self.UserName_TextField.frame.origin.y, self.UserName_TextField.frame.size.width, self.UserName_TextField.frame.size.height);
    
    self.Password_TextField.frame = CGRectMake((self.view.frame.size.width/2 - self.Password_TextField.frame.size.width/2), self.Password_TextField.frame.origin.y, self.Password_TextField.frame.size.width, self.Password_TextField.frame.size.height);
}

-(void) showCursor{
    self.UserName_TextField.tintColor = [UIColor colorWithRed:98.0/255.0f green:98.0/255.0f blue:98.0/255.0f alpha:1.0];
    
    self.Password_TextField.tintColor = [UIColor colorWithRed:98.0/255.0f green:98.0/255.0f blue:98.0/255.0f alpha:1.0];
    
}

-(void) formatTextFields {
    [self.UserName_TextField setReturnKeyType:UIReturnKeyNext];
    [self.Password_TextField setReturnKeyType:UIReturnKeyDone];

	[UIEffects disableSpellCheckOnTextField:self.UserName_TextField];
	[UIEffects disableSpellCheckOnTextField:self.Password_TextField];

}

// Enter button presses login
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.UserName_TextField)
    {
        [self.Password_TextField becomeFirstResponder];
        return YES;
    }
    if (textField == self.Password_TextField)
    {
        // [self signUpUser:self.signUp_button];
        [self.Password_TextField resignFirstResponder];
        return YES;
    }
    return NO;
}

#pragma mark - Login and Sign Up Logic -

- (void) signUpUser:(GTLVerbatmAppVerbatmUser*) user {
	GTLQueryVerbatmApp* query = [GTLQueryVerbatmApp queryForVerbatmuserInsertUserWithObject:user];
	[self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppVerbatmUser *object, NSError *error) {
		if (!error) {
			// Do something with user info
			//Send a notification that the user is logged in
			[self performSegueWithIdentifier:EXIT_SIGNIN_SEGUE sender:self];
		} else {
			NSLog(@"Error signing up user: %@", error.description);
			//TODO:Error handling
		}
	}];
}

//- (void) loginUser:(GTLVerbatmAppVerbatmUser*) user {
//	//TODO
//}



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

//for ios8- To hide the status bar
-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void) removeStatusBar{
    //remove the status bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}


-(NSUInteger)supportedInterfaceOrientations{
    //return supported orientation masks
    return UIInterfaceOrientationMaskPortrait;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
