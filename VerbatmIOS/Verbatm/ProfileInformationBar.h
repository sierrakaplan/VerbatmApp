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
-(void)blockCurrentUserShouldBlock:(BOOL) shouldBlock;

@end

@interface ProfileInformationBar : UIView

@property (nonatomic, weak) id <ProfileInformationBarProtocol> delegate;
@property (nonatomic) BOOL hasBlockedUser;

-(instancetype)initWithFrame:(CGRect)frame andUserName: (NSString *) userName
			   isCurrentUser:(BOOL) isCurrentUser isBlockedByCurrentUser:(BOOL) isBlocked
				isProfileTab: (BOOL)profileTab;

@end
