//
//  profileNavBar.h
//  Verbatm
//
//  Created by Iain Usiri on 11/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ProfileNavBarDelegate <NSObject>

-(void)newChannelSelectedWithName:(NSString *) channelName;

@end

@interface ProfileNavBar : UIView

@property (nonatomic, strong) id<ProfileNavBarDelegate> delegate;
-(instancetype) initWithFrame:(CGRect)frame andThreads:(NSArray *) threads andUserName:(NSString *) userName;

@end


