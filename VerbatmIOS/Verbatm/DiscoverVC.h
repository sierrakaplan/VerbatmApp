//
//  FeaturedContentVC.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OnboardingBlogsDelegate <NSObject>

//todo: better way to do this
//Lets parent know that there are friends to present
-(void) followingFriends;

@end


@interface DiscoverVC : UITableViewController

@property (nonatomic) BOOL onboardingBlogSelection;
@property (nonatomic, weak) id<OnboardingBlogsDelegate> onboardingDelegate;

@end
