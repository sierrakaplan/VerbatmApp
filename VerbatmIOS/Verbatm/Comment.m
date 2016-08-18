//
//  Comment.m
//  Verbatm
//
//  Created by Iain Usiri on 8/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel.h"

#import "Comment.h"
#import "Commenting_BackendObject.h"
#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>
#import "UserManager.h"

@interface Comment ()
@property (nonatomic) PFObject * parseCommentObject;
@property (nonatomic) PFObject * parsePostObject;
@property (nonatomic) NSString * commentCreatorName;
@end

@implementation Comment

-(instancetype)initWithParseCommentObject:(PFObject *) parseCommentObject{
    self = [super init];
    if(self){
        self.parseCommentObject = parseCommentObject;
    }
    return  self;
}
-(instancetype)initWithString:(NSString *) comment andPostObject:(PFObject *) postObject{
    self = [super init];
    if(self){
        [self setCommentString:comment];
        [Commenting_BackendObject storeComment:comment forPost:postObject];
    }
    return  self;
}


-(NSString *)commentString{
    if(self.parseCommentObject){
        return [self.parseCommentObject valueForKey:COMMENT_STRING];
    }
    return _commentString;
}

-(void)getCommentCreatorWithCompletionBlock:(void (^)(NSString *))block{
    
    if(self.parseCommentObject){
        PFUser * creator = [self.parseCommentObject valueForKey:COMMENT_USER_KEY];
        [creator fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if(object){
                block([object valueForKey:VERBATM_USER_NAME_KEY]);
            }else{
                block(@"");
            }
        }];
    }else{
       //this will only happen if the current user is the creator and we are saving their post
        block([[PFUser currentUser] valueForKey:VERBATM_USER_NAME_KEY]);
    }
}


@end
