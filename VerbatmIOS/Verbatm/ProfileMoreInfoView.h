//
//  ProfileMoreInfoView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/29/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//
//	This class shows more information about a profile, including the followers and following lists
//	and description.

#import <UIKit/UIKit.h>

@protocol ProfileMoreInfoViewDelegate <NSObject>

-(void) followingButtonPressed;
-(void) followersButtonPressed;

-(void) followChannel:(BOOL)follow;
-(void) blockButtonPressed;

@end

@interface ProfileMoreInfoView : UIView

@property (nonatomic, weak) id<ProfileMoreInfoViewDelegate> delegate;

-(instancetype) initWithFrame:(CGRect)frame andChannel:(Channel*)channel
		 isCurrentUserProfile:(BOOL)currentUserProfile;

@end
