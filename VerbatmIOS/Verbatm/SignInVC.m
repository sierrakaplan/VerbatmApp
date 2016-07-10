//
//  verbatmUserLoginViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 12/27/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//


#import <Crashlytics/Crashlytics.h>
#import "Durations.h"

#import "Notifications.h"

#import "LoginKeyboardToolBar.h"
#import "LogIntoAccount.h"

#import "SegueIDs.h"
#import "SignInVC.h"
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

#import "UserInfoVC.h"
#import "UserSetupParameters.h"
#import "UserManager.h"

#import "ChooseLoginOrSignup.h"
#import "CreateAccount.h"
#import "ConfirmationCodeSignUp.h"


@interface SignInVC () <UIScrollViewDelegate,CreateAccountProtocol,
                        ChooseLoginOrSignupProtocol, ConfirmationCodeSignUpDelegate, LogIntoAccountProtocol>

@property (nonatomic) BOOL loginFirstTimeDone;
@property (strong, nonatomic) UIView* animationView;
@property (strong, nonatomic) UILabel* animationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *verbatmLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobileBloggingLabel;

@property (strong, nonatomic) FBSDKLoginButton *loginButton;

@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (nonatomic) BOOL nextButtonEnabled;
@property (weak, nonatomic) IBOutlet UITextField *phoneLoginField;
@property (nonatomic) CGRect originalPhoneTextFrame;
@property (nonatomic) BOOL enteringPhoneNumber;
@property (strong, nonatomic) NSString *phoneNumber;
@property (nonatomic) BOOL firstTimeLoggingIn;

@property (nonatomic) UIScrollView * onBoardingView;
@property (nonatomic) UIScrollView * contentOnboardingPage;


@property (nonatomic) LogIntoAccount * loginToAccountView;


@property (nonatomic) ConfirmationCodeSignUp * confirmationCodeEntry;

@property (nonatomic) ChooseLoginOrSignup * chooseLoginOrSignUpView;
@property (nonatomic) CreateAccount * createAccountView;

#define BRING_UP_CREATE_ACCOUNT_SEGUE @"create_account_segue"

@property (weak, nonatomic) IBOutlet UIPageControl *pageControlView;

@end

@implementation SignInVC

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.backgroundImageView setFrame:self.view.bounds];
	[self centerViews];
	[self registerForNotifications];
	//[self addFacebookLoginButton];
	self.loginFirstTimeDone = NO;
	self.enteringPhoneNumber = YES;
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
																		  action:@selector(keyboardDidHide:)];

	[self.view addGestureRecognizer:tap];
    
    if(![[UserSetupParameters sharedInstance] checkOnboardingShown]){
        [self createOnBoarding];
    }else{
      [self.pageControlView removeFromSuperview];
    }
    [self presentLoginSignUpOption];
    [self.view sendSubviewToBack:self.backgroundImageView];
}


//forward == yes means that animation should go right to left (advancing to next screen)
-(void)replaceView:(UIView *) currentView withView:(UIView *)nextView goingForward:(BOOL) forward{
    
    if(currentView && nextView){
        
        
        if(forward){
            nextView.frame = CGRectMake(self.view.frame.size.width, 0.f, nextView.frame.size.width, nextView.frame.size.height);
            [self.view addSubview:nextView];
        }else{
            nextView.frame = CGRectMake(-self.view.frame.size.width, 0.f, nextView.frame.size.width, nextView.frame.size.height);
            [self.view addSubview:nextView];
        }
        
        [UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
            
            if(forward){
                currentView.frame = CGRectMake(- self.view.frame.size.width, 0.f, currentView.frame.size.width, currentView.frame.size.height);
                nextView.frame = self.view.bounds;
            }else{
                currentView.frame = CGRectMake(self.view.frame.size.width, 0.f, currentView.frame.size.width, currentView.frame.size.height);
                
                nextView.frame = self.view.bounds;
            }
            
        }];
    }
}

-(void)presentLoginSignUpOption{
    self.chooseLoginOrSignUpView = [[ChooseLoginOrSignup alloc] initWithFrame:self.view.bounds];
    self.chooseLoginOrSignUpView.delegate = self;
    [self.view addSubview:self.chooseLoginOrSignUpView];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if(scrollView == self.onBoardingView){
        self.pageControlView.currentPage = scrollView.contentOffset.x/self.view.bounds.size.width;
        
        if(scrollView.contentOffset.x == self.view.bounds.size.width *3){
            [scrollView removeFromSuperview];
            [self.pageControlView removeFromSuperview];
            [[UserSetupParameters sharedInstance] setOnboardingShown];
        }
        
    }else if (scrollView == self.contentOnboardingPage){
        if(scrollView.contentOffset.y == self.view.bounds.size.height){
            self.pageControlView.numberOfPages = 4;
            self.onBoardingView.contentSize = CGSizeMake(self.view.bounds.size.width *4, 0);
        }
    }
}

