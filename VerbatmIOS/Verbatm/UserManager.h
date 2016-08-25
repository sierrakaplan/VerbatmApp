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

+(void) setFbId;

-(void) signUpOrLoginUserFromFacebookToken: (FBSDKAccessToken*) accessToken;

-(void) logOutUser;
-(BOOL) shouldRequestForUserFeedback;

-(void) holdCurrentCoverPhoto:(UIImage *)coverPhoto;

-(UIImage*) getCurrentCoverPhoto;

@end
