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

    #define FILTER_INSTRUCTION_KEY @"FILTER_INSTRUCTION_KEY"
    #define TRENDING_CIRCLE_INSTRUCTION_KEY @"TRENDING_CIRCLE_INSTRUCTION_KEY"
    #define CIRCLE_IS_PAGE_INSTRUCTION_KEY @"CIRCLE_IS_PAGE_INSTRUCTION_KEY"
    #define PINCH_INSTRUCTION_KEY @"PINCH_INSTRUCTION_KEY"
    #define SWIPE_TO_DELETE_INSTRUCTION_KEY @"SWIPE_TO_DELETE_INSTRUCTION_KEY"
    #define TAPNHOLD_TO_REMOVE_INSTRUCTION_KEY @"TAPNHOLD_TO_REMOVE_INSTRUCTION_KEY"
    #define ACCESS_KEY_INSTRUCTION_KEY @"ACCESS_KEY_INSTRUCTION_KEY"

    #define ACCESS_KEY_INSTRUCTION_KEY_INDEX 0
    #define CIRCLE_IS_PAGE_INSTRUCTION_KEY_INDEX 1
    #define FILTER_INSTRUCTION_KEY_INDEX 2
    #define PINCH_INSTRUCTION_KEY_INDEX 3
    #define SWIPE_TO_DELETE_INSTRUCTION_KEY_INDEX 4
    #define TAPNHOLD_TO_REMOVE_INSTRUCTION_KEY_INDEX 5
    #define TRENDING_CIRCLE_INSTRUCTION_KEY_INDEX 6

    #define NUMBER_OF_KEYS 7
@end

@implementation UserSetupParameters

/*
    Saves the users parameters
 */
+(instancetype) sharedInstance{

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
        if(![defaults objectForKey:FILTER_INSTRUCTION_KEY]){
            [defaults setBool:NO forKey:TRENDING_CIRCLE_INSTRUCTION_KEY];
            [defaults setBool:NO forKey:FILTER_INSTRUCTION_KEY];
            [defaults setBool:NO forKey:CIRCLE_IS_PAGE_INSTRUCTION_KEY];
            [defaults setBool:NO forKey:PINCH_INSTRUCTION_KEY];
            [defaults setBool:NO forKey:TAPNHOLD_TO_REMOVE_INSTRUCTION_KEY];
            [defaults setBool:NO forKey:SWIPE_TO_DELETE_INSTRUCTION_KEY];
            [defaults setBool:NO forKey:ACCESS_KEY_INSTRUCTION_KEY];
            [defaults synchronize];
        }else{
            //load and set the information we have set already -- asynchronous
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                self.notificationArray = [[NSMutableArray alloc] init];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [self.notificationArray addObject:[NSNumber numberWithBool:[defaults boolForKey:ACCESS_KEY_INSTRUCTION_KEY]]];
                [self.notificationArray addObject:[NSNumber numberWithBool:[defaults boolForKey:CIRCLE_IS_PAGE_INSTRUCTION_KEY]]];
                [self.notificationArray addObject:[NSNumber numberWithBool:[defaults boolForKey:FILTER_INSTRUCTION_KEY]]];
                [self.notificationArray addObject:[NSNumber numberWithBool:[defaults boolForKey:PINCH_INSTRUCTION_KEY]]];
                [self.notificationArray addObject:[NSNumber numberWithBool:[defaults boolForKey:SWIPE_TO_DELETE_INSTRUCTION_KEY]]];
                [self.notificationArray addObject:[NSNumber numberWithBool:[defaults boolForKey:TAPNHOLD_TO_REMOVE_INSTRUCTION_KEY]]];
                [self.notificationArray addObject:[NSNumber numberWithBool:[defaults boolForKey:TRENDING_CIRCLE_INSTRUCTION_KEY]]];
            });
        }
    }
}

#pragma mark - Check Parameters -
-(BOOL)blackCircleInstructionShown{
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return NO;
    
    NSNumber * boolAsNumber = self.notificationArray[TRENDING_CIRCLE_INSTRUCTION_KEY_INDEX];
    return boolAsNumber.boolValue;
}

-(BOOL) filter_InstructionShown{
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return NO;
    
    NSNumber * boolAsNumber = self.notificationArray[FILTER_INSTRUCTION_KEY_INDEX];
    return boolAsNumber.boolValue;
}