-(void)createOnBoarding{
    [self.view bringSubviewToFront:self.pageControlView];
    
    NSArray * planeNames = @[@"Welcome D6", @"Post"];
    NSArray * subSVNames= @[@"Content", @"Content Page 2"];
    
    
    for(int i = 0; i < planeNames.count; i ++){
        NSString * name =  planeNames[i];
        CGRect frame = CGRectMake(self.view.bounds.size.width * i, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        UIImageView * iv = [[UIImageView alloc] initWithFrame:frame];
        iv.image = [UIImage imageNamed:name];
        [self.onBoardingView addSubview:iv];
    }
    
    for(int i = 0; i < planeNames.count; i ++){
        NSString * name =  subSVNames[i];
        CGRect frame = CGRectMake(0, self.view.bounds.size.height * i, self.view.bounds.size.width, self.view.bounds.size.height);
        UIImageView * iv = [[UIImageView alloc] initWithFrame:frame];
        iv.image = [UIImage imageNamed:name];
        [self.contentOnboardingPage addSubview:iv];
    }
    [self.onBoardingView addSubview:self.contentOnboardingPage];
    
    [self.view addSubview:self.onBoardingView];
    [self.view bringSubviewToFront:self.onBoardingView];
    [self.view bringSubviewToFront:self.pageControlView];
    self.pageControlView.currentPage = 0;
    self.pageControlView.numberOfPages = 3;
    self.pageControlView.defersCurrentPageDisplay = YES;
    
    self.onBoardingView.delegate = self;
    self.contentOnboardingPage.delegate = self;
    
    CGRect pageControllViewFrame = CGRectMake((self.view.bounds.size.width/2.f)-(self.pageControlView.frame.size.width/2.f), self.view.bounds.size.height -  (self.pageControlView.frame.size.height + 10), self.pageControlView.frame.size.width, self.pageControlView.frame.size.height);
    self.pageControlView.frame = pageControllViewFrame;
    
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if(![[UserSetupParameters sharedInstance] checkTermsShown] && !self.loginFirstTimeDone){
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
	self.welcomeLabel.center = CGPointMake(self.view.center.x, self.welcomeLabel.center.y + 4);
	self.mobileBloggingLabel.center = CGPointMake(self.view.center.x, self.mobileBloggingLabel.center.y);
	self.orLabel.center = CGPointMake(self.view.center.x, self.orLabel.center.y);
	self.phoneLoginField.center = CGPointMake(self.view.center.x, self.phoneLoginField.center.y);
	self.originalPhoneTextFrame = self.phoneLoginField.frame;

		//self.phoneLoginField.delegate = self;
}

-(void)textNotAlphaNumericaCreateAccount{
    [self alertTextNotAcceptable];
}

-(void)alertTextNotAcceptable{
    UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Text Must Be Alphanumeric" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {}];
    [newAlert addAction:action1];
    [self presentViewController:newAlert animated:YES completion:nil];
}


-(void) setEnteringCode {
	self.enteringPhoneNumber = NO;
	self.phoneLoginField.text = @"";
	self.phoneLoginField.placeholder = @"Enter the 4-digit confirmation code:";
	self.nextButtonEnabled = YES;
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
	float buttonWidth = self.loginButton.frame.size.width*1.5;
	float buttonHeight = self.loginButton.frame.size.height*1.5;
	self.loginButton.frame = CGRectMake(self.view.center.x - buttonWidth/2.f, (self.view.frame.size.height/3.f) + 20.f,
										buttonWidth, buttonHeight);
	//self.loginButton.delegate = self;
	self.loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
	[self.view addSubview:self.loginButton];
	[self.view bringSubviewToFront:self.loginButton];
}



#pragma mark - Phone login Delegate -

-(void) sendCodeToUser {
	[self.phoneLoginField resignFirstResponder];
	NSString *simplePhoneNumber = self.phoneNumber;
	//todo: accept more phone numbers
	if (simplePhoneNumber.length != 10) {
		[self showAlertWithTitle:@"Phone Login" andMessage:@"You must enter a 10-digit US phone number including area code."];
		return;
	}

	self.nextButtonEnabled = NO;

	PFQuery *findUserQuery = [PFUser query];
	[findUserQuery whereKey:@"username" equalTo:simplePhoneNumber];
	[findUserQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable user, NSError * _Nullable error) {
		if (user && !error) {
			PFUser *currentUser = (PFUser*)user;
			NSString *name = [currentUser objectForKey:VERBATM_USER_NAME_KEY];
			if (name == nil) {
				//User never finished signing in so delete them
				[user deleteInBackground];
			} else {
				self.firstTimeLoggingIn = NO;
				self.phoneNumber = simplePhoneNumber;
				[self performSegueWithIdentifier:USER_SETTINGS_SEGUE sender:self];
				return;
			}
		}
		self.firstTimeLoggingIn = YES;
		self.phoneNumber = simplePhoneNumber;
		[self setEnteringCode];

		//todo: include more languages
		NSDictionary *params = @{@"phoneNumber" : simplePhoneNumber, @"language" : @"en"};
		[PFCloud callFunctionInBackground:@"sendCode" withParameters:params block:^(id  _Nullable response, NSError * _Nullable error) {
			if (error) {
				[[Crashlytics sharedInstance] recordError: error];
				[self showAlertWithTitle:@"Error sending code" andMessage:@"Something went wrong. Please verify your phone number is correct."];
			} else {
				// Parse has now created an account with this phone number and generated a random code,
				// user must enter the correct code to be logged in
			}
		}];

	}];
}

-(void) codeEnteredWithPhoneNumber:(NSString *)number andCode:(NSString *)code{
	self.nextButtonEnabled = NO;
	if (code.length != 4) {
		NSString *message = @"You must enter a 4 digit confirmation code.\
		It was sent in an SMS message to +1";
		message = [message stringByAppendingString:self.phoneNumber];
		[self showAlertWithTitle:@"Phone Login" andMessage: message];
		return;
	}

	NSDictionary *params = @{@"phoneNumber": number, @"codeEntry": code};
    
    __weak SignInVC * weakSelf = self;
    
	[PFCloud callFunctionInBackground:@"logIn" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
		if (error) {
			[weakSelf showAlertWithTitle:@"Login Error" andMessage: error.localizedDescription];
		} else {
			// This is the session token for the user
			NSString *token = (NSString*)object;

			[PFUser becomeInBackground:token block:^(PFUser * _Nullable user, NSError * _Nullable error) {
				if (error) {
					[weakSelf showAlertWithTitle:@"Login Error" andMessage:error.localizedDescription];
					[weakSelf setEnteringCode];
				} else {
					//delete so they can be recreated
					[user deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
						[weakSelf performSegueWithIdentifier:USER_SETTINGS_SEGUE sender:weakSelf];
					}];
				}
			}];
		}
	}];
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

