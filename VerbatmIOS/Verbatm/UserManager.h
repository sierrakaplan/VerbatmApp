//
//  UserManager.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/25/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/PFUser.h>
#import <Parse/PFQuery.h>
#import <ParseFacebookutilsV4/PFFacebookUtils.h>
#import <PromiseKit/PromiseKit.h>

@class GTLVerbatmAppVerbatmUser;
@class PovInfo;

@interface UserManager : NSObject

+ (UserManager *)sharedInstance;

//-(void) signUpUserFromEmail: (NSString*)email andName: (NSString*)name
//				andPassword: (NSString*)password andPhoneNumber: (NSString*) phoneNumber;

-(void) signUpOrLoginUserFromFacebookToken: (FBSDKAccessToken*) accessToken;

-(void) logOutUser;

@end
