//
//  CustomScrollingTabBar.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/3/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomScrollingTabBarDelegate <NSObject>

-(void) tabPressedWithTitle:(NSString*) title;

@end

@interface CustomScrollingTabBar : UIScrollView

@property (strong, nonatomic) id<CustomScrollingTabBarDelegate> customScrollingTabBarDelegate;


// array of NSString*
-(void) displayTabs: (NSArray*) tabTitles;

@end
