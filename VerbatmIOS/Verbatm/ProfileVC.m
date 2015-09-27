//
//  profileVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "GTLVerbatmAppVerbatmUser.h"

#import "ProfileVC.h"

#import "UserManager.h"

@interface ProfileVC() <UserManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (strong, nonatomic) UserManager* userManager;

@end

@implementation ProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
	[self updateUserInfo];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void) updateUserInfo {
	[self.userManager getCurrentUser];
}


#pragma mark - User Manager Delegate Methods -

-(void) successfullyRetrievedCurrentUser:(GTLVerbatmAppVerbatmUser *)user {
	self.userNameLabel.text = user.name;
}

-(void) errorRetrievingCurrentUser:(NSError *)error {

}

#pragma mark - Lazy Instantiation -

-(UserManager*) userManager {
	if (!_userManager) _userManager = [[UserManager alloc] init];
	_userManager.delegate = self;
	return _userManager;
}

@end
