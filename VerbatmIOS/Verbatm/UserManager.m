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
#import "GTLVerbatmAppPhoneNumber.h"
#import "GTLVerbatmAppEmail.h"
#import "GTMHTTPFetcherLogging.h"

#import "UserManager.h"

@interface UserManager()

@property(nonatomic, strong) GTLServiceVerbatmApp *service;

@end

@implementation UserManager

-(void) signUpUserFromEmail: (NSString*)email andName: (NSString*)name
				andPassword: (NSString*)password andPhoneNumber: (NSString*) phoneNumber {

	PFUser* newUser = [[PFUser alloc] init];
	// TODO: send confirmation email (must be unique)
	newUser.username = email;
	newUser.password = password;

	[newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
		if(succeeded) {
			GTLVerbatmAppVerbatmUser* verbatmUser = [GTLVerbatmAppVerbatmUser alloc];
			verbatmUser.name = name;
			GTLVerbatmAppEmail* verbatmEmail = [GTLVerbatmAppEmail alloc];
			verbatmEmail.email = email;
			verbatmUser.email = verbatmEmail;
			if (phoneNumber.length) {
				GTLVerbatmAppPhoneNumber* verbatmPhoneNumber = [GTLVerbatmAppPhoneNumber alloc];
				verbatmPhoneNumber.number = phoneNumber;
				verbatmUser.phoneNumber = verbatmPhoneNumber;
			}
			[self insertUser:verbatmUser];

		} else {
			[self.delegate errorSigningUpUser: error];
		}
	}];
}

-(void) signUpUserFromFacebookToken:(FBSDKAccessToken *)accessToken {
	
	[PFFacebookUtils logInInBackgroundWithAccessToken:[FBSDKAccessToken currentAccessToken] block:^(PFUser * _Nullable user, NSError * _Nullable error) {
		if (error) {
			//TODO:
		} else {
		}
	}];

	FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
	//get current signed-in user info
	NSDictionary* userFields =  [NSDictionary dictionaryWithObject: @"id,name,email,picture,friends" forKey:@"fields"];
	FBSDKGraphRequest *requestMe = [[FBSDKGraphRequest alloc]
									initWithGraphPath:@"me" parameters:userFields];
	[connection addRequest:requestMe
		 completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
			 if (!error) {
				 NSLog(@"Fetched User: %@", result);

				 NSString* name = result[@"name"];
				 NSString* email = result[@"email"];
				 [PFUser currentUser].email = email;
//	TODO: get picture data then store image			 NSString* pictureURL = result[@"picture"][@"data"][@"url"];

				 //will only show friends who have signed up for the app with fb
				 NSArray* friends = nil;
				 if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"user_friends"]) {
					 friends = result[@"friends"][@"data"];
				 }
				 GTLVerbatmAppVerbatmUser* verbatmUser = [GTLVerbatmAppVerbatmUser alloc];
				 GTLVerbatmAppEmail* verbatmEmail = [GTLVerbatmAppEmail alloc];
				 verbatmEmail.email = email;

				 verbatmUser.name = name;
				 verbatmUser.email = verbatmEmail;
				 [self insertUser:verbatmUser];
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

- (void) getCurrentUser {
	if (![PFUser currentUser]) {
		NSLog(@"User is not logged in.");
		return;
	}
	NSString* email = [PFUser currentUser].username;
	if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
		email = [PFUser currentUser].email;
	}
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

-(void) logOutUser {
	[PFUser logOutInBackground];
}

-(void) changeUserProfilePhoto: (UIImage*) image {
	//TODO:
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