#pragma mark -CreateAccount Protocol-
-(void)errorInSignInWithError:(NSString *)error{
    [self errorInSignInWithError:error];
}

-(void)loginWithFacebookSucceeded{
    
}

-(void)signUpWithPhoneNumberSelectedWithNumber:(NSString *) phoneNumber andPassword:(NSString *)password{
    self.phoneNumber = phoneNumber;
    self.confirmationCodeEntry.phoneNumberEntered = phoneNumber;
    [self sendCodeToUser];
    [self replaceView:self.createAccountView withView:self.confirmationCodeEntry goingForward:YES];
}

-(void)goBackSelectedCreateAccount{
    [self replaceView:self.createAccountView withView:self.chooseLoginOrSignUpView goingForward:NO];
    
}


-(void)codeSubmitted:(NSString *) enteredCode{
    [self codeEnteredWithPhoneNumber:self.phoneNumber andCode:enteredCode];
}

#pragma mark -LogIntoAccount Protocol-
-(void)goBackSelectedLoginAccount{
    [self replaceView:self.loginToAccountView withView:self.chooseLoginOrSignUpView goingForward:NO];
}

-(void)textNotAlphaNumericaLoginAccount{
    
}

-(void)loginUpWithPhoneNumberSelectedWithNumber:(NSString *) phoneNumber andPassword:(NSString *)password{
    [PFUser logInWithUsernameInBackground:phoneNumber password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (error || !user) {
            [self showAlertWithTitle:@"Incorrect password" andMessage: @"Please try again"];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGIN_SUCCEEDED object:[PFUser currentUser]];
           // [self unwindToMasterVC];
        }
    }];


}

-(void)errorInLogInWithError:(NSString *)error{
    
}





#pragma mark -ConfirmationCodeSignup Protocol-
-(void)goBackSelectedConfirmationCode{
    [self replaceView:self.confirmationCodeEntry  withView:self.createAccountView goingForward:NO];
}

-(void)resendCodeSelectedConfirmationCode{
    
}

-(void)codeSubmittedConfirmationCode:(NSString *) enteredCode{
    [self codeEnteredWithPhoneNumber:self.phoneNumber andCode:enteredCode];
}




#pragma mark -ChooseLoginOrSignUp Protocol-

