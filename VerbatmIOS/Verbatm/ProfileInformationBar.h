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
    -(void)followButtonSelected;
    -(void)backButtonSelected;
@end

@interface ProfileInformationBar : UIView
    -(instancetype)initWithFrame:(CGRect)frame andUserName: (NSString *) userName isCurrentUser:(BOOL) isCurrentUser;
    @property (nonatomic) id <ProfileInformationBarProtocol> delegate;
@end
