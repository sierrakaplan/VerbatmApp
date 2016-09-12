//
//  SettingsVC.m
//  Verbatm
//
//  Created by Iain Usiri on 1/5/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "CustomNavigationBar.h"

#import <MessageUI/MessageUI.h>

#import "Notifications.h"

#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>

#import "SizesAndPositions.h"
#import "SegueIDs.h"
#import "SettingsVC.h"
#import "Styles.h"
#import "TermsAndConditionsVC.h"


#import "User_BackendObject.h"
#import "UserInfoCache.h"
#import "UserManager.h"

@interface SettingsVC () <MFMailComposeViewControllerDelegate, UITableViewDelegate,
UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;
@property (weak, nonatomic) IBOutlet UILabel *termsAndConditionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *signOutLabel;

@property (nonatomic) NSString *oldUsername;

#define FONT_SIZE 16.f
#define X_POS 5.f

#define USER_NAME_CHAR_LIMIT 30
#define VERBATM_HELP_EMAIL @"feedback@verbatm.io"
#define HELP_EMAIL_SUBJECT @"Feedback to Verbatm team"

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
	self.userNameTextField.font = [UIFont fontWithName:ITALIC_FONT size:FONT_SIZE];
	self.userNameTextField.text = [PFUser currentUser][VERBATM_USER_NAME_KEY];
	self.userNameTextField.delegate = self;
	self.userNameTextField.returnKeyType = UIReturnKeyDone;
	self.feedbackLabel.font = [UIFont fontWithName:REGULAR_FONT size:FONT_SIZE];
	self.termsAndConditionsLabel.font = [UIFont fontWithName:REGULAR_FONT size:FONT_SIZE];
	self.signOutLabel.font = [UIFont fontWithName:BOLD_FONT size:FONT_SIZE];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}

-(BOOL) prefersStatusBarHidden {
	return NO;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 1) {
		if (row == 0) {
			[self sendFeedback];
		} else {
			[self showTermsAndConditions];
		}
	} else if (section == 2 && row == 0) {
		[self logoutAlert];
	}
}

#pragma mark - Editing text field -

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSUInteger newLength = [textField.text length] + [string length] - range.length;
	if (newLength < textField.text.length) {
		return YES;
	}
	return newLength <= USER_NAME_CHAR_LIMIT;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField {
	self.oldUsername = textField.text;
}

-(void) textFieldDidEndEditing:(UITextField *)textField {
	if (textField.text.length < 1) {
		textField.text = self.oldUsername;
		return;
	}
	//todo: this should be atomic
	NSString *newUserName = textField.text;    
    [User_BackendObject updateUserNameOfCurrentUserTo:newUserName];

}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

#pragma mark - Send Feedback -

-(void) sendFeedback {
	[self presentEmailViewController];
}

-(void)presentEmailViewController {
    NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
    NSString *model = [[UIDevice currentDevice] model];
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setToRecipients:[NSArray arrayWithObjects:VERBATM_HELP_EMAIL, nil]];
    [mailComposer setSubject:HELP_EMAIL_SUBJECT];
    NSString *supportText = [NSString stringWithFormat:@"Device: %@\niOS Version:%@\n\n",model,iOSVersion];
    supportText = [supportText stringByAppendingString: @"Please give us feedback or describe your problem. \n Thank you!"];
    [mailComposer setMessageBody:supportText isHTML:NO];
    [self presentViewController:mailComposer animated:YES completion:nil];

}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Terms and Conditions -

-(void) showTermsAndConditions {
	[self performSegueWithIdentifier:SEGUE_TERMS_AND_CONDITIONS_FROM_SETTINGS sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

#pragma mark - Logging Out -

-(void) logoutAlert {
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
																   message:nil
															preferredStyle:UIAlertControllerStyleActionSheet];

	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction * action) {}];
	UIAlertAction* logoutAction = [UIAlertAction actionWithTitle:@"Log Out" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		[self logout];
	}];

	[alert addAction: cancelAction];
	[alert addAction: logoutAction];
	[self presentViewController:alert animated:YES completion:nil];

}

-(void) logout {
	[[UserManager sharedInstance] logOutUser];
}
@end
