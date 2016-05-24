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
@property (atomic, strong) NSMutableDictionary * notificationSet;

#define FILTER_SWIPE_INSTRUCTION_KEY @"FILTER_INSTRUCTION_KEY"
#define PROFILE_INTRO_INSTRUCTION_KEY @"PROFILE_INTRO_INSTRUCTION_KEY"
#define FEED_INTRO_INSTRUCTION_KEY @"FEED_INTRO_INSTRUCTION_KEY"
#define ADK_INTRO_INSTRUCTION_KEY @"ADK_INTRO_INSTRUCTION_KEY"
#define SWIPE_UP_DOWN_INSTRUCTION_KEY @"SWIPE_UP_DOWN_INSTRUCTION_KEY"

#define ACCEPTED_TERMS_KEY @"ACCEPTED_TERMS_KEY"

#define PINCH_INSTRUCTION_KEY @"PINCH_INSTRUCTION_KEY"

#define ON_BOARDING_EXPERIENCE_KEY @"ON_BOARDING_EXPRIENCE_KEY"
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
			[defaults setBool:NO forKey:FILTER_SWIPE_INSTRUCTION_KEY];
			[defaults setBool:NO forKey:PINCH_INSTRUCTION_KEY];
			[defaults setBool:NO forKey:PROFILE_INTRO_INSTRUCTION_KEY];
			[defaults setBool:NO forKey:ADK_INTRO_INSTRUCTION_KEY];
			[defaults setBool:NO forKey:SWIPE_UP_DOWN_INSTRUCTION_KEY];
			[defaults setBool:NO forKey:ACCEPTED_TERMS_KEY];
			[defaults setBool:NO forKey:ON_BOARDING_EXPERIENCE_KEY];
			[defaults synchronize];
		} else {
			//load and set the information we have saved already -- asynchronous
			dispatch_async(dispatch_get_global_queue(0, 0), ^{
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				self.notificationSet = [NSMutableDictionary dictionaryWithDictionary:defaults.dictionaryRepresentation];
			});
		}
	}
}

#pragma mark - Check Parameters -


-(BOOL) isonBoarding_InstructionShown {
	if (self.ftue) return YES;
	if(!self.self.notificationSet) return NO;
	NSNumber * boolAsNumber = self.notificationSet[ON_BOARDING_EXPERIENCE_KEY];
	return boolAsNumber.boolValue;
}

-(BOOL) isFeed_InstructionShown{
	if (self.ftue) return YES;
	if(!self.self.notificationSet) return NO;
	NSNumber * boolAsNumber = self.notificationSet[FEED_INTRO_INSTRUCTION_KEY];
	return boolAsNumber.boolValue;
}

-(BOOL) isProfile_InstructionShown{
	if (self.ftue) return YES;
	if(!self.self.notificationSet) return NO;
	NSNumber * boolAsNumber = self.notificationSet[PROFILE_INTRO_INSTRUCTION_KEY];
	return boolAsNumber.boolValue;
}

-(BOOL) isAdk_InstructionShown {
	if (self.ftue) return YES;
	if(!self.self.notificationSet) return NO;
	NSNumber * boolAsNumber = self.notificationSet[ADK_INTRO_INSTRUCTION_KEY];
	return boolAsNumber.boolValue;
}

-(BOOL) isFilter_InstructionShown{
	if (self.ftue) return YES;
	//the array is still being prepared -- unlikely to be a problem
	if(!self.notificationSet) return NO;

	NSNumber * boolAsNumber = self.notificationSet[FILTER_SWIPE_INSTRUCTION_KEY];
	return boolAsNumber.boolValue;
}

-(BOOL) isPinchCircles_InstructionShown {
	if (self.ftue) return YES;
	//the array is still being prepared -- unlikely to be a problem
	if(!self.self.notificationSet) return NO;
	NSNumber * boolAsNumber = self.notificationSet[PINCH_INSTRUCTION_KEY];
	return boolAsNumber.boolValue;
}


-(BOOL) isSwipeUpDown_InstructionShown {
	if (self.ftue) return YES;
	if(!self.self.notificationSet) return NO;
	NSNumber * boolAsNumber = self.notificationSet[SWIPE_UP_DOWN_INSTRUCTION_KEY];
	return boolAsNumber.boolValue;
}

-(BOOL) isTermsAccept_InstructionShown{
	if (self.ftue) return YES;
	if(!self.notificationSet) return NO;
	NSNumber * boolAsNumber = self.notificationSet[ACCEPTED_TERMS_KEY];
	return boolAsNumber.boolValue;
}


#pragma mark - Change Paramaters -

-(void) set_onboarding_InstructionAsShown {
	@synchronized(self) {
		[self.notificationSet setValue:[NSNumber numberWithBool:YES] forKey:ON_BOARDING_EXPERIENCE_KEY];
		[self saveAllChanges];
	}
}

-(void) set_filter_InstructionAsShown {
	@synchronized(self) {
		[self.notificationSet setValue:[NSNumber numberWithBool:YES] forKey:FILTER_SWIPE_INSTRUCTION_KEY];
		[self saveAllChanges];
	}
}

-(void) set_pinchCircles_InstructionAsShown {
	@synchronized(self) {
		[self.notificationSet setValue:[NSNumber numberWithBool:YES] forKey:PINCH_INSTRUCTION_KEY];
		[self saveAllChanges];
	}
}

-(void) set_profileNotification_InstructionAsShown {
	@synchronized(self) {
		[self.notificationSet setValue:[NSNumber numberWithBool:YES] forKey:PROFILE_INTRO_INSTRUCTION_KEY];
		[self saveAllChanges];
	}
}
-(void) set_feedNotification_InstructionAsShown {
	@synchronized(self) {
		[self.notificationSet setValue:[NSNumber numberWithBool:YES] forKey:FEED_INTRO_INSTRUCTION_KEY];
		[self saveAllChanges];
	}
}
-(void) set_ADKNotification_InstructionAsShown {
	@synchronized(self) {
		[self.notificationSet setValue:[NSNumber numberWithBool:YES] forKey:ADK_INTRO_INSTRUCTION_KEY];
		[self saveAllChanges];
	}
}


-(void) set_SwipeUpDownNotification_InstructionAsShown {
	@synchronized(self) {
		[self.notificationSet setValue:[NSNumber numberWithBool:YES] forKey:SWIPE_UP_DOWN_INSTRUCTION_KEY];
		[self saveAllChanges];
	}
}


-(void) set_TermsAccept_InstructionAsShown {
	@synchronized(self) {
		[self.notificationSet setValue:[NSNumber numberWithBool:YES] forKey:ACCEPTED_TERMS_KEY];
		[self saveAllChanges];
	}
}

-(void)saveAllChanges {
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setValuesForKeysWithDictionary:self.notificationSet];
	});

}



@end