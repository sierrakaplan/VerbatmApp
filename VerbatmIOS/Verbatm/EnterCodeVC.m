//
//  EnterCodeVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/23/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "EnterCodeVC.h"
#import "LoginKeyboardToolBar.h"
#import <Parse/PFCloud.h>
#import "Notifications.h"
#import "UtilityFunctions.h"
#import "SegueIDs.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "UIView+Effects.h"
#import "UserSetupParameters.h"

#import <Parse/PFUser.h>
#import "ParseBackendKeys.h"

@interface EnterCodeVC() <UITextFieldDelegate, LoginKeyboardToolBarDelegate>

@property (nonatomic) NSString *simplePhoneNumber;

@property (nonatomic) UITextField *digitOneField;
@property (nonatomic) UITextField *digitTwoField;
@property (nonatomic) UITextField *digitThreeField;
@property (nonatomic) UITextField *digitFourField;

@property (nonatomic) UILabel *codeSentToNumberLabel;

@property (nonatomic) BOOL verifyingCode;
@property (nonatomic) BOOL segueCalled;
@property (nonatomic) UIButton *resendCodeButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

#define CODE_TEXT_FIELD_Y_OFFSET 100.f
#define CODE_TEXT_FIELD_WIDTH 50.f
#define CODE_SPACING 10.f
#define VERTICAL_SPACING 5.f
#define ZERO_WIDTH_CHARACTER @"\u200B"

#define RESEND_CODE_BUTTON_WIDTH 150.f
#define RESEND_CODE_BUTTON_HEIGHT 50.f
#define RESEND_CODE_FONT_SIZE 20.f

@end

@implementation EnterCodeVC

-(void) viewDidLoad {
	self.verifyingCode = NO;
	self.simplePhoneNumber = [UtilityFunctions removeAllNonNumbersFromString: self.phoneNumber];
	[self sendCodeToUser: self.simplePhoneNumber];
	[self.view addSubview: self.digitOneField];
	[self.view addSubview: self.digitTwoField];
	[self.view addSubview: self.digitThreeField];
	[self.view addSubview: self.digitFourField];
	[self.view addSubview: self.codeSentToNumberLabel];
	[self.view addSubview: self.resendCodeButton];
	self.backgroundImageView.frame = self.view.bounds;
	[self.view sendSubviewToBack:self.backgroundImageView];
	[self.digitOneField becomeFirstResponder];
	[self formatNavigationItem];
}

-(void)viewWillAppear:(BOOL)animated{
    self.segueCalled = NO;
}

-(BOOL) prefersStatusBarHidden {
	return YES;
}

-(void) formatNavigationItem {
	self.navigationItem.title = self.creatingAccount ? @"Verify phone number" : @"Enter code to log in";
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
}

-(void) sendCodeToUser:(NSString*) simplePhoneNumber {
<<<<<<< HEAD
	return;
=======
   // return;//todo: this line lines allow testing create new accounts (use phone numbers no one has)
    
>>>>>>> TestPhoneLogin
	[self disableResendCodeButtonWithText:@"Sending code..."];
	//todo: include more languages
	NSDictionary *params = @{@"phoneNumber" : simplePhoneNumber, @"language" : @"en"};
	[PFCloud callFunctionInBackground:@"sendCode" withParameters:params block:^(id  _Nullable response, NSError * _Nullable error) {
		[self enableResendCodeButton];
		if (error) {
			[[Crashlytics sharedInstance] recordError: error];
			[self showAlertWithTitle:@"Error sending code" andMessage:@"Something went wrong. Please verify your phone number is correct."];
			self.codeSentToNumberLabel.text = @"Attempted to send code to ";
		} else {
			self.codeSentToNumberLabel.text = @"Enter the code sent to +1 ";
		}
		self.codeSentToNumberLabel.text = [_codeSentToNumberLabel.text stringByAppendingString: self.phoneNumber];
	}];
	
}

