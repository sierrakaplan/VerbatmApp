//
//  Like_BackendManager.m
//  Verbatm
//
//  Created by Iain Usiri on 3/20/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Like_BackendManager.h"
#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>
#import <Parse/PFQuery.h>
#import <Parse/PFCloud.h>
#import <Crashlytics/Crashlytics.h>
#import <PromiseKit/PromiseKit.h>
#import "Notification_BackendManager.h"

@implementation Like_BackendManager

+ (void)currentUserLikePost:(PFObject *) postParseObject {
	PFObject *newLikeObject = [PFObject objectWithClassName:LIKE_PFCLASS_KEY];
	[newLikeObject setObject:[PFUser currentUser]forKey:LIKE_USER_KEY];
	[newLikeObject setObject:postParseObject forKey:LIKE_POST_LIKED_KEY];
	// Will return error if like already existed - ignore
	[newLikeObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
		if(succeeded) {
			[postParseObject incrementKey:POST_NUM_LIKES];
			[postParseObject saveInBackground];
			[Notification_BackendManager createNotificationWithType:NotificationTypeLike
													  receivingUser:[postParseObject valueForKey:POST_ORIGINAL_CREATOR_KEY]
												 relevantPostObject:postParseObject];
		}
	}];
}

+ (void)currentUserStopLikingPost:(PFObject *) postParseObject {
	PFQuery * likeQuery = [PFQuery queryWithClassName:LIKE_PFCLASS_KEY];
	[likeQuery whereKey:LIKE_POST_LIKED_KEY equalTo:postParseObject];
	[likeQuery whereKey:LIKE_USER_KEY equalTo:[PFUser currentUser]];
	[likeQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
														 NSError * _Nullable error) {
		if(objects && !error) {
			// Should only be 1, but because of bugs might be more
			BOOL __block duplicate = NO;
			for (PFObject *likeObject in objects) {
				[likeObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
					if(succeeded && !duplicate) {
						duplicate = YES;
						[postParseObject incrementKey:POST_NUM_LIKES byAmount:[NSNumber numberWithInteger:-1]];
						[postParseObject saveInBackground];
					}
				}];
			}
		}
	}];
}

+ (void)getUsersWhoLikePost:(PFObject *) postParseObject withCompletionBlock:(void(^)(NSArray *))block{
    if(!postParseObject)return;
	//todo: cloud code
    PFQuery * likeQuery = [PFQuery queryWithClassName:LIKE_PFCLASS_KEY];
	likeQuery.limit = 1000;
    [likeQuery whereKey:LIKE_POST_LIKED_KEY equalTo:postParseObject];
    [likeQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                         NSError * _Nullable error) {
        if(objects && !error) {
            block(objects);
            NSMutableArray * userPromises = [[NSMutableArray alloc] init];
            NSMutableArray * userList = [[NSMutableArray alloc] init];
            for(PFObject * likeObject in objects){
                [userPromises addObject:
                    [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
                        [[likeObject valueForKey:LIKE_USER_KEY] fetchInBackgroundWithBlock:^(PFObject * _Nullable user, NSError * _Nullable error) {
                            
                            if(user){
                                [userList addObject:user];
                            }
                            resolve(nil);
                        }];
                        
                    }]
                 ];
            }
        
            PMKWhen(userPromises).then(^(id nothing) {
                block(userList);
            });
        
        
        } else {
            block(nil);
        }
    }];
}

//tests to see if the logged in user likes this post
+ (void)currentUserLikesPost:(PFObject *) postParseObject withCompletionBlock:(void(^)(bool))block {
    if(!postParseObject)return;
    //we just delete the Follow Object
    PFQuery * likeQuery = [PFQuery queryWithClassName:LIKE_PFCLASS_KEY];
    [likeQuery whereKey:LIKE_POST_LIKED_KEY equalTo:postParseObject];
    [likeQuery whereKey:LIKE_USER_KEY equalTo:[PFUser currentUser]];
    [likeQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                         NSError * _Nullable error) {
        if(objects && !error) {
            if(objects.count >= 1)block(YES);
            else block(NO);
        }
    }];
}

+(void) deleteLikesForPost:(PFObject*) postParseObject withCompletionBlock:(void(^)(BOOL)) block {
	PFQuery *likesQuery = [PFQuery queryWithClassName:LIKE_PFCLASS_KEY];
	likesQuery.limit = 1000;
	[likesQuery whereKey:LIKE_POST_LIKED_KEY equalTo:postParseObject];
	[likesQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
													NSError * _Nullable error) {
		if(objects && !error) {
			for (PFObject *likeObject in objects) {
				[likeObject deleteInBackground];
			}
			block (YES);
			return;
		}
		block (NO);
	}];
}

@end
