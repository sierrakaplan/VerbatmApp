//
//  Commenting_BackendObject.m
//  Verbatm
//
//  Created by Iain Usiri on 8/16/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Commenting_BackendObject.h"
#import "Comment.h"
#import "Notification_BackendManager.h"

#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>
#import <Parse/PFQuery.h>

@implementation Commenting_BackendObject

+(void)getCommentsForObject:(PFObject *) postParseObject withCompletionBlock:(void(^)(NSArray *))block{
    
    PFQuery * commentQuery = [PFQuery queryWithClassName:COMMENT_PFCLASS_KEY];
    commentQuery.limit = 1000;
    [commentQuery whereKey:COMMENT_POSTCOMMENTED_KEY equalTo:postParseObject];
    [commentQuery orderByAscending:@"createdAt"];
    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects,
                                                  NSError * _Nullable error) {
        if(objects && !error) {
            NSMutableArray * finalComments = [[NSMutableArray alloc] initWithCapacity:objects.count];
            
            for(PFObject * parseComment in objects){
                [finalComments addObject:[[Comment alloc] initWithParseCommentObject:parseComment]];
            }
            block(finalComments);
            
        } else {
            block(nil);
        }
    }];
}


+(void)storeComment:(NSString *) commentString forPost:(PFObject *) postParseObject{
    PFObject *newComment = [PFObject objectWithClassName:COMMENT_PFCLASS_KEY];
    [newComment setObject:[PFUser currentUser]forKey:COMMENT_USER_KEY];
    [newComment setObject:postParseObject forKey:COMMENT_POSTCOMMENTED_KEY];
    [newComment setObject:commentString forKey:COMMENT_STRING];
    
    // Will return error if comment already existed - ignore
    [newComment saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded) {
            [postParseObject incrementKey:POST_NUM_COMMENTS];
            [postParseObject saveInBackground];
            [Notification_BackendManager createNotificationWithType:NewComment receivingUser:[postParseObject valueForKey:POST_ORIGINAL_CREATOR_KEY] relevantPostObject:postParseObject];
        }
    }];
}


@end