-(void) disableResendCodeButtonWithText:(NSString*)text {
	self.resendCodeButton.enabled = NO;
	self.resendCodeButton.layer.borderColor = [UIColor grayColor].CGColor;
	self.codeSentToNumberLabel.hidden = YES;
	NSAttributedString *attributedTitle = [self getAttributedTitleForResendCodeButtonWithText:text
																				 andTextColor:[UIColor grayColor]];
	[self.resendCodeButton setAttributedTitle:attributedTitle forState: UIControlStateNormal];
}

-(void) enableResendCodeButton {
	self.resendCodeButton.enabled = YES;
	self.resendCodeButton.layer.borderColor = [UIColor whiteColor].CGColor;
	self.codeSentToNumberLabel.hidden = NO;
	NSAttributedString *attributedTitle = [self getAttributedTitleForResendCodeButtonWithText:@"Resend code"
																				 andTextColor:[UIColor whiteColor]];
	[self.resendCodeButton setAttributedTitle:attributedTitle forState: UIControlStateNormal];
}

-(NSAttributedString*) getAttributedTitleForResendCodeButtonWithText:(NSString*)text andTextColor:(UIColor*)color {
	NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: color,
									  NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size: RESEND_CODE_FONT_SIZE]};
	NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:text attributes:titleAttributes];
	return attributedTitle;
}

-(void)goOnToCreateName{
    if(self.segueCalled) return;
    self.segueCalled = YES;
    [self performSegueWithIdentifier:SEGUE_CREATE_NAME sender:self];
    
}

-(void) verifyCode {
	NSString *code = [self getCode];

//	//todo: these lines lines allow testing create new accounts (use phone numbers no one has)
<<<<<<< HEAD
	PFUser *newUser = [PFUser user];
	newUser.username = self.simplePhoneNumber;
	newUser.password = code;
	[newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
		[self performSegueWithIdentifier:SEGUE_CREATE_NAME sender:self];
	}];

	return;
=======
//	PFUser *newUser = [PFUser user];
//	newUser.username = self.simplePhoneNumber;
//	newUser.password = code;
//	[newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//        [self goOnToCreateName];
//    }];
//
//	return;
>>>>>>> TestPhoneLogin

	if (self.verifyingCode) return;
	self.verifyingCode = YES;
	[self disableResendCodeButtonWithText:@"Verifying code..."];
	NSLog(@"verifying code");
	code = [UtilityFunctions removeAllNonNumbersFromString: code];
	code = [code stringByReplacingOccurrencesOfString:ZERO_WIDTH_CHARACTER withString:@""];
	if (code.length != 4) {
		[self showWrongCode];
	} else {
		//todo: show something's happening
		NSDictionary *params = @{@"phoneNumber": self.simplePhoneNumber, @"codeEntry": code};
		[PFCloud callFunctionInBackground:@"logIn" withParameters:params
									block:^(id  _Nullable object, NSError * _Nullable error) {
			if (error) {
				[self showWrongCode];
			} else {
				// This is the session token for the user
				NSString *token = (NSString*)object;

				[PFUser becomeInBackground:token block:^(PFUser * _Nullable user, NSError * _Nullable error) {
					if (error) {
						[self showAlertWithTitle:@"Login Error" andMessage:error.localizedDescription];
						[self enableResendCodeButton];
						self.verifyingCode = NO;
					} else {
						if (self.creatingAccount) {
							//todo: enter name
							//						[user setObject:self.verbatmName forKey:VERBATM_USER_NAME_KEY];
							[user setObject:[NSNumber numberWithBool:NO] forKey:USER_FTUE];
							[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
								if(succeeded) {
                                    [self goOnToCreateName];
								}
							}];
						} else {
                            
                            if(![[UserSetupParameters sharedInstance] checkOnboardingShown]){
                                NSString * userName = user[VERBATM_USER_NAME_KEY];
                                if(userName && userName.length){
                                    //go to onboarding adk
                                    [self performSegueWithIdentifier:SEGUE_ONBOARD_FROM_ENTER_CODE sender:self];
                                }else{
                                    [self goOnToCreateName];
                                }
                                
                            }else{
                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGIN_SUCCEEDED object:[PFUser currentUser]];
                                [self performSegueWithIdentifier:UNWIND_SEGUE_PHONE_LOGIN_TO_MASTER sender:self];
                            }
						}
					}
				}];
			}
		}];
	}
}

