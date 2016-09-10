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
@property (nonatomic) UIImage * currentCoverPhoto;
@end

@implementation UserManager

+ (instancetype)sharedInstance {
	static UserManager *_sharedInstance = nil;
	static dispatch_once_t onceSecurePredicate;
	dispatch_once(&onceSecurePredicate,^{
		_sharedInstance = [[self alloc] init];
	});

	return _sharedInstance;
}

-(instancetype) init {
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(userHasSignedOut)
													 name:NOTIFICATION_USER_SIGNED_OUT
												   object:nil];
	}
	return self;
}

-(void) userHasSignedOut {
	self.currentCoverPhoto = nil;
}

#pragma mark - Creating Account (Signing up user) -

-(void) signUpOrLoginUserFromFacebookToken:(FBSDKAccessToken *)accessToken {
	[PFFacebookUtils logInInBackgroundWithAccessToken:[FBSDKAccessToken currentAccessToken] block:^(PFUser * _Nullable user, NSError * _Nullable error) {
		if (error) {
			//todo: fail error
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

-(void)updateCurrentUserWithName:(NSString *) name andEmail:(NSString *) email andFbId:(NSString*)fbId {
	// update current user
	PFUser* currentUser = [PFUser currentUser];
	//we don't set the username because that's set by facebook.
	if(email) currentUser.email = email;
	if(name) [currentUser setObject: name forKey:VERBATM_USER_NAME_KEY];
	[currentUser setObject:[NSNumber numberWithBool:NO] forKey:USER_FTUE];
	[currentUser setObject:fbId forKey:USER_FB_ID];
	[currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
		if(error) {
			[[Crashlytics sharedInstance] recordError:error];
		}
	}];
}

+(void) setFbId {
	FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
	NSDictionary* userFields =  [NSDictionary dictionaryWithObject: @"id" forKey:@"fields"];
	FBSDKGraphRequest *requestMe = [[FBSDKGraphRequest alloc]
									initWithGraphPath:@"me" parameters:userFields];
	[connection addRequest:requestMe
		 completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
			 if (!error) {
				  NSString *fbId = [result objectForKey:@"id"];
				 [[PFUser currentUser] setObject:fbId forKey:USER_FB_ID];
				 [[PFUser currentUser] saveInBackground];
			 }
		 }];
	[connection start];
}

// Starts request query for a fb user's name, email, picture, and friends.
// Assumes the accessToken has been checked somewhere else
- (void) getUserInfoFromFacebookToken: (FBSDKAccessToken*) accessToken {

	FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
	NSDictionary* userFields =  [NSDictionary dictionaryWithObject: @"id,name,email,picture" forKey:@"fields"];
	FBSDKGraphRequest *requestMe = [[FBSDKGraphRequest alloc]
									initWithGraphPath:@"me" parameters:userFields];
	[connection addRequest:requestMe
		 completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
			 if (error) {
				 [[PFUser currentUser] deleteInBackground];
				 //todo: fail error
				 [self notifyFailedLogin: error];
				 return;
			 }

			 NSString *name = result[@"name"];
			 NSString *email = result[@"email"];
			 NSString *fbId = [result objectForKey:@"id"];

			 if(!email) {
				 NSString *description = @"Facebook login failed. Please try again.";
				 NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : description};
				 //todo: don't hardcode error codes
				 NSError *needEmailError = [NSError errorWithDomain:@"world" code:20 userInfo:errorDictionary];
				 [[PFUser currentUser] deleteInBackground];
				 [self notifyFailedLogin: needEmailError];
				 return;
			 }

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
					 [self updateCurrentUserWithName:name andEmail:email andFbId:fbId];
					 //						NSString* pictureURL = result[@"picture"][@"data"][@"url"];
					 //						NSLog(@"profile picture url: %@", pictureURL);

					 [self notifySuccessfulLogin];

				 }

			 }];
		 }];
	[connection start];
}

-(NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
	NSDate *fromDate;
	NSDate *toDate;

	NSCalendar *calendar = [NSCalendar currentCalendar];

	[calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
				 interval:NULL forDate:fromDateTime];
	[calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
				 interval:NULL forDate:toDateTime];

	NSDateComponents *difference = [calendar components:NSCalendarUnitDay
											   fromDate:fromDate toDate:toDate options:0];

	return [difference day];
}

-(BOOL)hasBeenAWeek:(NSDate *)lastDate{
	NSDate * today = [NSDate date];

	if(!lastDate || [self daysBetweenDate:lastDate andDate:today] >= 7){
		return YES;
	}
	return NO;
}

-(BOOL)shouldRequestForUserFeedback{
	NSDate * lastFeedbackDate = [[PFUser currentUser] valueForKey:USER_LAST_FEEDBACK_DATE_KEY];
	if([self hasBeenAWeek:lastFeedbackDate]){
		[[PFUser currentUser] setValue:[NSDate date] forKey:USER_LAST_FEEDBACK_DATE_KEY];
		return YES;
	}
	return NO;
}

-(void)holdCurrentCoverPhoto:(UIImage *)coverPhoto{
	self.currentCoverPhoto = coverPhoto;
}

-(UIImage *)getCurrentCoverPhoto{
	return self.currentCoverPhoto;
}

#pragma mark - Log user out -

-(void) logOutUser {
	[PFUser logOutInBackground];
	[[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
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
