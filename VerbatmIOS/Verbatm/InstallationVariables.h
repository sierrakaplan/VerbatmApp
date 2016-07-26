//
//  InstallationVariables.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//
//  A class storing global variables having to do with the state of the app
// 	on open (whether opened from a push notification, etc.)

#import <Foundation/Foundation.h>

@interface InstallationVariables : NSObject

@property (nonatomic) BOOL launchedFromNotification;

+ (InstallationVariables *)sharedInstance;

@end
