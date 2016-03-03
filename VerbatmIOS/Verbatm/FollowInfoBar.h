//
//  followInfoBar.h
//  Verbatm
//
//  Created by Iain Usiri on 1/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//


/*
 Presents two buttons one to show followers and the other to show who you're following
 */

#import <UIKit/UIKit.h>


@protocol FollowInfoBarDelegate <NSObject>

//present the people that follow the current user and the specific channels
-(void)showWhoIsFollowingMeSelected;

//show the people that I am following 
-(void)showWhoIAmFollowingButtonSelected;

@end

@interface FollowInfoBar : UIView

-(void) setNumFollowers: (NSNumber*) numFollowers;
-(void) setNumFollowing: (NSNumber*) numFollowing;

@property (nonatomic) id<FollowInfoBarDelegate> delegate;

@end
