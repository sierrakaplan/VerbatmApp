//
//  PermissionCodePageVC.m
//  Verbatm
//
//  Created by Iain Usiri on 9/28/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "PermissionCodePageVC.h"
#import "UserSetupParameters.h"

@interface PermissionCodePageVC () <UITextFieldDelegate>
    @property (weak, nonatomic) IBOutlet UITextField *fieldEntry;
    @property (weak, nonatomic) IBOutlet UIImageView *logo;


#define FIELD_Y_OFFSET_FROM_LOGO 100
#define ACCESS_CODE @"5591"

@end

@implementation PermissionCodePageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.logo.frame = CGRectMake(self.view.center.x - (self.logo.frame.size.width/2), self.logo.frame.origin.y,
                                 self.logo.frame.size.width, self.logo.frame.size.height);
    
    self.fieldEntry.frame = CGRectMake(self.view.center.x - (self.fieldEntry.frame.size.width/2),
                                       self.logo.frame.origin.y + self.logo.frame.size.height + FIELD_Y_OFFSET_FROM_LOGO,
                                       self.fieldEntry.frame.size.width, self.fieldEntry.frame.size.height);
    
    self.fieldEntry.delegate = self;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if([textField.text isEqualToString:ACCESS_CODE]){
        //segue
        [textField resignFirstResponder];
        [UserSetupParameters set_accessCodeAsEntered];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

        return YES;
    }
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Wrong Access Code. Please Try Again." message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
    
    return NO;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
