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

		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		//because they are all saved together we can just check if one exists
		if(![defaults objectForKey:FEED_INTRO_INSTRUCTION_KEY]){
			[defaults setBool:NO forKey:FEED_INTRO_INSTRUCTION_KEY];
			[defaults setBool:NO forKey:FILTER_SWIPE_INSTRUCTION_KEY];
			[defaults setBool:NO forKey:PINCH_INSTRUCTION_KEY];
			[defaults setBool:NO forKey:PROFILE_INTRO_INSTRUCTION_KEY];
			[defaults setBool:NO forKey:ADK_INTRO_INSTRUCTION_KEY];
			[defaults setBool:NO forKey:SWIPE_UP_DOWN_INSTRUCTION_KEY];
			[defaults setBool:NO forKey:ACCEPTED_TERMS_KEY];
			[defaults setBool:NO forKey:ON_BOARDING_EXPERIENCE_KEY];
            [defaults setBool:NO forKey:ADK_ONBOARDING_EXPERIENCE_KEY];
            [defaults setBool:NO forKey:FIRST_TIME_BLOG_FOLLOW_KEY];
            [defaults setBool:NO forKey:EDIT_PROFILE_PROMPT];
			[defaults synchronize];
		}
	}
}

#pragma mark - Check & set parameters -

-(BOOL) checkTermsShown {
	if (self.ftue) return YES;
	@synchronized(self) {
		return [(NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:ACCEPTED_TERMS_KEY] boolValue];
	}
}

-(void) setTermsShown {
	@synchronized (self) {
		[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:ACCEPTED_TERMS_KEY];
	}
}

-(BOOL) checkOnboardingShown {
	if (self.ftue) return YES;
	@synchronized(self) {
		return [(NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:ON_BOARDING_EXPERIENCE_KEY] boolValue];
	}
}

-(void) setOnboardingShown {
	[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:ON_BOARDING_EXPERIENCE_KEY];
}


-(BOOL) checkEditButtonNotification {
    if (self.ftue) return YES;
    @synchronized(self) {
        BOOL shown = [(NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:EDIT_PROFILE_PROMPT] boolValue];
        if (!shown) {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:EDIT_PROFILE_PROMPT];
        }
        return shown;
    }
}


-(BOOL) checkAdkOnboardingShown {
    if (self.ftue) return YES;
    @synchronized(self) {
        BOOL shown = [(NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:ADK_ONBOARDING_EXPERIENCE_KEY] boolValue];
        if (!shown) {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:ADK_ONBOARDING_EXPERIENCE_KEY];
        }
        return shown;
    }
}

-(BOOL) checkFirstTimeFollowBlogShown {
    if (self.ftue) return YES;
    @synchronized(self) {
        BOOL shown = [(NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:FIRST_TIME_BLOG_FOLLOW_KEY] boolValue];
        if (!shown) {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:FIRST_TIME_BLOG_FOLLOW_KEY];
        }
        return shown;
    }
}

-(BOOL) checkAndSetFeedInstructionShown {
	if (self.ftue) return YES;
	@synchronized(self) {
		BOOL shown = [(NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:FEED_INTRO_INSTRUCTION_KEY] boolValue];
		if (!shown) {
			[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:FEED_INTRO_INSTRUCTION_KEY];
		}
		return shown;
	}
}

-(BOOL) checkAndSetProfileInstructionShown {
	if (self.ftue) return YES;
	@synchronized(self) {
		BOOL shown = [(NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:PROFILE_INTRO_INSTRUCTION_KEY] boolValue];
		if (!shown) {
			[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:PROFILE_INTRO_INSTRUCTION_KEY];
		}
		return shown;
	}
}

-(BOOL) checkAndSetADKInstructionShown {
	if (self.ftue) return YES;
	@synchronized(self) {
		BOOL shown = [(NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:ADK_INTRO_INSTRUCTION_KEY] boolValue];
		if (!shown) {
			[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:ADK_INTRO_INSTRUCTION_KEY];
		}
		return shown;
	}
}

-(BOOL) checkAndSetPinchInstructionShown {
	if (self.ftue) return YES;
	@synchronized(self) {
		BOOL shown = [(NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:PINCH_INSTRUCTION_KEY] boolValue];
		if (!shown) {
			[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:PINCH_INSTRUCTION_KEY];
		}
		return shown;
	}
}

-(BOOL) checkAndSetEditPinchViewInstructionShown {
	if (self.ftue) return YES;
	@synchronized(self) {
		BOOL shown = [(NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:EDIT_INSTRUCTION_KEY] boolValue];
		if (!shown) {
			[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:EDIT_INSTRUCTION_KEY];
		}
		return shown;
	}
}

-(BOOL) checkAndSetSwipeInstructionShown {
	if (self.ftue) return YES;
	@synchronized(self) {
		BOOL shown = [(NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:SWIPE_UP_DOWN_INSTRUCTION_KEY] boolValue];
		if (!shown) {
			[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:SWIPE_UP_DOWN_INSTRUCTION_KEY];
		}
		return shown;
	}
}

-(BOOL) checkAndSetFilterInstructionShown {
	if (self.ftue) return YES;
	@synchronized(self) {
		BOOL shown = [(NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:FILTER_SWIPE_INSTRUCTION_KEY] boolValue];
		if (!shown) {
			[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:FILTER_SWIPE_INSTRUCTION_KEY];
		}
		return shown;
	}
}

-(BOOL) checkAndSetAddTextInstructionShown {
	if (self.ftue) return YES;
	@synchronized (self) {
		BOOL shown = [(NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:ADD_TEXT_INSTRUCTION_KEY] boolValue];
		if (!shown) {
			[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:ADD_TEXT_INSTRUCTION_KEY];
		}
		return shown;
	}
}

@end