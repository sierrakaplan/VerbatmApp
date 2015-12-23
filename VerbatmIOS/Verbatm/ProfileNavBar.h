//
//  profileNavBar.h
//  Verbatm
//
//  Created by Iain Usiri on 11/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ProfileNavBarDelegate <NSObject>

-(void) settingsButtonClicked;
-(void) newChannelSelectedWithName:(NSString *) channelName;

@end

@interface ProfileNavBar : UIView

#define PROFILE_HEADER_HEIGHT 70.f
#define THREAD_SCROLLVIEW_HEIGHT 40.f
#define PROFILE_NAV_BAR_HEIGHT (PROFILE_HEADER_HEIGHT + THREAD_SCROLLVIEW_HEIGHT)

@property (nonatomic, strong) id<ProfileNavBarDelegate> delegate;

-(instancetype) initWithFrame:(CGRect)frame andThreads:(NSArray *)threads andUserName:(NSString *)userName;

@end
