//
//  EnterCodeVC.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/23/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//
//	This class handles sending a code to the user's phone number,
// 	the user entering the number and confirming it. 

#import <UIKit/UIKit.h>

@interface EnterCodeVC : UIViewController

@property (nonatomic) BOOL creatingAccount;
@property (nonatomic) NSString *phoneNumber;

@end
