//
//  CreateAccount.m
//  Verbatm
//
//  Created by Iain Usiri on 9/11/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "CreateAccount.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@interface CreateAccount ()<FBSDKLoginButtonDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *fullnameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;

#define FACEBOOK_BUTTON_YOFFSET 40 //distance of facebook button from bottom of view above it

@end

@implementation CreateAccount

-(void)viewDidLoad{
    [super viewDidLoad];
    if(self){
        [self setFieldFrame];
        [self setDelegates];
        [self addFacebookLoginButton];
    }
}

-(void)setDelegates {
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    self.fullnameField.delegate = self;
    self.phoneNumberField.delegate = self;
}

-(void)setFieldFrame{
    
    self.emailField.frame = CGRectMake((self.view.frame.size.width/2) - (self.emailField.frame.size.width/2) , self.emailField.frame.origin.y, self.emailField.frame.size.width, self.emailField.frame.size.height);
     self.fullnameField.frame = CGRectMake((self.view.frame.size.width/2) - (self.fullnameField.frame.size.width/2) , self.fullnameField.frame.origin.y, self.fullnameField.frame.size.width, self.fullnameField.frame.size.height);
     self.passwordField.frame = CGRectMake((self.view.frame.size.width/2) - (self.passwordField.frame.size.width/2) , self.passwordField.frame.origin.y, self.passwordField.frame.size.width, self.passwordField.frame.size.height);
     self.phoneNumberField.frame = CGRectMake((self.view.frame.size.width/2) - (self.phoneNumberField.frame.size.width/2) , self.phoneNumberField.frame.origin.y, self.phoneNumberField.frame.size.width, self.phoneNumberField.frame.size.height);
     self.orLabel.frame = CGRectMake((self.view.frame.size.width/2) - (self.orLabel.frame.size.width/2) , self.orLabel.frame.origin.y, self.orLabel.frame.size.width, self.orLabel.frame.size.height);
    
}

- (void) addFacebookLoginButton {
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    float buttonWidth = loginButton.frame.size.width*1.5;
    float buttonHeight = loginButton.frame.size.height*1.5;
    loginButton.frame = CGRectMake(self.view.center.x - buttonWidth/2, self.orLabel.frame.origin.y + self.orLabel.frame.size.height +FACEBOOK_BUTTON_YOFFSET, buttonWidth, buttonHeight);
    loginButton.delegate = self;
    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    [self.view addSubview:loginButton];
}


//we add a sign up button to the screen if the user doesn't sign in with FB
-(void)replaceWithSignUpButton {
    //this button replaces the or label so make sure
    //it's on the screen
    if(!self.orLabel)return;
    UIButton * signInButton = [[UIButton alloc]init];
    [signInButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    float buttonWidth  = self.fullnameField.frame.size.width;
    float buttonX = self.view.center.x - buttonWidth/2;
    float buttonY = self.orLabel.frame.origin.y;
    float buttonHeight = self.fullnameField.frame.size.height;
    signInButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    signInButton.backgroundColor = [UIColor lightGrayColor];
    [signInButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [signInButton addTarget:self action:@selector(completeAccountCreation) forControlEvents:UIControlEventTouchUpInside];
    [self.orLabel removeFromSuperview];
    [self.view addSubview:signInButton];
}

//called when the user is done inputing their information
//and the content is accepted
-(void)completeAccountCreation {
    /*To do*/
    if(self.emailField.text.length >0 &&
       self.phoneNumberField.text.length >0 &&
       self.passwordField.text.length >0 &&
       self.fullnameField.text.length >0) {
        /*Do some login stuff */
        /*removes the current VC by going two layers deep */
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        }];
    }else{
        /*Give them some sort of prompt
         for what's missing
         */
        
    }
    
}


#pragma mark - delegates -
- (void)textFieldDidBeginEditing:(UITextField *)textField {
 
    [self replaceWithSignUpButton];
    
}

@end
