//
//  CreateNameVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/25/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "CreateNameVC.h"

#import "LoginKeyboardToolBar.h"

#import "Notifications.h"

#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>

#import "SegueIDs.h"
#import "SizesAndPositions.h"
#import "Styles.h"

#import "UserInfoCache.h"

@interface CreateNameVC() <LoginKeyboardToolBarDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic) UILabel *enterNameLabel;
@property (nonatomic) UITextField *enterNameField;
@property (nonatomic) BOOL savingName;

@property (nonatomic) UIActivityIndicatorView *loadingIndicator;

#define ENTER_NAME_LABEL_Y_POS 100.f
#define ENTER_NAME_FIELD_Y_POS 200.f

#define ENTER_NAME_FIELD_WIDTH 200.f
#define ENTER_NAME_FIELD_HEIGHT 50.f

#define ENTER_NAME_LABEL_WIDTH 270.f
#define ENTER_NAME_LABEL_HEIGHT 50.f

#define MAX_LENGTH_NAME 20

@end

@implementation CreateNameVC

-(void) viewDidLoad {
	[super viewDidLoad];
	self.savingName = NO;
	self.backgroundImageView.frame = self.view.bounds;
	[self.view addSubview: self.enterNameField];
	[self.view addSubview: self.enterNameLabel];
	[self.view sendSubviewToBack: self.backgroundImageView];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear: animated];
	[self.enterNameField becomeFirstResponder];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES];
}

-(BOOL) prefersStatusBarHidden {
	return YES;
}

-(void) nextButtonPressed {
	NSString *name = self.enterNameField.text;
	if (name.length < 1) {
		[self showAlertWithTitle:nil andMessage:@"Enter your name."];
	} else {
		if (self.savingName) return;
        [self.loadingIndicator startAnimating];
		self.savingName = YES;
		//todo: show loading
		[PFUser currentUser][VERBATM_USER_NAME_KEY] = name;
		[[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
			if (!succeeded || error) {
				self.savingName = NO;
				//todo: error handling?
                [self.loadingIndicator stopAnimating];
			} else {
				[[UserInfoCache sharedInstance] loadUserChannelWithCompletionBlock:^{
					Channel *channel = [[UserInfoCache sharedInstance] getUserChannel];
					channel.parseChannelObject[CHANNEL_CREATOR_NAME_KEY] = name;
					[channel.parseChannelObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        [self.loadingIndicator stopAnimating];
						if (!succeeded || error) {
							self.savingName = NO;
						} else {
							[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGIN_SUCCEEDED object:[PFUser currentUser]];
							[self performSegueWithIdentifier:SEGUE_FOLLOW_FRIENDS sender:self];
						}
					}];
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

#pragma mark - Text field delegate -

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (textField == self.enterNameField) {
		NSInteger length = textField.text.length + string.length - range.length;
		if (length > MAX_LENGTH_NAME) {
			return NO;
		}
		return YES;
	}
	return YES;
}

#pragma mark - Lazy Instantiation -

-(UITextField*) enterNameField {
	if (!_enterNameField) {
		CGRect frame = CGRectMake(self.view.center.x - ENTER_NAME_FIELD_WIDTH/2.f, ENTER_NAME_FIELD_Y_POS,
								  ENTER_NAME_FIELD_WIDTH, ENTER_NAME_FIELD_HEIGHT);
		_enterNameField = [[UITextField alloc] initWithFrame: frame];
		_enterNameField.backgroundColor = [UIColor whiteColor];
		_enterNameField.layer.borderColor = [UIColor blackColor].CGColor;
		_enterNameField.layer.borderWidth = 1.f;
		_enterNameField.font = [UIFont fontWithName:REGULAR_FONT size:24.f]; //todo:
		_enterNameField.layer.cornerRadius = 5.f;
		_enterNameField.layer.sublayerTransform = CATransform3DMakeTranslation(20.f, 0, 0);
		_enterNameField.keyboardType = UIKeyboardTypeAlphabet;
		_enterNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		_enterNameField.placeholder = @"Veronica Mars";
		_enterNameField.delegate = self;

		CGRect toolBarFrame = CGRectMake(0, self.view.frame.size.height - LOGIN_TOOLBAR_HEIGHT,
										 self.view.frame.size.width, LOGIN_TOOLBAR_HEIGHT);
		LoginKeyboardToolBar *toolbar = [[LoginKeyboardToolBar alloc] initWithFrame:toolBarFrame];
		toolbar.delegate = self;
		[toolbar setNextButtonText:@"Next"];
		_enterNameField.inputAccessoryView = toolbar;
	}
	return _enterNameField;
}


-(UIActivityIndicatorView *) loadingIndicator {
    if(!_loadingIndicator) {
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
        CGFloat yPos = self.enterNameField.frame.origin.y + self.enterNameField.frame.size.height + _loadingIndicator.frame.size.height +  5.f;
        _loadingIndicator.center = CGPointMake(self.view.frame.size.width/2.f, yPos);
        _loadingIndicator.hidesWhenStopped = YES;
        [self.view addSubview:_loadingIndicator];
    }
    return _loadingIndicator;
}

-(UILabel*) enterNameLabel {
	if(!_enterNameLabel) {
		CGRect frame = CGRectMake(self.view.center.x - ENTER_NAME_LABEL_WIDTH/2.f, ENTER_NAME_LABEL_Y_POS,
								  ENTER_NAME_LABEL_WIDTH, ENTER_NAME_LABEL_HEIGHT);
		_enterNameLabel = [[UILabel alloc] initWithFrame:frame];
		_enterNameLabel.text = @"Enter your name!";
		_enterNameLabel.textAlignment = NSTextAlignmentCenter;
		[_enterNameLabel setBackgroundColor:[UIColor clearColor]];
		[_enterNameLabel setTextColor:[UIColor whiteColor]];
		[_enterNameLabel setFont:[UIFont fontWithName:REGULAR_FONT size:20.f]]; //todo

	}
	return _enterNameLabel;
}

@end
