//
//  UserSetupParemeters.m
//  Verbatm
//
//  Created by Iain Usiri on 9/13/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "UserSetupParameters.h"

@interface UserSetupParameters()

    @property (atomic, strong) NSMutableArray * notificationArray;

    #define FILTER_SWIPE_INSTRUCTION_KEY @"FILTER_INSTRUCTION_KEY"
    #define PAGE_SWIPE_INSTRUCTION_KEY @"PAGE_SWIPE_INSTRUCTION_KEY"
    #define PINCH_INSTRUCTION_KEY @"PINCH_INSTRUCTION_KEY"

    #define PAGE_SWIPE_INSTRUCTION_KEY_INDEX 0
    #define FILTER_SWIPE_INSTRUCTION_KEY_INDEX 1
    #define PINCH_INSTRUCTION_KEY_INDEX 2

    #define NUMBER_OF_KEYS 3
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
            [defaults setBool:NO forKey:PAGE_SWIPE_INSTRUCTION_KEY];
            [defaults synchronize];
        }else{
            //load and set the information we have set already -- asynchronous
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                self.notificationArray = [[NSMutableArray alloc] init];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [self.notificationArray addObject:[NSNumber numberWithBool:[defaults boolForKey:PAGE_SWIPE_INSTRUCTION_KEY]]];
                [self.notificationArray addObject:[NSNumber numberWithBool:[defaults boolForKey:FILTER_SWIPE_INSTRUCTION_KEY]]];
                [self.notificationArray addObject:[NSNumber numberWithBool:[defaults boolForKey:PINCH_INSTRUCTION_KEY]]];
            });
        }
    }
}

#pragma mark - Check Parameters -

-(BOOL) isFilter_InstructionShown{
    
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return NO;
    
    NSNumber * boolAsNumber = self.notificationArray[FILTER_SWIPE_INSTRUCTION_KEY_INDEX];
    return boolAsNumber.boolValue;
}



-(BOOL) isPinchCircles_InstructionShown{
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return NO;
    
    NSNumber * boolAsNumber = self.notificationArray[PINCH_INSTRUCTION_KEY_INDEX];
    return boolAsNumber.boolValue;
}

-(BOOL) isPageSwipeNavigation_InstructionShown{
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return NO;
    
    NSNumber * boolAsNumber = self.notificationArray[PAGE_SWIPE_INSTRUCTION_KEY_INDEX];
    return boolAsNumber.boolValue;
}

#pragma mark - Change Paramaters -




-(void) set_filter_InstructionAsShown {
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return;
    self.notificationArray[FILTER_SWIPE_INSTRUCTION_KEY_INDEX] = [NSNumber numberWithBool:YES];
}


-(void) set_pinchCircles_InstructionAsShown {
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return;
    self.notificationArray[PINCH_INSTRUCTION_KEY_INDEX] = [NSNumber numberWithBool:YES];
}


-(void) set_pageSwipeNavigation_InstructionAsShown {
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return;
    self.notificationArray[PAGE_SWIPE_INSTRUCTION_KEY_INDEX] = [NSNumber numberWithBool:YES];
}



-(void)saveAllChanges {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:(BOOL)self.notificationArray[FILTER_SWIPE_INSTRUCTION_KEY_INDEX] forKey:FILTER_SWIPE_INSTRUCTION_KEY];
    [defaults setBool:(BOOL)self.notificationArray[PAGE_SWIPE_INSTRUCTION_KEY_INDEX] forKey:PAGE_SWIPE_INSTRUCTION_KEY];
    [defaults setBool:(BOOL)self.notificationArray[PINCH_INSTRUCTION_KEY_INDEX] forKey:PINCH_INSTRUCTION_KEY];
    
}








@end