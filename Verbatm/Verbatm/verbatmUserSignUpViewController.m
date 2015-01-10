//
//  verbatmUserSignUpViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 12/27/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmUserSignUpViewController.h"
#import "VerbatmUser.h"
@interface verbatmUserSignUpViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *UserName_TextField;
@property (weak, nonatomic) IBOutlet UITextField *Password_TextField;
@property (weak, nonatomic) IBOutlet UITextField *FirstName_TextField;
@property (weak, nonatomic) IBOutlet UITextField *LastName_TextField;
@property (weak, nonatomic) IBOutlet UITextField *Email_TextField;
@property (weak, nonatomic) IBOutlet UITextField *PhoneNumber_TextField;

#define Number_of_Fields 6
#define SINGUP_SUCCEEDED_NOTIFICATION @"userSignedIn"
#define SINGUP_FAILED_NOTIFIACTION @"userFailedToSignIn"
@end

@implementation verbatmUserSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.UserName_TextField setDelegate:self];
    [self.FirstName_TextField setDelegate:self];
    [self.LastName_TextField setDelegate:self];
    [self.Password_TextField setDelegate:self];
    [self.Email_TextField setDelegate:self];
    [self.PhoneNumber_TextField setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//Iain
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.UserName_TextField resignFirstResponder];
    [self.FirstName_TextField resignFirstResponder];
    [self.LastName_TextField resignFirstResponder];
    [self.Password_TextField resignFirstResponder];
    [self.Email_TextField resignFirstResponder];
    [self.PhoneNumber_TextField resignFirstResponder];
    return YES;
}

//signs up the user to parse
- (IBAction)signUpUser:(UIButton *)sender
{
    //make sure all the textfields are entered in correctly
    if([self.UserName_TextField.text isEqualToString:@""]) return;
    if([self.FirstName_TextField.text isEqualToString:@""])return;
    if([self.LastName_TextField.text isEqualToString:@""])return;
    if([self.Password_TextField.text isEqualToString:@""])return;
    if([self.Email_TextField.text isEqualToString:@""])return;
    if([self.PhoneNumber_TextField.text isEqualToString:@""])return;
    
    
    VerbatmUser * newUser = [[VerbatmUser alloc] initWithUserName:self.UserName_TextField.text FirstName:self.FirstName_TextField.text LastName:self.LastName_TextField.text Email:self.Email_TextField.text PhoneNumber:[NSNumber numberWithInteger:self.PhoneNumber_TextField.text.integerValue ] Password:self.Password_TextField.text  withSignUpCompletionBlock:^(BOOL succeeded, NSError *error)
    
    {
        if(succeeded)
        {
            //Send a notification that the user is logged in 
            NSNotification * notification = [[NSNotification alloc]initWithName:SINGUP_SUCCEEDED_NOTIFICATION object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
            
        }else if (!succeeded)
        {
            //Send a notification that the user failed to log in
            NSLog(error);
            
            NSNotification * notification = [[NSNotification alloc]initWithName:SINGUP_FAILED_NOTIFIACTION object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
        
    }];
    
    
    
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
