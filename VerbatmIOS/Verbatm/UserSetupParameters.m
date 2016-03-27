//
//  UserSetupParemeters.m
//  Verbatm
//
//  Created by Iain Usiri on 9/13/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "UserSetupParameters.h"

@interface UserSetupParameters()

    @property (atomic, strong) NSDictionary * notificationSet;

    #define FILTER_SWIPE_INSTRUCTION_KEY @"FILTER_INSTRUCTION_KEY"
    #define PROFILE_INTRO_INSTRUCTION_KEY @"PROFILE_INTRO_INSTRUCTION_KEY"
    #define FEED_INTRO_INSTRUCTION_KEY @"FEED_INTRO_INSTRUCTION_KEY"
    #define ADK_INTRO_INSTRUCTION_KEY @"ADK_INTRO_INSTRUCTION_KEY"

    #define PINCH_INSTRUCTION_KEY @"PINCH_INSTRUCTION_KEY"
@end

@implementation UserSetupParameters

/*
    Saves the users parameters
 */
+(instancetype) sharedInstance {
    static UserSetupParameters * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UserSetupParameters alloc] init];
    });
    return sharedInstance;
}

-(void)setUpParameters{
    @synchronized(self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //because they are all saved together we can just check if one exists
        if(![defaults objectForKey:FILTER_SWIPE_INSTRUCTION_KEY]){
            [defaults setBool:NO forKey:FILTER_SWIPE_INSTRUCTION_KEY];
            [defaults setBool:NO forKey:PINCH_INSTRUCTION_KEY];
            [defaults setBool:NO forKey:PROFILE_INTRO_INSTRUCTION_KEY];
            [defaults setBool:NO forKey:FEED_INTRO_INSTRUCTION_KEY];
            [defaults setBool:NO forKey:ADK_INTRO_INSTRUCTION_KEY];
            [defaults synchronize];
        }else{
            //load and set the information we have saved already -- asynchronous
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                self.notificationSet = [NSDictionary dictionaryWithDictionary:defaults.dictionaryRepresentation];
            });
        }
    }
}

#pragma mark - Check Parameters -


-(BOOL) isFeed_InstructionShown{
    if(!self.self.notificationSet) return NO;
    NSNumber * boolAsNumber = self.notificationSet[FEED_INTRO_INSTRUCTION_KEY];
    return boolAsNumber.boolValue;
}
-(BOOL) isProfile_InstructionShown{
    if(!self.self.notificationSet) return NO;
    NSNumber * boolAsNumber = self.notificationSet[PROFILE_INTRO_INSTRUCTION_KEY];
    return boolAsNumber.boolValue;
}
-(BOOL) isAdk_InstructionShown{
    if(!self.self.notificationSet) return NO;
    NSNumber * boolAsNumber = self.notificationSet[ADK_INTRO_INSTRUCTION_KEY];
    return boolAsNumber.boolValue;
}


//
//-(BOOL) isFilter_InstructionShown{
//    
//    //the array is still being prepared -- unlikely to be a problem
//    if(!self.notificationSet) return NO;
//    
//    NSNumber * boolAsNumber = self.notificationArray[FILTER_SWIPE_INSTRUCTION_KEY_INDEX];
//    return boolAsNumber.boolValue;
//}
//
//
//
//-(BOOL) isPinchCircles_InstructionShown{
//    //the array is still being prepared -- unlikely to be a problem
//    if(self.notificationArray.count != NUMBER_OF_KEYS) return NO;
//    
//    NSNumber * boolAsNumber = self.notificationArray[PINCH_INSTRUCTION_KEY_INDEX];
//    return boolAsNumber.boolValue;
//}



#pragma mark - Change Paramaters -




//-(void) set_filter_InstructionAsShown {
//    //the array is still being prepared -- unlikely to be a problem
//    if(self.notificationArray.count != NUMBER_OF_KEYS) return;
//    self.notificationArray[FILTER_SWIPE_INSTRUCTION_KEY_INDEX] = [NSNumber numberWithBool:YES];
//}
//
//
//-(void) set_pinchCircles_InstructionAsShown {
//    //the array is still being prepared -- unlikely to be a problem
//    if(self.notificationArray.count != NUMBER_OF_KEYS) return;
//    self.notificationArray[PINCH_INSTRUCTION_KEY_INDEX] = [NSNumber numberWithBool:YES];
//}





-(void)saveAllChanges {
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setBool:(BOOL)self.notificationArray[FILTER_SWIPE_INSTRUCTION_KEY_INDEX] forKey:FILTER_SWIPE_INSTRUCTION_KEY];
//    [defaults setBool:(BOOL)self.notificationArray[PINCH_INSTRUCTION_KEY_INDEX] forKey:PINCH_INSTRUCTION_KEY];
    
}








@end