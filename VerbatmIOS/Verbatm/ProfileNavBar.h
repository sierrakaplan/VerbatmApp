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
-(void) followOptionSelected;//current user selected to follow a channel


-(void) followersOptionSelected;//current user wants to see their own followers
-(void) followingOptionSelected;//current user wants to see who they follow

-(void) settingsButtonClicked;
-(void) newChannelSelected:(Channel *) channel;
-(void) createNewChannel;//notifies view to prompt user to create new channel

-(void)exitCurrentProfile;//the current user has selected the back button

@end

@interface ProfileNavBar : UIView



@property (nonatomic, strong) id<ProfileNavBarDelegate> delegate;

-(instancetype) initWithFrame:(CGRect)frame andChannels:(NSArray *)channels startChannel:(Channel *) startChannel andUser:(PFUser *)profileUser isCurrentLoggedInUser:(BOOL) isCurrentUser;

-(void) selectChannel: (Channel*) channel;
-(void)newChannelCreated: (Channel *) channel;

@end
