//
//  UserInfoVC.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/24/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoVC : UIViewController

@property (weak, nonatomic) NSString *phoneNumber;
@property (nonatomic) BOOL firstTimeLoggingIn;
@property (nonatomic) BOOL successfullyLoggedIn;

@end
