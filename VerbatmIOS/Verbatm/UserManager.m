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
	
}

- (void) insertUser:(GTLVerbatmAppVerbatmUser*) user {
	GTLQueryVerbatmApp* query = [GTLQueryVerbatmApp queryForVerbatmuserInsertUserWithObject:user];
	[self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLVerbatmAppVerbatmUser *object, NSError *error) {
		if (!error) {
			NSLog(@"Successfully inserted user object");
		} else {
			NSLog(@"Error signing up user: %@", error.description);
			//TODO:Error handling
		}
	}];
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
