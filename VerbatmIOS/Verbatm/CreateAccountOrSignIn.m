//
//  CreateAccountOrSignIn.m
//  Verbatm
//
//  Created by Iain Usiri on 9/11/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "CreateAccountOrSignIn.h"

@interface CreateAccountOrSignIn ()
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation CreateAccountOrSignIn

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setButtonFrame];
}


-(void)setButtonFrame {
    self.createAccountButton.frame = CGRectMake((self.view.frame.size.width/2) - (self.createAccountButton.frame.size.width/2) , self.createAccountButton.frame.origin.y, self.createAccountButton.frame.size.width, self.createAccountButton.frame.size.height);
    
    self.signInButton.frame = CGRectMake((self.view.frame.size.width/2) - (self.signInButton.frame.size.width/2) , self.signInButton.frame.origin.y, self.signInButton.frame.size.width, self.signInButton.frame.size.height);
}


////catches the unwind segue - popout again to the master view
//- (IBAction)done:(UIStoryboardSegue *)segue {
//    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
//    }];
//}

@end
