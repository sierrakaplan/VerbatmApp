//
//  profileNavBar.h
//  Verbatm
//
//  Created by Iain Usiri on 11/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "Channel.h"
#import <Parse/PFUser.h>
#import "SizesAndPositions.h"
#import <UIKit/UIKit.h>

@protocol ProfileNavBarDelegate <NSObject>

-(void) settingsButtonClicked;
-(void) newChannelSelected:(Channel *) channel;
-(void) createNewChannel;

-(void) exitCurrentProfile;
-(void) blockCurrentUserShouldBlock:(BOOL) shouldBlock;

@end

@interface ProfileNavBar : UIView

@property (nonatomic, strong) id<ProfileNavBarDelegate> delegate;

-(instancetype) initWithFrame:(CGRect)frame andChannels:(NSArray *)channels
					  andUser:(PFUser *)profileUser isCurrentLoggedInUser:(BOOL) isCurrentUser
				 isProfileTab:(BOOL) profileTab;

-(void) selectChannel: (Channel*) channel;
-(void) newChannelCreated: (Channel *) channel;

-(void )updateUserIsBlocked:(BOOL)blocked;

@end
