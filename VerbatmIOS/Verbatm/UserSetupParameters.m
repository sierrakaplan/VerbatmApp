//
//  UserSetupParemeters.m
//  Verbatm
//
//  Created by Iain Usiri on 9/13/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "UserSetupParameters.h"

@interface UserSetupParameters()
#define FILTER_INSTRUCTION_KEY @"FILTER_INSTRUCTION_KEY"
#define TRENDING_CIRCLE_INSTRUCTION_KEY @"TRENDING_CIRCLE_INSTRUCTION_KEY"
#define CIRCLE_IS_PAGE_INSTRUCTION_KEY @"CIRCLE_IS_PAGE_INSTRUCTION_KEY"
#define PINCH_INSTRUCTION_KEY @"PINCH_INSTRUCTION_KEY"
#define SWIPE_TO_DELETE_INSTRUCTION_KEY @"SWIPE_TO_DELETE_INSTRUCTION_KEY"
#define TAPNHOLD_TO_REMOVE_INSTRUCTION_KEY @"TAPNHOLD_TO_REMOVE_INSTRUCTION_KEY"

@end

@implementation UserSetupParameters

/*
    Saves the users parameters
 */
+(void) setUpParameters{
    @synchronized(self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //because they are all saved together we can just check if one exists
        if(![defaults objectForKey:FILTER_INSTRUCTION_KEY]){
            [defaults setBool:NO forKey:FILTER_INSTRUCTION_KEY];
            [defaults setBool:NO forKey:TRENDING_CIRCLE_INSTRUCTION_KEY];
            [defaults setBool:NO forKey:CIRCLE_IS_PAGE_INSTRUCTION_KEY];
            [defaults setBool:NO forKey:PINCH_INSTRUCTION_KEY];
            [defaults setBool:NO forKey:SWIPE_TO_DELETE_INSTRUCTION_KEY];
            [defaults setBool:NO forKey:TAPNHOLD_TO_REMOVE_INSTRUCTION_KEY];
            [defaults synchronize];
        }
    }
    
}

#pragma mark - Check Parameters -
+(BOOL)trendingCirle_InstructionShown{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:TRENDING_CIRCLE_INSTRUCTION_KEY];
}

+(BOOL) filter_InstructionShown{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:FILTER_INSTRUCTION_KEY];
}

+(BOOL) circlesArePages_InstructionShown{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:CIRCLE_IS_PAGE_INSTRUCTION_KEY];
}


+(BOOL) pinchCircles_InstructionShown{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   return [defaults boolForKey:PINCH_INSTRUCTION_KEY];
}

+(BOOL) tapNhold_InstructionShown{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:SWIPE_TO_DELETE_INSTRUCTION_KEY];
}

+(BOOL) swipeToDelete_InstructionShown{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:TAPNHOLD_TO_REMOVE_INSTRUCTION_KEY];
}

#pragma mark - Change Paramaters -
+(void) set_filter_InstructionAsShown{
    @synchronized(self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:FILTER_INSTRUCTION_KEY];
    }
}

+(void)set_trendingCirle_InstructionAsShown{
    @synchronized(self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:TRENDING_CIRCLE_INSTRUCTION_KEY];
    }
}


+(void)set_circlesArePages_InstructionAsShown{
    @synchronized(self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:CIRCLE_IS_PAGE_INSTRUCTION_KEY];
    }
}


+(void)set_pinchCircles_InstructionAsShown{
    @synchronized(self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:PINCH_INSTRUCTION_KEY];
    }
}


+(void)set_tapNhold_InstructionAsShown{
     @synchronized(self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         [defaults setBool:YES forKey:SWIPE_TO_DELETE_INSTRUCTION_KEY];
     }
}


+(void)set_swipeToDelete_InstructionAsShown{
     @synchronized(self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:TAPNHOLD_TO_REMOVE_INSTRUCTION_KEY];
     }
}

@end