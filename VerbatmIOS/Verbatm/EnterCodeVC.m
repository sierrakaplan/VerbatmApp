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
#import "UtilityFunctions.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "UIView+Effects.h"

@interface EnterCodeVC() <UITextFieldDelegate, LoginKeyboardToolBarDelegate>

@property (nonatomic) NSString *simplePhoneNumber;

@property (nonatomic) UITextField *digitOneField;
@property (nonatomic) UITextField *digitTwoField;
@property (nonatomic) UITextField *digitThreeField;
@property (nonatomic) UITextField *digitFourField;

@property (nonatomic) UILabel *codeSentToNumberLabel;

@property (nonatomic) UIButton *resendCodeButton;

#define CODE_TEXT_FIELD_Y_OFFSET 100.f
#define CODE_TEXT_FIELD_WIDTH 50.f
#define CODE_SPACING 10.f
#define VERTICAL_SPACING 10.f
#define ZERO_WIDTH_CHARACTER @"\u200B"

#define RESEND_CODE_BUTTON_WIDTH 200.f
#define RESEND_CODE_BUTTON_HEIGHT 100.f

@end

@implementation EnterCodeVC

-(void) viewDidLoad {
	self.simplePhoneNumber = [UtilityFunctions removeAllNonNumbersFromString: self.phoneNumber];
	[self sendCodeToUser: self.simplePhoneNumber];
	[self.view addSubview: self.digitOneField];
	[self.view addSubview: self.digitTwoField];
	[self.view addSubview: self.digitThreeField];
	[self.view addSubview: self.digitFourField];
	[self.view addSubview: self.codeSentToNumberLabel];
	[self.view addSubview: self.resendCodeButton];
	[self.digitOneField becomeFirstResponder];
	[self formatNavigationBar];
}

-(BOOL) prefersStatusBarHidden {
	return YES;
}

-(void) formatNavigationBar {
	self.navigationItem.title = @"Verify phone number";
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
}

-(void) sendCodeToUser:(NSString*) simplePhoneNumber {
	//todo: show sending code
	//todo: include more languages
	NSDictionary *params = @{@"phoneNumber" : simplePhoneNumber, @"language" : @"en"};
	[PFCloud callFunctionInBackground:@"sendCode" withParameters:params block:^(id  _Nullable response, NSError * _Nullable error) {
		if (error) {
			[[Crashlytics sharedInstance] recordError: error];
//			[self showAlertWithTitle:@"Error sending code" andMessage:@"Something went wrong. Please verify your phone number is correct."];
		} else {
			//			self.createdUserWithLoginCode = YES;
			// Parse has now created an account with this phone number and generated a random code,
			// user must enter the correct code to be logged in
		}
	}];
	
}

-(void) verifyCode {
	NSString *code = [self getCode];
	code = [UtilityFunctions removeAllNonNumbersFromString: code];
	if (code.length != 4) {
		[self showWrongCode];
	} else {
		//todo: verify code
	}
}

-(NSString*) getCode {
	NSString *code = [self.digitOneField.text stringByAppendingString:
					  [self.digitTwoField.text stringByAppendingString:
					   [self.digitThreeField.text stringByAppendingString:self.digitFourField.text]]];
	return code;
}

-(void) showWrongCode {
	//todo:
	[self setTextColor: [UIColor redColor]];

}

-(void) setTextColor:(UIColor*)color {
	for (NSInteger tag = 1; tag <= 4; tag++) {
		UITextField *field = [self.view viewWithTag: tag];
		field.textColor = color;
		field.layer.borderColor = color.CGColor;
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
		[self setTextColor:[UIColor blackColor]];
	}
	// Inputting value - add it then set next responder
	if (textField.text.length < 2  && string.length > 0) {
		NSInteger nextTag = textField.tag + 1;

		UITextField *nextResponder = [textField.superview viewWithTag:nextTag];
		if (nextResponder == nil) {
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
		if (previousResponder == nil) {
			previousResponder = self.digitOneField;
		}
		[previousResponder becomeFirstResponder];
		previousResponder.text = ZERO_WIDTH_CHARACTER;
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
	textField.textAlignment = NSTextAlignmentCenter;
	textField.backgroundColor = [UIColor whiteColor];
	textField.font = [UIFont fontWithName:BOLD_FONT size:40.f]; //todo
	[textField addBottomBorderWithColor:[UIColor blackColor] andWidth:2.f];
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
		CGFloat xPos = 50.f; //todo
		CGRect frame = CGRectMake(xPos, self.digitOneField.frame.origin.y + self.digitOneField.frame.size.height + VERTICAL_SPACING,
								  self.view.frame.size.width - xPos*2, 50.f);
		_codeSentToNumberLabel = [[UILabel alloc] initWithFrame:frame];
		_codeSentToNumberLabel.font = [UIFont fontWithName:REGULAR_FONT size:18.f]; //todo
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
		_resendCodeButton.layer.borderColor = [UIColor blackColor].CGColor;
		_resendCodeButton.layer.borderWidth = 1.f;
		NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
										  NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:20.f]}; //todo
		NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"Resend code" attributes:titleAttributes];
		[_resendCodeButton setAttributedTitle:attributedTitle forState: UIControlStateNormal];
		[_resendCodeButton addTarget:self action:@selector(resendCodeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _resendCodeButton;
}

@end
