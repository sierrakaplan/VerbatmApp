 //
//  VerbatmUser.m
//  Verbatm
//
//  Created by Iain Usiri on 8/16/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "VerbatmUser.h"
#import "Article.h"

/*Reviewed by: Lucio*/
//
/*This class does not handle saving errors properly- to be reviewed further
 */

@interface VerbatmUser () <PFSubclassing>
@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSNumber * phoneNumber;
@property (nonatomic, strong) NSString * status;
@property (nonatomic) BOOL advancedUser;
@property (nonatomic, strong) PFRelation * followingRelationship;
@property (nonatomic, strong) PFRelation * endorsingRelationship;
@property (nonatomic, strong) PFRelation * likeRelationship;
@property (nonatomic, strong) PFRelation * articles;

#define FOLLOW @"follows"
#define ARTICLES @"articles"
#define ENDORSE @"endorsements"
#define LIKE @"likes"


@end

@implementation VerbatmUser

@dynamic firstName;
@dynamic lastName;
@dynamic phoneNumber;
@dynamic status;
@dynamic advancedUser;

/* note: Seems we need to assign them instance variables in order to initialise them.
 The @dynamic system for parse doesn't call relationForKey*/
@synthesize followingRelationship = _followingRelationship;
@synthesize endorsingRelationship = _endorsingRelationship;
@synthesize likeRelationship = _likeRelationship;
@synthesize articles = _articles;

#pragma mark - lazy instantiation of relationships
-(PFRelation *) followingRelationship
{
    if(!_followingRelationship) _followingRelationship = [self relationForKey:FOLLOW];
    return _followingRelationship;
}
-(PFRelation *) endorsingRelationship
{
    if(!_endorsingRelationship) _endorsingRelationship= [self relationForKey:ENDORSE];
    return _endorsingRelationship;
}
-(PFRelation *) likeRelationship
{
    if(!_likeRelationship) _likeRelationship = [self relationForKey:LIKE];
    return _likeRelationship;
}
-(PFRelation *) articles
{
    if(!_articles)_articles = [self relationForKey:ARTICLES];
    return _articles;
}


#pragma mark - create new verbatm user
/*Author: Iain Usiri*/
/*returns nil if something went wrong saving*/
- (VerbatmUser *) initWithUserName: (NSString *) userName
                      FirstName: (NSString *) firstName
                       LastName: (NSString *) lastName
                          Email: (NSString *) email
                    PhoneNumber: (NSNumber *) phoneNumber
                       Password: (NSString *) password
         withSignUpCompletionBlock: (void(^)(BOOL succeeded, NSError *error)) block

{
    if((self=[super init])){
        /*Checking data format validity.
        Ensure phone number has no letters (Implicit with NSNumber)*/
        
        //ensure firstName and lastName are different
        if([firstName isEqualToString:lastName]) return Nil;
        
        //ensure email contains an @
        NSRange stringRange = [email rangeOfString:@"@"];
        if(stringRange.location == NSNotFound) return Nil;
        
        //Save User object
        self.email = email;
        self.username= userName;
        self.password = password;
        self.firstName = firstName;
        self.lastName= lastName;
        self.phoneNumber = phoneNumber;
        self.advancedUser = YES;//everyone is an advanced user for now (testing)
        [self signUpInBackgroundWithBlock:block];
    }
    //return user if everything passes - nil if it doesn't
    return self;
}


#pragma mark- relationships
/*Author: Iain Usiri*/
/*
 completion block should handle errors in saving the relationship
 */
-(void) followUser:(VerbatmUser *)toFollowed withCompletionBlock: (void(^)(BOOL succeeded, NSError *error)) block
{
    if(self==toFollowed) return;//can't follow yourself
    if([PFUser currentUser] != self)return; //make sure to only save to the logged in User
    self.followingRelationship = [self relationForKey:FOLLOW];
    [self.followingRelationship addObject:toFollowed];
    [self saveInBackgroundWithBlock:block];
}


/*Author: Iain Usiri*/
//Still needs editing- not sure how to handle saving errors yet
-(void) setCurrentStatus: (NSString *) status withCompletionBlock: (void(^)(BOOL succeeded, NSError *error)) block
{
    //check character length limit (to be determined)
    
    //set status and save
    if(!status)self.status = status;
    [self saveInBackgroundWithBlock: block];
}

/*Author: Iain Usiri*/
//Register that a user likes an article.
//Takes the user liking and the aricle being liked.
-(void) likeArticle: (Article *) article withCompletionBlock: (void(^)(BOOL succeeded, NSError *error)) block
{
    [self.likeRelationship addObject:article];
    [self saveInBackgroundWithBlock: block];
}

/*Author: Iain Usiri*/
/*Only Advanced Users can endorse other User accounts*/
-(void) endorseUser: (VerbatmUser *) user withCompletionBlock: (void(^)(BOOL succeeded, NSError * error)) block
{
    //Check if the person endorsing has permission to do so (is an Advanced User)
    if(!self.advancedUser) return; //for now everyone is an advanced user
    //The person endorsing records who he is endorsing as an endorsement
    [self.endorsingRelationship addObject:user];
    [self saveInBackgroundWithBlock:block];
}

/*Author: Iain Usiri*/
//Save a new article from a user
//Article should have all content added to it and correctly formatted
//note must save the relationship of the article afterwards
- (void) saveNewArticle:(Article *)article withCompletionBlock: (void(^)(BOOL succeeded, NSError * error)) block
{
    
}

/*Author: Iain Usiri*/
/*takes in completion block for error handling*/
+ (void) loginUserWithUserName: (NSString *) userName andPassword: (NSString *) passWord withCompletionBlock: (void (^)(PFUser *user, NSError* error))block;
{
    [VerbatmUser logInWithUsernameInBackground:userName password:passWord block:block];
}


#pragma mark - required subclassing method
/*Author: Iain Usiri*/
+(void)load{
    [self registerSubclass];
}

@end
