//
//  profileNavBar.h
//  Verbatm
//
//  Created by Iain Usiri on 11/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SizesAndPositions.h"
@protocol ProfileNavBarDelegate <NSObject>
-(void) followOptionSelected;//current user selected to follow a channel


-(void) followersOptionSelected;//current user wants to see their own followers
-(void) followingOptionSelected;//current user wants to see who they follow

-(void) settingsButtonClicked;
-(void) newChannelSelectedWithName:(NSString *) channelName;
-(void) createNewChannel;//notifies view to prompt user to create new channel

-(void)exitCurrentProfile;//the current user has selected the back button

@end

@interface ProfileNavBar : UIView



@property (nonatomic, strong) id<ProfileNavBarDelegate> delegate;

-(instancetype) initWithFrame:(CGRect)frame andChannels:(NSArray *)threads andUserName:(NSString *)userName isCurrentLoggedInUser:(BOOL) isCurrentUser;

@end
