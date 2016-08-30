//
//  CurrentUserProfileVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/29/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "CurrentUserProfileVC.h"
#import "Icons.h"
#import "ParseBackendKeys.h"
#import "SettingsVC.h"
#import "VerbatmNavigationController.h"
#import "StoryboardVCIdentifiers.h"

@interface CurrentUserProfileVC()

#define SETTINGS_BUTTON_SIZE 24.f

@end

@implementation CurrentUserProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear: animated];
	[self setNavigationItem];
	[self.navigationController setNavigationBarHidden:NO];
	[(VerbatmNavigationController*)self.navigationController setNavigationBarBackgroundClear];
	[(VerbatmNavigationController*)self.navigationController setNavigationBarTextColor:[UIColor whiteColor]];
}

-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.navigationItem.rightBarButtonItem = nil;
}

-(void) setNavigationItem {
	UIButton *settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, SETTINGS_BUTTON_SIZE,
																		  SETTINGS_BUTTON_SIZE)];
	settingsButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[settingsButton setImage:[UIImage imageNamed:SETTINGS_BUTTON_ICON] forState:UIControlStateNormal];
	[settingsButton addTarget:self action:@selector(settingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *settingsBarButton = [[UIBarButtonItem alloc] initWithCustomView: settingsButton];
	self.navigationItem.rightBarButtonItem = settingsBarButton;
}

-(void) settingsButtonPressed {
	SettingsVC *settingsVC = [self.storyboard instantiateViewControllerWithIdentifier:SETTINGS_VC_ID];
	settingsVC.userName  = [[PFUser currentUser] valueForKey:VERBATM_USER_NAME_KEY];
	[self.navigationController pushViewController:settingsVC animated:YES];
}

@end
