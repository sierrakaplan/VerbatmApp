//
//  SettingsVC.m
//  Verbatm
//
//  Created by Iain Usiri on 1/5/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "CustomNavigationBar.h"
#import "User_BackendObject.h"
#import <MessageUI/MessageUI.h>
#import "TermsAndConditionsVC.h"

#import "SizesAndPositions.h"
#import "SettingsVC.h"
#import "Styles.h"

#import "UserManager.h"

@interface SettingsVC () <CustomNavigationBarDelegate,
MFMailComposeViewControllerDelegate,UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UIButton *contactUsButton;
@property (weak, nonatomic) IBOutlet UIButton *termsAndConditionsButton;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UIImageView *profileIconImage;

@property (nonatomic) CustomNavigationBar * navigationBar;

#define VIEW_OFFSET_Y 50.f
#define PROFILE_ICON_WALL_OFFSET 15.f //distance of profile picture from left wall
#define PROFILE_TEXTFILED_GAP 10.f //distance between the profile icon and the textField
#define VERBATM_HELP_EMAIL @"founders@verbatm.io"
#define HELP_EMAIL_SUBJECT @"Feedback to Verbatm team"
@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createNavigationBar];
    [self positionButtonViews];
}

-(BOOL) prefersStatusBarHidden {
	return YES;
}

-(void)createNavigationBar{
    CGRect navBarFrame = CGRectMake(0.f, 0.f, self.view.frame.size.width, CUSTOM_NAV_BAR_HEIGHT);
    self.navigationBar = [[CustomNavigationBar alloc] initWithFrame:navBarFrame andBackgroundColor:SETTINGS_NAV_BAR_COLOR];
    self.navigationBar.delegate = self;
    
    [self.navigationBar createLeftButtonWithTitle:@"BACK" orImage:nil];
    
    [self.navigationBar createRightButtonWithTitle:@"SAVE" orImage:nil];
    
    [self.view addSubview:self.navigationBar];
}

-(void) positionButtonViews{
    
    CGRect userNameFieldFrame = CGRectMake(PROFILE_ICON_WALL_OFFSET +
                                           self.profileIconImage.frame.size.width +
                                           PROFILE_TEXTFILED_GAP, CUSTOM_NAV_BAR_HEIGHT +
                                  VIEW_OFFSET_Y, self.view.frame.size.width -
                                           (self.profileIconImage.frame.size.width + PROFILE_ICON_WALL_OFFSET*2 +
                                            PROFILE_TEXTFILED_GAP),
                                           self.userNameField.frame.size.height);
    
    self.userNameField.frame = userNameFieldFrame;
    self.userNameField.returnKeyType = UIReturnKeyDone;
    self.userNameField.delegate = self;
    
    if(self.userName){
        self.userNameField.text = self.userName;
    }
    
    
    CGFloat profileIconWidth = self.profileIconImage.frame.size.width;
    CGFloat profileIconHeight = profileIconWidth * (47.f/35.f);

    CGRect profileIconFrame = CGRectMake(PROFILE_ICON_WALL_OFFSET,self.userNameField.center.y - (profileIconHeight/2.f) , profileIconWidth, profileIconHeight);
    
    self.profileIconImage.frame = profileIconFrame;

	CGRect signOutButtonFrame = CGRectMake(0.f, profileIconFrame.origin.y +
										   profileIconFrame.size.height + VIEW_OFFSET_Y , self.view.frame.size.width, self.contactUsButton.frame.size.height);

    CGRect termsAndCondButtonFrame = CGRectMake(0.f, signOutButtonFrame.origin.y +
                                             signOutButtonFrame.size.height + VIEW_OFFSET_Y , self.view.frame.size.width, self.termsAndConditionsButton.frame.size.height);

	CGRect contactUsButtonFrame = CGRectMake(0.f, termsAndCondButtonFrame.origin.y +
											 termsAndCondButtonFrame.size.height + VIEW_OFFSET_Y , self.view.frame.size.width, self.signOutButton.frame.size.height);


    
    
    self.contactUsButton.frame= contactUsButtonFrame;
    self.termsAndConditionsButton.frame = termsAndCondButtonFrame;
    self.signOutButton.frame = signOutButtonFrame;
}

//when the user is done editing their name then they can remove the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

//user selected cancel so remove settings view
-(void) leftButtonPressed{
    [self exitSettingsPageWithCompletionBlock:nil];
}

//user selected done. Save their changes and exit view
-(void) rightButtonPressed {
    //save changes made by user to username
    [User_BackendObject updateUserNameOfCurrentUserTo:self.userNameField.text];
    [self exitSettingsPageWithCompletionBlock:nil];
}


-(void)exitSettingsPageWithCompletionBlock:(void(^)())block{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            if(block)block();
    }];
}


- (IBAction)signOutButtonSelected:(id)sender {
    //sign out functionality -- not sure what this should be
    [self exitSettingsPageWithCompletionBlock:^{
        [[UserManager sharedInstance] logOutUser];
    }];
}





#pragma mark -seding email functionality-

- (IBAction)contactUsButtonSelected:(id)sender {
    
    [self presentEmailViewController];
}


-(void)presentEmailViewController {
    NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
    NSString *model = [[UIDevice currentDevice] model];
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setToRecipients:[NSArray arrayWithObjects:VERBATM_HELP_EMAIL,nil]];
    [mailComposer setSubject:HELP_EMAIL_SUBJECT];
    NSString *supportText = [NSString stringWithFormat:@"Device: %@\niOS Version:%@\n\n",model,iOSVersion];
    supportText = [supportText stringByAppendingString: @"Please give us feedback or describe your problem. \n Thank you!"];
    [mailComposer setMessageBody:supportText isHTML:NO];
    [self presentViewController:mailComposer animated:YES completion:nil];

}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    UIViewController * vc = [segue destinationViewController];
    if([vc isKindOfClass:[TermsAndConditionsVC class]]){
        ((TermsAndConditionsVC *)vc).userMustAcceptTerms = NO;
    }
}


@end
