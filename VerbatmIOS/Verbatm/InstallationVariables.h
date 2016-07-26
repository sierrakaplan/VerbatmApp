//
//  InstallationVariables.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstallationVariables : NSObject

@property (nonatomic) BOOL launchedFromNotification;

+ (InstallationVariables *)sharedInstance;

@end
