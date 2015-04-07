//
//  verbatmUserLoginViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 12/27/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmUserLoginViewController.h"
#import "VerbatmUser.h"

@interface verbatmUserLoginViewController () <UITextFieldDelegate>
#define SINGUP_SUCCEEDED_NOTIFICATION @"userSignedIn"
#define SINGUP_FAILED_NOTIFIACTION @"userFailedToSignIn"
#define TOAST_DURATION 1
@property (weak, nonatomic) IBOutlet UITextField *UserName_TextField;
@property (weak, nonatomic) IBOutlet UITextField *Password_TextField;
@end

@implementation verbatmUserLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //signup for a notification that tells you the user 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signUpSuccesful:) name:SINGUP_SUCCEEDED_NOTIFICATION object: nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signUpFailed:) name:SINGUP_FAILED_NOTIFIACTION object: nil];
    self.UserName_TextField.delegate = self;
    self.Password_TextField.delegate = self;
    //if the user is logged in then lets get outta here!
    if([VerbatmUser userIsLoggedIn]) [self performSegueWithIdentifier:@"bringUpADK" sender:self];
}

//Iain
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.UserName_TextField resignFirstResponder];
    [self.Password_TextField resignFirstResponder];
    return YES;
}

//not that the signup was succesful - post a notiication
-(void) signUpSuccesful: (NSNotification *) notification
{
    NSLog(@"Signup Succeeded");

}

//not that the signup was succesful - post a notiication
-(void) signUpFailed: (NSNotification *) notification
{
    NSLog(@"SignUp failed");

}

- (IBAction)login:(UIButton *)sender
{
    [VerbatmUser logInWithUsername:self.UserName_TextField.text password:self.Password_TextField.text];
    
    [VerbatmUser loginUserWithUserName:self.UserName_TextField.text andPassword:self.Password_TextField.text withCompletionBlock:^(PFUser *user, NSError *error) {
       
        if(user)
        {
            //should only call this segue if the user is logged in
            [self performSegueWithIdentifier:@"bringUpADK" sender:self];
        }else
        {
            NSLog(@"Login failed");
        }
    }];
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

#pragma mark Orientation
- (NSUInteger)supportedInterfaceOrientations
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
