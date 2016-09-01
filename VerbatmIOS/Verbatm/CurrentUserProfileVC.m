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
#import "ProfileHeaderView.h"
#import "SettingsVC.h"
#import "VerbatmNavigationController.h"
#import "StoryboardVCIdentifiers.h"

#import "VerbatmNavigationController.h"

@interface CurrentUserProfileVC() <ProfileHeaderViewDelegate>

#define SETTINGS_BUTTON_SIZE 24.f

@end

@implementation CurrentUserProfileVC

-(void) viewDidLoad {
	[super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear: animated];
	[(VerbatmNavigationController*)self.navigationController setNavigationBarTextColor:[UIColor blackColor]];
}

-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

-(void) setNavigationItem {
}

-(void) headerViewTapped {
	[super headerViewTapped];
}

-(void) moreInfoButtonTapped {
	[super moreInfoButtonTapped];
}

-(void) addCoverPhotoButtonTapped {
	//todo:
}

-(void) settingsButtonTapped {
	SettingsVC *settingsVC = [self.storyboard instantiateViewControllerWithIdentifier:SETTINGS_VC_ID];
	[self.navigationController pushViewController:settingsVC animated:YES];
}

@end
