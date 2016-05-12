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

/*check if these conditions have been met*/
-(BOOL) isFilter_InstructionShown;
-(BOOL) isPinchCircles_InstructionShown;
-(BOOL) isSwipeUpDown_InstructionShown;

-(BOOL) isFeed_InstructionShown;
-(BOOL) isProfile_InstructionShown;
-(BOOL) isAdk_InstructionShown;

-(BOOL) isTermsAccept_InstructionShown;

-(BOOL) isonBoarding_InstructionShown;


/*Stores that the notifications have been shown*/
-(void) set_filter_InstructionAsShown;
-(void) set_pinchCircles_InstructionAsShown;

-(void) set_profileNotification_InstructionAsShown;
-(void) set_feedNotification_InstructionAsShown;
-(void) set_ADKNotification_InstructionAsShown;
-(void) set_SwipeUpDownNotification_InstructionAsShown;

-(void) set_TermsAccept_InstructionAsShown;


-(void) set_onboarding_InstructionAsShown;



-(void)saveAllChanges;

@end
