//
//  profileVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//


#import "ProfileVC.h"
#import "profileNavBar.h"
#import "SizesAndPositions.h"
#import "GTLVerbatmAppVerbatmUser.h"
#import "UserManager.h"
@interface ProfileVC()

@property (nonatomic, strong) profileNavBar * profileNavBar;
@property (weak, nonatomic) GTLVerbatmAppVerbatmUser* currentUser;
@end

@implementation ProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
	
    NSArray * testThreads = @[@"Parties", @"Selfies", @"The Diaspora"];
    [self createNavigationBarWithThreads:testThreads];
    
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}



-(void) createNavigationBarWithThreads:(NSArray *) threads {
    CGRect navBarFrame = CGRectMake(0.f, 0.f, self.view.frame.size.width, CUSTOM_NAV_BAR_HEIGHT*2);
    [self updateUserInfo];
    self.profileNavBar = [[profileNavBar alloc] initWithFrame:navBarFrame andThreads:threads andUserName:self.currentUser.name];
    
}

-(void) updateUserInfo {
    self.currentUser = [[UserManager sharedInstance] getCurrentUser];
}

@end