-(void) showAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
	UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:title message:message
																preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction * action) {}];
	[newAlert addAction:defaultAction];
	[self presentViewController:newAlert animated:YES completion:nil];
}

-(NSString*) getCode {
	NSString *code = [self.digitOneField.text stringByAppendingString:
					  [self.digitTwoField.text stringByAppendingString:
					   [self.digitThreeField.text stringByAppendingString:self.digitFourField.text]]];
	return code;
}

-(void) showWrongCode {
	[self enableResendCodeButton];
	self.verifyingCode = NO;
	//todo:
	[self setTextColor: [UIColor redColor] andShakeView:YES];
}

-(void) setTextColor:(UIColor*)color andShakeView:(BOOL)shake {
	for (NSInteger tag = 1; tag <= 4; tag++) {
		UITextField *field = [self.view viewWithTag: tag];
		field.textColor = color;
		[field addBottomBorderWithColor:color andWidth:2.f];
		if (shake) {
			[field shake];
		}
	}
}

-(void) resendCodeButtonPressed {
	[self sendCodeToUser: self.simplePhoneNumber];
}

#pragma mark - Login Keyboard toolbar delegate -

-(void) nextButtonPressed {
	[self verifyCode];
}

#pragma mark - Text field delegate -

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (textField.textColor == [UIColor redColor]) {
		[self setTextColor:[UIColor whiteColor] andShakeView:NO];
	}
	// Inputting value - add it then set next responder
	if (textField.text.length < 2  && string.length > 0) {
		NSInteger nextTag = textField.tag + 1;

		UITextField *nextResponder = [textField.superview viewWithTag:nextTag];
		if (nextTag == 5) {
			nextResponder = self.digitOneField;
		}
		textField.text = string;
		if (textField.tag == 4) {
			[self verifyCode];
		} else {
			[nextResponder becomeFirstResponder];
		}
		return NO;
	}
	// Deleting value -
	else if (string.length == 0) {

		NSInteger previousTag = textField.tag - 1;
		// get next responder
		UITextField *previousResponder = [textField.superview viewWithTag:previousTag];
		if (previousTag < 1) {
			previousResponder = self.digitOneField;
		}
		[previousResponder becomeFirstResponder];
		if (textField.text.length >= 1) {
			textField.text = ZERO_WIDTH_CHARACTER;
		} else {
			previousResponder.text = ZERO_WIDTH_CHARACTER;
		}
		return NO;
	}
	return YES;
}

#pragma mark - Next

#pragma mark - Lazy Instantiation -

-(UITextField*) digitOneField {
	if (!_digitOneField) {
		CGFloat xPos = (self.view.frame.size.width - (CODE_TEXT_FIELD_WIDTH*4 + CODE_SPACING*3))/2.f;
		_digitOneField = [self singleDigitTextFieldWithXPos:xPos];
		_digitOneField.tag = 1;
	}
	return _digitOneField;
}

-(UITextField*) digitTwoField {
	if (!_digitTwoField) {
		CGFloat xPos = self.digitOneField.frame.origin.x + CODE_TEXT_FIELD_WIDTH + CODE_SPACING;
		_digitTwoField = [self singleDigitTextFieldWithXPos:xPos];
		_digitTwoField.tag = 2;
	}
	return _digitTwoField;
}

