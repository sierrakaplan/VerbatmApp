//
//  UserSetupParemeters.m
//  Verbatm
//
//  Created by Iain Usiri on 9/13/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "UserSetupParameters.h"

#import <Parse/PFUser.h>

#import "ParseBackendKeys.h"

@interface UserSetupParameters()

@property (atomic) BOOL ftue;

#define FILTER_SWIPE_INSTRUCTION_KEY @"FILTER_INSTRUCTION_KEY"
#define PROFILE_INTRO_INSTRUCTION_KEY @"PROFILE_INTRO_INSTRUCTION_KEY"
#define FEED_INTRO_INSTRUCTION_KEY @"FEED_INTRO_INSTRUCTION_KEY"
#define ADK_INTRO_INSTRUCTION_KEY @"ADK_INTRO_INSTRUCTION_KEY"
#define SWIPE_UP_DOWN_INSTRUCTION_KEY @"SWIPE_UP_DOWN_INSTRUCTION_KEY"
#define ADD_TEXT_INSTRUCTION_KEY @"ADD_TEXT_INSTRUCTION_KEY"
#define ACCEPTED_TERMS_KEY @"ACCEPTED_TERMS_KEY"
#define PINCH_INSTRUCTION_KEY @"PINCH_INSTRUCTION_KEY"
#define EDIT_INSTRUCTION_KEY @"EDIT_INSTRUCTION_KEY"
#define ON_BOARDING_EXPERIENCE_KEY @"ON_BOARDING_EXPRIENCE_KEY"
#define ADK_ONBOARDING_EXPERIENCE_KEY @"ADK_ONBOARDING_EXPERIENCE_KEY"
#define EDIT_PROFILE_PROMPT @"EDIT_PROFILE_PROMPT"
#define TAP_TO_EXIT_FULLSCREEN @"TAP_TO_EXIT_FULLSCREEN"

#define FIRST_TIME_BLOG_FOLLOW_KEY @"FIRST_TIME_BLOG_FOLLOW_KEY" //Has the user followed any blogs for the first time?

@end

@implementation UserSetupParameters

+(instancetype) sharedInstance {
	static UserSetupParameters * sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[UserSetupParameters alloc] init];
	});
	return sharedInstance;
}

-(void) setUpParameters {
	@synchronized(self) {
		PFUser *currentUser = [PFUser currentUser];
		self.ftue = [[currentUser objectForKey:USER_FTUE] boolValue];
		if (self.ftue) return;
    }
}

-(BOOL) checkOnboardingShown {
	return self.ftue;
}

-(void) setOnboardingShown {
    
    [[PFUser currentUser] setValue:[NSNumber numberWithBool:YES] forKey:USER_FTUE];

}

@end