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

@property (nonatomic) Channel * currentChannel;

// array of NSString*
-(void) displayTabs: (NSArray*) channels withStartChannel:(Channel *) channel isLoggedInUser:(BOOL) isLoggedInUser;
-(void) addNewChannelToList:(Channel *) channel;
-(void) selectChannel: (Channel*) channel;

@end
