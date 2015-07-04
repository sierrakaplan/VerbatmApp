//
//  verbatmUserLoginViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 12/27/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmUserLoginViewController.h"
#import "verbatmUserSignUpViewController.h"
#import "VerbatmUser.h"

@interface verbatmUserLoginViewController () <UITextFieldDelegate>
#define SINGUP_FAILED_NOTIFIACTION @"userFailedToSignIn"
#define TOAST_DURATION 1
#define SINGUP_SUCCEEDED_NOTIFICATION @"userSignedIn"

@property (weak, nonatomic) IBOutlet UITextField *UserName_TextField;
@property (weak, nonatomic) IBOutlet UITextField *Password_TextField;
@property (weak, nonatomic) IBOutlet UILabel *verbatmTitle_label;

@property (weak, nonatomic) IBOutlet UIButton *signIn_button;
@property (weak, nonatomic) IBOutlet UIButton *signUp_button;
@end

@implementation verbatmUserLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signUpFailed:) name:SINGUP_FAILED_NOTIFIACTION object: nil];
    self.UserName_TextField.delegate = self;
    self.Password_TextField.delegate = self;
    [self centerAllframes];
    [self showCursor];
    [self changeReturnButton];
    
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

-(void) showCursor
{
    self.UserName_TextField.tintColor = [UIColor colorWithRed:98.0/255.0f green:98.0/255.0f blue:98.0/255.0f alpha:1.0];
    
    self.Password_TextField.tintColor = [UIColor colorWithRed:98.0/255.0f green:98.0/255.0f blue:98.0/255.0f alpha:1.0];
    
}

-(void) changeReturnButton
{
    [self.UserName_TextField setReturnKeyType:UIReturnKeyNext];
    [self.Password_TextField setReturnKeyType:UIReturnKeyDone];
}

// Enter button presses login
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.UserName_TextField) {
        [self.Password_TextField becomeFirstResponder];
        return YES;
    }
    if (textField == self.Password_TextField) {
        //        [self signUpUser:self.signUp_button];
        [self.Password_TextField resignFirstResponder];
        return YES;
    }
    return NO;
}


- (IBAction)login:(UIButton *)sender
{
    [VerbatmUser loginUserWithUserName:self.UserName_TextField.text andPassword:self.Password_TextField.text withCompletionBlock:^(PFUser *user, NSError *error) {
       
        if(user)
        {
            [self.presentingViewController dismissViewControllerAnimated:NO completion:^{
                return;
            }];
             
             
             [[NSNotificationCenter defaultCenter] postNotificationName:SINGUP_SUCCEEDED_NOTIFICATION
                                                                object:nil
                                                              userInfo:nil];
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
