//
//  CustomTabBarItem.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 10/28/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "CustomTabBarItem.h"
#import "Styles.h"

@interface CustomTabBarItem()
@property (nonatomic, strong) UIView* view;
@end

@implementation CustomTabBarItem

- (void)setSelected:(BOOL)selected {
	if (selected) {
		self.view.backgroundColor = [UIColor SELECTED_TAB_BAR_COLOR];
	} else {
		self.view.backgroundColor = [UIColor clearColor];
	}
}

@end
