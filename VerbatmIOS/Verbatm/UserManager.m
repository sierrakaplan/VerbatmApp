//
//  UserManager.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/25/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "GTLQueryVerbatmApp.h"
#import "GTLServiceVerbatmApp.h"
#import "GTLVerbatmAppVerbatmUser.h"
#import "GTMHTTPFetcherLogging.h"

#import "UserManager.h"

@interface UserManager()

@property(nonatomic, strong) GTLServiceVerbatmApp *service;

@end

@implementation UserManager


#pragma mark - Creating Account (Signing up user) -

-(void) signUpUserFromEmail: (NSString*)email andName: (NSString*)name
				andPassword: (NSString*)password andPhoneNumber: (NSString*) phoneNumber {

	PFUser* newUser = [[PFUser alloc] init];
	// TODO: send confirmation email (must be unique)
	newUser.username = email;
	newUser.email = email;
	newUser.password = password;

	[newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
		if(succeeded) {
			GTLVerbatmAppVerbatmUser* verbatmUser = [GTLVerbatmAppVerbatmUser alloc];
			verbatmUser.name = name;
			verbatmUser.email = email;
			if (phoneNumber.length) {
				verbatmUser.phoneNumber = phoneNumber;
			}
			[self insertUser:verbatmUser];

		} else {
			[self.delegate errorSigningUpUser: error];
		}
	}];

}

-(void) signUpOrLoginUserFromFacebookToken:(FBSDKAccessToken *)accessToken {

	[PFFacebookUtils logInInBackgroundWithAccessToken:[FBSDKAccessToken currentAccessToken] block:^(PFUser * _Nullable user, NSError * _Nullable error) {
		if (error) {
			[self errorInEitherSignUpOrLogin: error];
			return;
		} else {
			if (user.isNew) {
				[self getUserInfoFromFacebookToken: accessToken];
			} else {
				NSLog(@"User had already created account. Successfully logged in with Facebook.");
				[self.delegate successfullyLoggedInUser];
			}
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

				PFQuery *query = [PFUser query];
				[query whereKey:@"email" equalTo: email];
				[query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
					if (!error && object) {
						// delete the user created by fb login
						[[PFUser currentUser] deleteInBackground];
						FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
						[loginManager logOut];
						NSError* accountWithEmailExistsError = [NSError errorWithDomain:@"world" code: kPFErrorUserEmailTaken userInfo:nil];
						[self errorInEitherSignUpOrLogin: accountWithEmailExistsError];
					} else {
						// update current user
						PFUser* currentUser = [PFUser currentUser];
						[currentUser setObject: email forKey:@"email"];
						[currentUser saveInBackground];

						//	TODO: get picture data then store image
						//				 NSString* pictureURL = result[@"picture"][@"data"][@"url"];

						//will only show friends who have signed up for the app with fb
						NSArray* friends = nil;
						if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"user_friends"]) {
							friends = result[@"friends"][@"data"];
						}
						// TODO: do something with friends

						GTLVerbatmAppVerbatmUser* verbatmUser = [GTLVerbatmAppVerbatmUser alloc];
						verbatmUser.name = name;
						verbatmUser.email = email;
						[self insertUser:verbatmUser];
					}
				}];
			 } else {
				 [[PFUser currentUser] deleteInBackground];
				 [self.delegate errorSigningUpUser: error];
			 }
		 }];
	[connection start];
}

- (void) insertUser:(GTLVerbatmAppVerbatmUser*) user {
	GTLQueryVerbatmApp* insertUserQuery = [GTLQueryVerbatmApp queryForVerbatmuserInsertUserWithObject:user];
	[self.service executeQuery:insertUserQuery completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppVerbatmUser *userObject, NSError *error) {
		if (!error) {
			NSLog(@"Successfully inserted user object");
			[self.delegate successfullySignedUpUser: userObject];
		} else {
			NSLog(@"Error inserting user: %@", error.description);
			[[PFUser currentUser] deleteInBackground];
			[self.delegate errorSigningUpUser: error];
		}
	}];
}

-(void) errorInEitherSignUpOrLogin: (NSError*) error {
	if ( [self.delegate respondsToSelector:@selector(errorSigningUpUser:)]) {
		[self.delegate errorSigningUpUser: error];
	} else if ( [self.delegate respondsToSelector:@selector(errorLoggingInUser:)]) {
		[self.delegate errorLoggingInUser: error];
	}
}

#pragma mark - Logging in User -

-(void) loginUserFromEmail: (NSString*)email andPassword:(NSString*)password {
	[PFUser logInWithUsernameInBackground:email password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
		if (!error) {
			[self.delegate successfullyLoggedInUser];
		} else {
			[self.delegate errorLoggingInUser: error];
		}
	}];
}


#pragma mark - Retrieving current user -

- (void) getCurrentUser {
	if (![PFUser currentUser]) {
		NSLog(@"User is not logged in.");
		return;
	}
	NSString* email = [PFUser currentUser].email;
	GTLQueryVerbatmApp* getUserQuery = [GTLQueryVerbatmApp queryForVerbatmuserGetUserFromEmailWithEmail: email];
	[self.service executeQuery:getUserQuery completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppVerbatmUser* currentUser, NSError *error) {
		if (!error) {
			NSLog(@"Succesfully retrieved current user from datastore.");
			[self.delegate successfullyRetrievedCurrentUser: currentUser];
		} else {
			NSLog(@"Error retrieving current user: %@", error.description);
			[self.delegate errorRetrievingCurrentUser: error];
		}
	}];
}

#pragma mark - Update/change user info -

-(void) changeUserProfilePhoto: (UIImage*) image {
	//TODO:
}

#pragma mark - Log user out -

-(void) logOutUser {
	[PFUser logOutInBackground];
}

#pragma mark - Lazy Instantiation -

- (GTLServiceVerbatmApp *)service {
	if (!_service) {
		_service = [[GTLServiceVerbatmApp alloc] init];
		_service.retryEnabled = YES;
		// Development only
		[GTMHTTPFetcher setLoggingEnabled:YES];
	}
	return _service;
}

@end
