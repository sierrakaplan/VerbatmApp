//
//  profileVC.h
//  Verbatm
//
//  Created by Iain Usiri on 8/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileVCDelegate <NSObject>

-(void) showTabBar: (BOOL) show;

@end

@interface ProfileVC : UIViewController

@property (strong, nonatomic) id<ProfileVCDelegate> delegate;

-(void) updateUserInfo;

@end
