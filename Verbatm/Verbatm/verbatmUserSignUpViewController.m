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
@property (weak, nonatomic) IBOutlet UILabel *verbatmTitle_label;
@property (weak, nonatomic) IBOutlet UIButton *signUp_button;


#define Number_of_Fields 2
#define SINGUP_SUCCEEDED_NOTIFICATION @"userSignedIn"
#define SINGUP_FAILED_NOTIFIACTION @"userFailedToSignIn"
@end

@implementation verbatmUserSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.UserName_TextField setDelegate:self];
    [self.Password_TextField setDelegate:self];
    [self centerAllframes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//dynamically centers all our frames depending on phone screen dimensions
-(void) centerAllframes
{
    self.verbatmTitle_label.frame = CGRectMake((self.view.frame.size.width/2 - self.verbatmTitle_label.frame.size.width/2), self.verbatmTitle_label.frame.origin.y, self.verbatmTitle_label.frame.size.width, self.verbatmTitle_label.frame.size.height);
    
    self.signUp_button.frame =CGRectMake((self.view.frame.size.width/2 - self.signUp_button.frame.size.width/2), self.signUp_button.frame.origin.y, self.signUp_button.frame.size.width, self.signUp_button.frame.size.height);
    
    self.signUp_button.frame= CGRectMake((self.view.frame.size.width/2 - self.signUp_button.frame.size.width/2), self.signUp_button.frame.origin.y, self.signUp_button.frame.size.width, self.signUp_button.frame.size.height);
    
    CGRect textViewFrame = CGRectMake((self.view.frame.size.width/2 - self.UserName_TextField.frame.size.width/2), self.UserName_TextField.frame.origin.y, self.UserName_TextField.frame.size.width, self.UserName_TextField.frame.size.height);
    
//    textViewFrame.size.height = getContentSize(self.UserName_TextField);
//    textViewFrame.size = [self.UserName_TextField sizeThatFits:CGSizeMake(self.UserName_TextField.frame.size.width, FLT_MAX)];
    
    self.UserName_TextField.frame= textViewFrame;
    
    self.UserName_TextField.tintColor = [UIColor colorWithRed:98.0/255.0f green:98.0/255.0f blue:98.0/255.0f alpha:1.0];
    
    self.Password_TextField.frame = CGRectMake((self.view.frame.size.width/2 - self.Password_TextField.frame.size.width/2), self.Password_TextField.frame.origin.y, self.Password_TextField.frame.size.width, self.Password_TextField.frame.size.height);
    
    self.Password_TextField.tintColor = [UIColor colorWithRed:98.0/255.0f green:98.0/255.0f blue:98.0/255.0f alpha:1.0];
}

-(CGSize) getContentSize:(UITextView*) myTextView{
    return [myTextView sizeThatFits:CGSizeMake(myTextView.frame.size.width, FLT_MAX)];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.UserName_TextField resignFirstResponder];
    [self.Password_TextField resignFirstResponder];
    return YES;
}

//signs up the user to parse
- (IBAction)signUpUser:(UIButton *)sender
{
    //make sure all the textfields are entered in correctly
    if([self.UserName_TextField.text isEqualToString:@""]) return;
    if([self.Password_TextField.text isEqualToString:@""])return;

    VerbatmUser * newUser = [[VerbatmUser alloc] initWithUserName:self.UserName_TextField.text Password:self.Password_TextField.text  withSignUpCompletionBlock:^(BOOL succeeded, NSError *error)
    
    {
        if(succeeded)
        {
            //Send a notification that the user is logged in 
            NSNotification * notification = [[NSNotification alloc]initWithName:SINGUP_SUCCEEDED_NOTIFICATION object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
            
        }else if (!succeeded)
        {
            
            NSNotification * notification = [[NSNotification alloc]initWithName:SINGUP_FAILED_NOTIFIACTION object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
        
    }];
}


#pragma mark Orientation
- (NSUInteger)supportedInterfaceOrientations
{
    //return supported orientation masks
    return UIInterfaceOrientationMaskPortrait;
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