-(UITextField*) digitThreeField {
	if (!_digitThreeField) {
		CGFloat xPos = self.digitTwoField.frame.origin.x + CODE_TEXT_FIELD_WIDTH + CODE_SPACING;
		_digitThreeField = [self singleDigitTextFieldWithXPos:xPos];
		_digitThreeField.tag = 3;
	}
	return _digitThreeField;
}

-(UITextField*) digitFourField {
	if (!_digitFourField) {
		CGFloat xPos = self.digitThreeField.frame.origin.x + CODE_TEXT_FIELD_WIDTH + CODE_SPACING;
		_digitFourField = [self singleDigitTextFieldWithXPos:xPos];
		_digitFourField.tag = 4;
	}
	return _digitFourField;
}

-(UITextField*) singleDigitTextFieldWithXPos:(CGFloat)xPos {
	CGRect frame = CGRectMake(xPos, CODE_TEXT_FIELD_Y_OFFSET, CODE_TEXT_FIELD_WIDTH, CODE_TEXT_FIELD_WIDTH);
	UITextField *textField = [[UITextField alloc] initWithFrame: frame];
	textField.delegate = self;
	textField.textColor = [UIColor whiteColor];
	textField.textAlignment = NSTextAlignmentCenter;
	textField.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.2];
	textField.font = [UIFont fontWithName:BOLD_FONT size:40.f]; //todo
	[textField addBottomBorderWithColor:[UIColor whiteColor] andWidth:2.f];
	textField.keyboardType = UIKeyboardTypeNumberPad;
	textField.text = ZERO_WIDTH_CHARACTER;

	CGRect toolBarFrame = CGRectMake(0, self.view.frame.size.height - LOGIN_TOOLBAR_HEIGHT,
									 self.view.frame.size.width, LOGIN_TOOLBAR_HEIGHT);
	LoginKeyboardToolBar *toolbar = [[LoginKeyboardToolBar alloc] initWithFrame:toolBarFrame];
	toolbar.delegate = self;
	[toolbar setNextButtonText:@"Next"];
	textField.inputAccessoryView = toolbar;

	return textField;
}

-(UILabel*) codeSentToNumberLabel {
	if (!_codeSentToNumberLabel) {
		CGFloat xPos = 20.f; //todo
		CGRect frame = CGRectMake(xPos, self.digitOneField.frame.origin.y + self.digitOneField.frame.size.height + VERTICAL_SPACING,
								  self.view.frame.size.width - xPos*2, 50.f);
		_codeSentToNumberLabel = [[UILabel alloc] initWithFrame:frame];
		_codeSentToNumberLabel.textColor = [UIColor whiteColor];
		_codeSentToNumberLabel.font = [UIFont fontWithName:REGULAR_FONT size:14.f]; //todo
		_codeSentToNumberLabel.textAlignment = NSTextAlignmentCenter;
		_codeSentToNumberLabel.text = @"Enter the code sent to +1 ";
		_codeSentToNumberLabel.text = [_codeSentToNumberLabel.text stringByAppendingString: self.phoneNumber];
	}
	return _codeSentToNumberLabel;
}

-(UIButton*) resendCodeButton {
	if (!_resendCodeButton) {
		CGFloat xPos = self.view.frame.size.width/2.f - RESEND_CODE_BUTTON_WIDTH/2.f;
		CGFloat yPos = self.codeSentToNumberLabel.frame.origin.y + self.codeSentToNumberLabel.frame.size.height + VERTICAL_SPACING;
		CGRect frame = CGRectMake(xPos, yPos,
								  RESEND_CODE_BUTTON_WIDTH, RESEND_CODE_BUTTON_HEIGHT);
		_resendCodeButton = [[UIButton alloc] initWithFrame:frame];
		_resendCodeButton.layer.cornerRadius = 5.f;
//		_resendCodeButton.layer.borderColor = [UIColor whiteColor].CGColor;
//		_resendCodeButton.layer.borderWidth = 1.f;
//		_resendCodeButton.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.2];
		[_resendCodeButton addTarget:self action:@selector(resendCodeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _resendCodeButton;
}

@end
