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
@implementation Like_BackendManager

+(void)currentUserLikePost:(PFObject *) postParseObject{
    
    NSNumber * currentLikes = [postParseObject valueForKey:POST_LIKES_NUM_KEY];
    int likes = currentLikes.intValue;
    likes++;
    [postParseObject setValue:[NSNumber numberWithInt:likes] forKey:POST_LIKES_NUM_KEY];
    
    //we first save the number on the post then we save the relationship in our table
    [postParseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            PFObject * newFollowObject = [PFObject objectWithClassName:LIKE_PFCLASS_KEY];
            [newFollowObject setObject:[PFUser currentUser]forKey:LIKE_USER_KEY];
            [newFollowObject setObject:postParseObject forKey:LIKE_POST_LIKED_KEY];
            [newFollowObject saveInBackground];
        }
    }];
   
}




+(void)currentUserStopLikingPost:(PFObject *) postParseObject{
    
    NSNumber * currentLikes = [postParseObject valueForKey:POST_LIKES_NUM_KEY];
    int likes = currentLikes.intValue;
    likes--;
    if(likes < 0) likes = 0;
    
    [postParseObject setValue:[NSNumber numberWithInt:likes] forKey:POST_LIKES_NUM_KEY];
    
    //we first save the number on the post then we save the relationship in our table
    [postParseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            PFQuery * userChannelQuery = [PFQuery queryWithClassName:LIKE_PFCLASS_KEY];
            [userChannelQuery whereKey:LIKE_POST_LIKED_KEY equalTo:postParseObject];
            [userChannelQuery whereKey:LIKE_USER_KEY equalTo:[PFUser currentUser]];
            [userChannelQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                                 NSError * _Nullable error) {
                if(objects && !error) {
                    if(objects.count){
                        PFObject * followObj = [objects firstObject];
                        [followObj deleteInBackground];
                    }
                }
            }];
        }
    }];
}

//tests to see if the logged in user follows this channel
+(void)currentUserLikesPost:(PFObject *) postParseObject withCompletionBlock:(void(^)(bool))block{
    if(!postParseObject)return;
    //we just delete the Follow Object
    PFQuery * userChannelQuery = [PFQuery queryWithClassName:LIKE_PFCLASS_KEY];
    [userChannelQuery whereKey:LIKE_POST_LIKED_KEY equalTo:postParseObject];
    [userChannelQuery whereKey:LIKE_USER_KEY equalTo:[PFUser currentUser]];
    [userChannelQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                         NSError * _Nullable error) {
        if(objects && !error) {
            if(objects.count == 1)block(YES);
            else block(NO);
        }
    }];
    

}



@end