-(void)signUpChosen{
    [self replaceView:self.chooseLoginOrSignUpView withView:self.createAccountView goingForward:YES];
}
-(void)loginChosen{
    [self replaceView:self.chooseLoginOrSignUpView withView:self.loginToAccountView goingForward:YES];
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

// Set data on segue to user settings vc
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:USER_SETTINGS_SEGUE]) {
		UserInfoVC* userViewController = [segue destinationViewController];
		userViewController.phoneNumber = self.phoneNumber;
		userViewController.firstTimeLoggingIn = self.firstTimeLoggingIn;
	} else {
		UIViewController *destinationViewController =  [segue destinationViewController];

		if([destinationViewController isKindOfClass:[TermsAndConditionsVC class]]){
			((TermsAndConditionsVC *)destinationViewController).userMustAcceptTerms = YES;
		}
	}
}

- (IBAction) unwindToSignIn: (UIStoryboardSegue *)segue {
	UIViewController *sourceViewController = [segue sourceViewController];
	if ([sourceViewController isKindOfClass:[UserInfoVC class]]) {
		UserInfoVC* userInfoVC = (UserInfoVC*)sourceViewController;
		if (userInfoVC.successfullyLoggedIn) {
			[self unwindToMasterVC];
		}
	}
}


#pragma mark - Lazy Instantiation -

//lazy instantiation
-(UIView *)animationView {
	if(!_animationView)_animationView = [[UIView alloc] initWithFrame:self.view.bounds];
	[_animationView addSubview:self.animationLabel];
	_animationView.alpha = 0;
	return _animationView;
}


-(UIScrollView *)onBoardingView{
    if(!_onBoardingView){
        _onBoardingView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _onBoardingView.contentSize = CGSizeMake(self.view.bounds.size.width * 3, 0);
        _onBoardingView.pagingEnabled = YES;
        _onBoardingView.bounces = NO;
        _onBoardingView.showsHorizontalScrollIndicator = NO;
        _onBoardingView.showsVerticalScrollIndicator = NO;
    }
    return _onBoardingView;
}

-(UIScrollView *)contentOnboardingPage{
    if(!_contentOnboardingPage){
        _contentOnboardingPage = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * 2, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _contentOnboardingPage.contentSize = CGSizeMake(0, self.view.bounds.size.height * 2);
        _contentOnboardingPage.pagingEnabled = YES;
        _contentOnboardingPage.bounces = NO;
        _contentOnboardingPage.showsHorizontalScrollIndicator = NO;
        _contentOnboardingPage.showsVerticalScrollIndicator = NO;
    }
    return _contentOnboardingPage;
}

//lazy instantiation
-(UILabel *)animationLabel {
    if(!_animationLabel){
            _animationLabel = [[UILabel alloc] init];

        _animationLabel.frame = CGRectMake(0, self.view.bounds.size.height/2.f - SIGN_IN_ERROR_VIEW_HEIGHT/2.f,
                                           self.view.bounds.size.width, SIGN_IN_ERROR_VIEW_HEIGHT);
        _animationLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _animationLabel.font = [UIFont fontWithName:REGULAR_FONT size:ERROR_ANIMATION_FONT_SIZE];
        _animationLabel.textColor = [UIColor ERROR_ANIMATION_TEXT_COLOR];
        _animationLabel.numberOfLines = 0;
        _animationLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_animationLabel setTextAlignment:NSTextAlignmentCenter];
    }
	return _animationLabel;
}

-(LogIntoAccount *)loginToAccountView{
    if(!_loginToAccountView){
        _loginToAccountView = [[LogIntoAccount alloc] initWithFrame:self.view.bounds];
        _loginToAccountView.delegate = self;
    }
    return _loginToAccountView;
}

-(CreateAccount *)createAccountView{
    if(!_createAccountView){
        _createAccountView = [[CreateAccount alloc] initWithFrame:self.view.bounds];
        _createAccountView.delegate = self;
    }
    return _createAccountView;
}



-(ConfirmationCodeSignUp *)confirmationCodeEntry{
    if(!_confirmationCodeEntry){
        _confirmationCodeEntry = [[ConfirmationCodeSignUp alloc] initWithFrame:self.view.bounds];
        _confirmationCodeEntry.delagate = self;
    }
    return _confirmationCodeEntry;
}




-(void)keyboardDidHide:(UITapGestureRecognizer *)gesture
{
    if(self.onBoardingView.contentOffset.x == 0){
        [UIView animateWithDuration:0.7 animations:^{
            self.onBoardingView.contentOffset = CGPointMake(self.view.frame.size.width, 0);
        }completion:^(BOOL finished) {
            if(finished){
                self.pageControlView.currentPage = self.onBoardingView.contentOffset.x/self.view.bounds.size.width;
            }
        }];
    }else if (self.onBoardingView.contentOffset.x == self.view.frame.size.width * 3){
        [self.phoneLoginField resignFirstResponder];
    }

}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
