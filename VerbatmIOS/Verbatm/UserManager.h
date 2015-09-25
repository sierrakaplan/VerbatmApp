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
#import <ParseFacebookutilsV4/PFFacebookUtils.h>

@class GTLVerbatmAppVerbatmUser;

@protocol UserManagerDelegate <NSObject>

-(void) successfullySignedUpUser: (GTLVerbatmAppVerbatmUser*) user;
-(void) errorSigningUpUser: (NSError*) error;

@end

@interface UserManager : NSObject

@property (strong, nonatomic) id<UserManagerDelegate> delegate;

-(void) signUpUserFromEmail: (NSString*)email andName: (NSString*)name
				andPassword: (NSString*)password andPhoneNumber: (NSString*) phoneNumber;

-(void) signUpUserFromFacebookToken: (FBSDKAccessToken*) accessToken;

//TODO:
-(void) getCurrentUser;

//TODO:
-(void) changeUserProfilePhoto;

@end
