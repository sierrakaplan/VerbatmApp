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

@interface SignIn () <UITextFieldDelegate, FBSDKLoginButtonDelegate>

@property (strong, nonatomic) UIView* animationView;
@property (strong, nonatomic) UILabel* animationLabel;
@property (strong, nonatomic) NSTimer* animationTimer;

#define BRING_UP_CREATE_ACCOUNT_SEGUE @"create_account_segue"

@end

@implementation SignIn

- (void)viewDidLoad {
	[super viewDidLoad];
	[self registerForNotifications];
	[self addFacebookLoginButton];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
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
	FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
	float buttonWidth = loginButton.frame.size.width*1.2;
	float buttonHeight = loginButton.frame.size.height*1.2;
	loginButton.frame = CGRectMake(self.view.center.x - buttonWidth/2.f, self.view.center.y
								   - buttonHeight/2.f, buttonWidth, buttonHeight);
	loginButton.delegate = self;
	loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
	[self.view addSubview:loginButton];
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
	
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:errorMessage message:@""
                                                    delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
//    if(self.animationView.alpha > 0) return;
//	[self.animationLabel setText:errorMessage];
//	[self.view addSubview:self.animationView];
//	[self.view bringSubviewToFront:self.animationView];
//	[self showAnimationView:YES];
//	self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:ERROR_MESSAGE_ANIMATION_TIME target:self selector:@selector(removeAnimationView) userInfo:nil repeats:YES];
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

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// Segue back to the MasterNavigationVC after logging in
// Or segue to create account
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.
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
