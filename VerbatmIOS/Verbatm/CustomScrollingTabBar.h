//
//  CustomScrollingTabBar.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 12/3/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"

@protocol CustomScrollingTabBarDelegate <NSObject>

-(void) tabPressedWithChannel:(Channel*) title;
-(void) createNewChannel;//notifies view to prompt user to create new channel

@end

@interface CustomScrollingTabBar : UIScrollView

@property (strong, nonatomic) id<CustomScrollingTabBarDelegate> customScrollingTabBarDelegate;


// array of NSString*
-(void) displayTabs: (NSArray*) tabTitles;
-(void)addNewChannelToList:(Channel *) channel;
@end
