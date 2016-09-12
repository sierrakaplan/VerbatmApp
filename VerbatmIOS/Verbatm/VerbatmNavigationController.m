//
//  VerbatmNavigationController.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "UIImage+ImageEffectsAndTransforms.h"
#import "Styles.h"
#import "VerbatmNavigationController.h"

@implementation VerbatmNavigationController

-(void) viewDidLoad {
	[self formatNavigationBar];
	[self setNavigationBarHidden:YES animated:NO];
	[self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
}

-(void) setNavigationBarHidden:(BOOL)navigationBarHidden {
	[super setNavigationBarHidden: navigationBarHidden];
}

-(void) formatNavigationBar {
	[self setNavigationBarBackgroundColor:[UIColor blackColor]];
	[self setNavigationBarTextColor:[UIColor whiteColor]];
}

-(void) setNavigationBarBackgroundClear {
	self.navigationBar.translucent = YES;
}

-(void) setNavigationBarBackgroundColor:(UIColor*)backgroundColor {
	self.navigationBar.translucent = NO;
	self.navigationBar.barTintColor = backgroundColor;
}

-(void) setNavigationBarShadowColor:(UIColor*)shadowColor {
	if (shadowColor == [UIColor clearColor]) {
		self.navigationBar.shadowImage = [UIImage new];
	} else {
		UIImage *shadowImage = [UIImage makeImageWithColorAndSize:shadowColor andSize:CGSizeMake(1, 1)];
		self.navigationBar.shadowImage = shadowImage;
	}
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
