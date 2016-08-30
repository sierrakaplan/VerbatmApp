//
//  VerbatmNavigationController.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Styles.h"
#import "VerbatmNavigationController.h"

@implementation VerbatmNavigationController

-(void) viewDidLoad {
	[self formatNavigationBar];
	[self setNavigationBarHidden:YES animated:NO];
}

-(void) setNavigationBarHidden:(BOOL)navigationBarHidden {
	[super setNavigationBarHidden: navigationBarHidden];
}

-(void) formatNavigationBar {
	//	[self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
	//	self.navigationController.navigationBar.shadowImage = [UIImage new];
	//	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationController.navigationBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:NAVIGATION_BAR_HEIGHT]];

	self.navigationBar.translucent = NO;
	self.navigationBar.barTintColor = [UIColor blackColor];
	self.navigationBar.tintColor = [UIColor whiteColor];
	[self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
																	 [UIColor whiteColor], NSForegroundColorAttributeName,
																	 [UIFont fontWithName:BOLD_FONT size:21.0], NSFontAttributeName, nil]];
}

-(void) setNavigationBarStyleClearWithTextColor: (UIColor*)textColor {
	[self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
	self.navigationBar.shadowImage = [UIImage new];
	self.navigationBar.translucent = YES;
	self.navigationBar.tintColor = textColor;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
	return self.visibleViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
	return self.visibleViewController;
}

@end
