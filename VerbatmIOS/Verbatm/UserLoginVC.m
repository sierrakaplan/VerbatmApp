//
//  verbatmUserLoginViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 12/27/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "UserLoginVC.h"
#import "VerbatmUser.h"
#import "Notifications.h"
#import "Identifiers.h"
#import "SizesAndPositions.h"
#import "Durations.h"
#import "Styles.h"
#import "UIEffects.h"

@interface UserLoginVC () <UITextFieldDelegate>
#define TOAST_DURATION 1

@property (weak, nonatomic) IBOutlet UITextField *UserName_TextField;
@property (weak, nonatomic) IBOutlet UITextField *Password_TextField;
@property (weak, nonatomic) IBOutlet UILabel *verbatmTitle_label;

@property (weak, nonatomic) IBOutlet UIButton *signIn_button;
@property (weak, nonatomic) IBOutlet UIButton *signUp_button;
@property (strong, nonatomic) UIView *animationView;
@property (strong, nonatomic) UILabel* animationLabel;
@property (strong, nonatomic) NSTimer * animationTimer;
@end

@implementation UserLoginVC

- (void)viewDidLoad
{
    [super viewDidLoad];


    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signUpFailed:) name:SINGUP_FAILED_NOTIFIACTION object: nil];
    self.UserName_TextField.delegate = self;
    self.Password_TextField.delegate = self;
    [self centerAllframes];
    [self showCursor];
    [self formatTextFields];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

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


- (IBAction)login:(UIButton *)sender {
	//make sure all the textfields are entered in correctly
	if([self.UserName_TextField.text isEqualToString:@""]) return;
	if([self.Password_TextField.text isEqualToString:@""]) return;

    [VerbatmUser loginUserWithUserName:self.UserName_TextField.text andPassword:self.   Password_TextField.text withCompletionBlock:^(PFUser *user, NSError *error){
        if(user) {
            [self performSegueWithIdentifier:EXIT_SIGNIN_SEGUE sender:self];
        }else {
			NSString* errorMessage;
			if([error code] == kPFErrorObjectNotFound) {
				errorMessage = @"Username or password incorrect.";
			} else {
				errorMessage = @"We're sorry, something went wrong!";
			}
			[self errorInSignInAnimation:errorMessage];
        }
    }];
}

- (IBAction)signUp:(UIButton *)sender {
	//make sure all the textfields are entered in correctly
	if([self.UserName_TextField.text isEqualToString:@""]) return;
	if([self.Password_TextField.text isEqualToString:@""]) return;

	#pragma GCC diagnostic ignored "-Wunused-variable"
	VerbatmUser * newUser = [[VerbatmUser alloc] initWithUserName:self.UserName_TextField.text Password:self.Password_TextField.text  withSignUpCompletionBlock:^(BOOL succeeded, NSError *error) {

		if(succeeded) {
			//Send a notification that the user is logged in
			[self performSegueWithIdentifier:EXIT_SIGNIN_SEGUE sender:self];

		} else {
			NSString* errorMessage;
			if([error code] == kPFErrorUsernameTaken) {
				errorMessage = @"An account with that username already exists.";
			} else {
				errorMessage = @"We're sorry, something went wrong!";
			}
			[self errorInSignInAnimation:errorMessage];
		}

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

-(void) removeStatusBar
{
    //remove the status bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
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
