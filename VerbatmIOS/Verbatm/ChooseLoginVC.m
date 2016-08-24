//
//  ChooseLoginVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/23/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//


#import "ChooseLoginVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface ChooseLoginVC()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) FBSDKLoginButton *loginButton;
@property (nonatomic) UITextField *phoneLoginField;

#define PHONE_FIELD_WIDTH 200.f
#define PHONE_FIELD_HEIGHT 50.f

@end

@implementation ChooseLoginVC

-(void) viewDidLoad {
	[super viewDidLoad];
	self.navigationController.navigationBar.hidden = YES;
	[self.backgroundImageView setFrame: self.view.bounds];
}

#pragma mark - Lazy Instantiation -

-(UITextField*) phoneLoginField {
	if (!_phoneLoginField) {
		CGRect frame = CGRectMake(0.f, 0.f, PHONE_FIELD_WIDTH, PHONE_FIELD_HEIGHT);
		_phoneLoginField = [[UITextField alloc] initWithFrame: frame];
		_phoneLoginField.
	}
	return _phoneLoginField;
}

@end
