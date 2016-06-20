//
//  CustomTabBarController.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/4/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "CustomTabBarController.h"

@implementation CustomTabBarController

- (void)viewWillLayoutSubviews {
	CGRect tabFrame = self.tabBar.frame;
	tabFrame.size.height = self.tabBarHeight ? self.tabBarHeight : 80;
	tabFrame.origin.y = self.view.frame.size.height - tabFrame.size.height;
	self.tabBar.frame = tabFrame;
}

@end
