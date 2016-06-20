//
//  UserSetupParemeters.h
//  Verbatm
//
//  Created by Iain Usiri on 9/13/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

/*
 This class helps determine permenant users preferences.
 Right now it's used to know if we have taken the users through 
 an initial setup - using notifications
 */

#import <Foundation/Foundation.h>

@interface UserSetupParameters : NSObject

+(instancetype)sharedInstance;

//initializes everything
-(void)setUpParameters;

/*check if these conditions have been met and set them otherwise*/
-(BOOL) checkTermsShown;
-(void) setTermsShown;
-(BOOL) checkOnboardingShown;
-(void) setOnboardingShown;

-(BOOL) checkAndSetFeedInstructionShown;
-(BOOL) checkAndSetProfileInstructionShown;
-(BOOL) checkAndSetADKInstructionShown;

-(BOOL) checkAndSetPinchInstructionShown;
-(BOOL) checkAndSetEditPinchViewInstructionShown;
-(BOOL) checkAndSetFilterInstructionShown;
-(BOOL) checkAndSetSwipeInstructionShown;
-(BOOL) checkAndSetAddTextInstructionShown;

-(BOOL) checkAdkOnboardingShown;
-(BOOL) checkFirstTimeFollowBlogShown;


@end
