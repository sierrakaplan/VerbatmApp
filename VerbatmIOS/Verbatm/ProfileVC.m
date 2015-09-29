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

@interface ProfileVC()

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *underConstructionLabel;

@property (strong, nonatomic) UserManager* userManager;

@end

@implementation ProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
	[self updateUserInfo];
    [self setLabelFrames];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void) setLabelFrames{
    
    self.userNameLabel.frame = CGRectMake(self.view.center.x - (self.userNameLabel.frame.size.width/2), self.userNameLabel.frame.origin.y, self.userNameLabel.frame.size.width,
                                          self.userNameLabel.frame.size.height);
    
    self.underConstructionLabel.frame = CGRectMake(self.view.center.x - (self.underConstructionLabel.frame.size.width/2),
                                                   self.underConstructionLabel.frame.origin.y,
                                                   self.underConstructionLabel.frame.size.width, self.underConstructionLabel.frame.size.height);
}

-(void) updateUserInfo {
	GTLVerbatmAppVerbatmUser* currentUser = [self.userManager getCurrentUser];
	self.userNameLabel.text = currentUser.name;
}

#pragma mark - Lazy Instantiation -

-(UserManager*) userManager {
	if (!_userManager) _userManager = [UserManager sharedInstance];
	return _userManager;
}

@end