-(BOOL) circlesArePages_InstructionShown{
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return NO;
    
    NSNumber * boolAsNumber = self.notificationArray[CIRCLE_IS_PAGE_INSTRUCTION_KEY_INDEX];
    return boolAsNumber.boolValue;
}

-(BOOL) pinchCircles_InstructionShown{
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return NO;
    
    NSNumber * boolAsNumber = self.notificationArray[PINCH_INSTRUCTION_KEY_INDEX];
    return boolAsNumber.boolValue;
}

-(BOOL) tapNhold_InstructionShown{
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return NO;
    
    NSNumber * boolAsNumber = self.notificationArray[TAPNHOLD_TO_REMOVE_INSTRUCTION_KEY_INDEX];
    return boolAsNumber.boolValue;
}

-(BOOL) swipeToDelete_InstructionShown {
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return NO;
    
    NSNumber * boolAsNumber = self.notificationArray[SWIPE_TO_DELETE_INSTRUCTION_KEY_INDEX];
    return boolAsNumber.boolValue;
}

-(BOOL) accessCodeEntered {
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return NO;
    
    NSNumber * boolAsNumber = self.notificationArray[ACCESS_KEY_INSTRUCTION_KEY_INDEX];
    return boolAsNumber.boolValue;
}

#pragma mark - Change Paramaters -

-(void) set_accessCodeAsEntered{
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return;
    
    self.notificationArray[ACCESS_KEY_INSTRUCTION_KEY_INDEX] = [NSNumber numberWithBool:YES];
}


-(void) set_filter_InstructionAsShown{
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return;
    
    self.notificationArray[FILTER_INSTRUCTION_KEY_INDEX] = [NSNumber numberWithBool:YES];
}

-(void)set_trendingCirle_InstructionAsShown{
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return;
    
    self.notificationArray[TRENDING_CIRCLE_INSTRUCTION_KEY_INDEX] = [NSNumber numberWithBool:YES];
}

-(void)set_circlesArePages_InstructionAsShown{
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return;
    
    self.notificationArray[CIRCLE_IS_PAGE_INSTRUCTION_KEY_INDEX] = [NSNumber numberWithBool:YES];
}


-(void)set_pinchCircles_InstructionAsShown{
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return;
    
    self.notificationArray[PINCH_INSTRUCTION_KEY_INDEX] = [NSNumber numberWithBool:YES];
}


-(void)set_tapNhold_InstructionAsShown{
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return;
    
    self.notificationArray[TAPNHOLD_TO_REMOVE_INSTRUCTION_KEY_INDEX] = [NSNumber numberWithBool:YES];
}


-(void)set_swipeToDelete_InstructionAsShown{
    //the array is still being prepared -- unlikely to be a problem
    if(self.notificationArray.count != NUMBER_OF_KEYS) return;
    
    self.notificationArray[SWIPE_TO_DELETE_INSTRUCTION_KEY_INDEX] = [NSNumber numberWithBool:YES];
    
}



-(void)saveAllChanges{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.notificationArray[TRENDING_CIRCLE_INSTRUCTION_KEY_INDEX] forKey:TRENDING_CIRCLE_INSTRUCTION_KEY];
    [defaults setBool:self.notificationArray[FILTER_INSTRUCTION_KEY_INDEX] forKey:FILTER_INSTRUCTION_KEY];
    [defaults setBool:self.notificationArray[CIRCLE_IS_PAGE_INSTRUCTION_KEY_INDEX] forKey:CIRCLE_IS_PAGE_INSTRUCTION_KEY];
    [defaults setBool:self.notificationArray[PINCH_INSTRUCTION_KEY_INDEX] forKey:PINCH_INSTRUCTION_KEY];
    [defaults setBool:self.notificationArray[TAPNHOLD_TO_REMOVE_INSTRUCTION_KEY_INDEX] forKey:TAPNHOLD_TO_REMOVE_INSTRUCTION_KEY];
    [defaults setBool:self.notificationArray[SWIPE_TO_DELETE_INSTRUCTION_KEY_INDEX] forKey:SWIPE_TO_DELETE_INSTRUCTION_KEY];
    [defaults setBool:self.notificationArray[ACCESS_KEY_INSTRUCTION_KEY_INDEX] forKey:ACCESS_KEY_INSTRUCTION_KEY];
}


@end