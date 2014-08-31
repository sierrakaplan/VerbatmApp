//
//  VerbatmUser.h
//  Verbatm
//
//  Created by Iain Usiri on 8/16/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Article.h"

@interface VerbatmUser : PFUser 


/*
 Every method must be called by a user that is logged in. Use [VerbatmUser currentUser] as the argument.
 */
/*
 returns nil if something went wrong creating the user
 doesn't signin user- do this externally
 */
- (VerbatmUser *) initWithUserName: (NSString *) userName
                         FirstName: (NSString *) firstName
                          LastName: (NSString *) lastName
                             Email: (NSString *) email
                       PhoneNumber: (NSNumber *) phoneNumber
                          Password: (NSString *) password
         withSignUpCompletionBlock: (void(^)(BOOL succeeded, NSError *error)) block;

/*Follow feature.*/
/*
 completion block should handle errors in saving the relationship
 */
-(void) followUser:(VerbatmUser *)toFollow withCompletionBlock: (void(^)(BOOL succeeded, NSError * error)) block;

/*Edits the User's status*/

-(void) setCurrentStatus: (NSString *) status withCompletionBlock: (void(^)(BOOL succeeded, NSError * error)) block;

/*Adds the article to the list of articles the user likes*/
/*
 completion block should handle errors in saving the relationship
 */
-(void) likeArticle: (Article *) article withCompletionBlock: (void(^)(BOOL succeeded, NSError * error)) block;

/*Advance Users can endorse other users to raise their reputation within the system*/
/*
 completion block should handle errors in saving the relationship
 */
-(void) endorseUser: (VerbatmUser *) user withCompletionBlock: (void(^)(BOOL succeeded, NSError * error)) block;

//login user
/*takes in completion block for error handling*/
/*
 completion block should handle errors in login in the user
 */
+ (void) loginUserWithUserName: (NSString *) userName andPassword: (NSString *) passWord withCompletionBlock: (void (^)(PFUser *user, NSError* error))block;

/* Store an article composed by the User
Article should already be saved, have all content added to it and correctly formatted 
 */
- (void) saveNewArticle:(Article *)article withCompletionBlock: (void(^)(BOOL succeeded, NSError * error)) block;
@end
