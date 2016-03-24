
//
//  User_BackendObject.m
//  Verbatm
//
//  Created by Iain Usiri on 3/24/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "User_BackendObject.h"
#import <Parse/PFUser.h>
#import <Parse/PFQuery.h>
#import "ParseBackendKeys.h"
#import "Notifications.h"
@implementation User_BackendObject


+(void)updateUserNameOfCurrentUserTo:(NSString *) newName{
    if(newName && [User_BackendObject stringHasCharacters:newName] &&
       ![newName isEqualToString:[[PFUser currentUser] valueForKey:USER_USER_NAME_KEY]])
    {
        
        //we check if the name is already taken
        PFQuery * userQuery = [PFQuery queryWithClassName:@"User"];
        [userQuery whereKey:USER_USER_NAME_KEY equalTo:newName];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                             NSError * _Nullable error) {
        
            if(objects.count == 0){
                //name not taken
                [[PFUser currentUser] setValue:newName forKey:USER_USER_NAME_KEY];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(succeeded){
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USERNAME_CHANGED_SUCCESFULLY object:nil];
                    }else{
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USERNAME_CHANGE_FAILED object:nil];
                    }
                }];
            }
        }];
    }
}

+(BOOL)stringHasCharacters:(NSString *) text{
    NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
    return ![[text stringByTrimmingCharactersInSet:alphaSet] isEqualToString:text];
}



@end
