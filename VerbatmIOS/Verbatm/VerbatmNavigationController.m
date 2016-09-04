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
	[self setNavigationBarBackgroundColor:[UIColor blackColor]];
	[self setNavigationBarTextColor:[UIColor whiteColor]];
}

-(void) setNavigationBarBackgroundClear {
	[self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
	self.navigationBar.shadowImage = [UIImage new];
	self.navigationBar.translucent = YES;
}

-(void) setNavigationBarBackgroundColor:(UIColor*)backgroundColor {
	self.navigationBar.translucent = NO;
	self.navigationBar.barTintColor = backgroundColor;
}

-(void) setNavigationBarTextColor: (UIColor*)textColor {
	self.navigationBar.tintColor = textColor;
	[self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
												textColor, NSForegroundColorAttributeName,
												[UIFont fontWithName:BOLD_FONT size:21.0], NSFontAttributeName, nil]];
}

- (UIViewController *)childViewControllerForStatusBarHidden {
	return self.visibleViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
	return self.visibleViewController;
}

@end
