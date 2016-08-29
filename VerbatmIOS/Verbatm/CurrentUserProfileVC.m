//
//  CurrentUserProfileVC.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/29/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "CurrentUserProfileVC.h"
#import "Icons.h"
#import "SettingsVC.h"
#import "VerbatmNavigationController.h"

@implementation CurrentUserProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
	[self.navigationController setNavigationBarHidden:NO];
	[(VerbatmNavigationController*)self.navigationController setNavigationBarStyleClearWithTextColor:[UIColor whiteColor]];
	[self setNavigationItem];
}

-(void) setNavigationItem {
	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:SETTINGS_BUTTON_ICON]
																	   style:UIBarButtonItemStylePlain target:self
																	  action:@selector(settingsButtonPressed)];
	self.navigationItem.rightBarButtonItem = settingsButton;
}

-(void) settingsButtonPressed {
	SettingsVC *settingsVC = [[SettingsVC alloc] init];
	[self.navigationController pushViewController:settingsVC animated:YES];
}

@end
