//
//  profileInformationBar.h
//  Verbatm
//
//  Created by Iain Usiri on 12/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 This is the view that presents the username as well as the settings button on the 
 Profile screen
 */

@protocol ProfileInformationBarProtocol <NSObject>
    -(void)settingsButtonSelected;
    -(void)followButtonSelectedShouldFollowUser:(BOOL) followUser;
    -(void)backButtonSelected;
@end

@interface ProfileInformationBar : UIView
    -(instancetype)initWithFrame:(CGRect)frame andUserName: (NSString *) userName isCurrentUser:(BOOL) isCurrentUser;
    //makes the follow button show that we are/aren't following the current channel being presented
    -(void)setFollowIconToFollowingCurrentChannel:(BOOL) isFollowingChannel;
    @property (nonatomic) id <ProfileInformationBarProtocol> delegate;
@end
