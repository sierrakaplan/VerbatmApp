//
//  UserManager.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/25/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "Notifications.h"
#import "ParseBackendKeys.h"
#import "ProfileVC.h"
#import "UserManager.h"

@interface UserManager()

@end

@implementation UserManager

+ (UserManager *)sharedInstance {
	static UserManager *_sharedInstance = nil;
	static dispatch_once_t onceSecurePredicate;
	dispatch_once(&onceSecurePredicate,^{
		_sharedInstance = [[self alloc] init];
	});

	return _sharedInstance;
}


#pragma mark - Creating Account (Signing up user) -

-(void) signUpOrLoginUserFromFacebookToken:(FBSDKAccessToken *)accessToken {
	[PFFacebookUtils logInInBackgroundWithAccessToken:[FBSDKAccessToken currentAccessToken] block:^(PFUser * _Nullable user, NSError * _Nullable error) {
		if (error) {
			[self notifyFailedLogin: error];
			return;
		} else {
			if (user.isNew) {
				[self getUserInfoFromFacebookToken: accessToken];
			} else {
				NSLog(@"User had already created account. Successfully logged in with Facebook.");
                [self notifySuccessfulLogin];
			}
		}
	}];
}

-(void)updateCurrentUserWithName:(NSString *) name andEmail:(NSString *) email{
    // update current user
    PFUser* currentUser = [PFUser currentUser];
    //we don't set the username because that's set by facebook.
    if(email)currentUser.email = email;
    if(name)[currentUser setObject: name forKey:VERBATM_USER_NAME_KEY];
    [currentUser setObject:[NSNumber numberWithBool:NO] forKey:USER_FTUE];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error) {
            [[Crashlytics sharedInstance] recordError:error];
        }
    }];
}

// Starts request query for a fb user's name, email, picture, and friends.
// Assumes the accessToken has been checked somewhere else
- (void) getUserInfoFromFacebookToken: (FBSDKAccessToken*) accessToken {

	FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
	NSDictionary* userFields =  [NSDictionary dictionaryWithObject: @"id,name,email,picture,friends" forKey:@"fields"];
	FBSDKGraphRequest *requestMe = [[FBSDKGraphRequest alloc]
									initWithGraphPath:@"me" parameters:userFields];
	[connection addRequest:requestMe
		 completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
			 if (!error) {

				 NSString* name = result[@"name"];
				 NSString* email = result[@"email"];
                 
                 if(email){
                            PFQuery *query = [PFUser query];
                            [query whereKey:@"email" equalTo: email];
                            [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                                if (!error && object) {
                                    // delete the user created by fb login
                                    [[PFUser currentUser] deleteInBackground];
                                    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
                                    [loginManager logOut];
                                    NSError* accountWithEmailExistsError = [NSError errorWithDomain:@"world" code: kPFErrorUserEmailTaken userInfo:nil];
                                    [self notifyFailedLogin: accountWithEmailExistsError];
                                } else {
                                    [self updateCurrentUserWithName:name andEmail:email];

            //						NSString* pictureURL = result[@"picture"][@"data"][@"url"];
            //						NSLog(@"profile picture url: %@", pictureURL);

                                    //will only show friends who have signed up for the app with fb
                                    NSArray* friends = nil;
                                    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"user_friends"]) {
                                        //friends = result[@"friends"][@"data"];
                                    }
                                    
                                    [self notifySuccessfulLogin];
                                    
                                }
                                
                            }];
                 }else if(name){
                     [self updateCurrentUserWithName:name andEmail:email];
                 }
			 } else {
				 [[PFUser currentUser] deleteInBackground];
				 [self notifyFailedLogin: error];
			 }
		 }];
	[connection start];
}


#pragma mark - Log user out -

-(void) logOutUser {
	[PFUser logOutInBackground];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_SIGNED_OUT object:nil];
}

#pragma mark - Notifications -

-(void) notifySuccessfulLogin {
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGIN_SUCCEEDED object:[PFUser currentUser]];
}

-(void) notifyFailedLogin: (NSError*) error {
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGIN_FAILED object:error];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
