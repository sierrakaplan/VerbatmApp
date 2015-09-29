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

@class GTLVerbatmAppVerbatmUser;

@protocol UserManagerDelegate <NSObject>

-(void) successfullyLoggedInUser: (GTLVerbatmAppVerbatmUser*) user;
-(void) errorLoggingInUser: (NSError*) error;

@end

@interface UserManager : NSObject

@property (strong, nonatomic) id<UserManagerDelegate> delegate;

+ (UserManager *)sharedInstance;

-(void) signUpUserFromEmail: (NSString*)email andName: (NSString*)name
				andPassword: (NSString*)password andPhoneNumber: (NSString*) phoneNumber;

-(void) signUpOrLoginUserFromFacebookToken: (FBSDKAccessToken*) accessToken;

-(void) loginUserFromEmail: (NSString*)email andPassword:(NSString*)password;

-(GTLVerbatmAppVerbatmUser*) getCurrentUser;

-(void) logOutUser;

//TODO:
-(void) changeUserProfilePhoto: (UIImage*) image;

@end
