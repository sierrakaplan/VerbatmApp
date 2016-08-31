//
//  Comment.h
//  Verbatm
//
//  Created by Iain Usiri on 8/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//
//	Wrapper for comment PFObject

#import <Foundation/Foundation.h>
#import <Parse/PFObject.h>

@interface Comment : NSObject

-(instancetype)initWithParseCommentObject:(PFObject *) parseCommentObject;
-(instancetype)initWithString:(NSString *) comment andPostObject:(PFObject *) postObject;

@property (nonatomic) NSString * commentString;

-(void)getCommentCreatorWithCompletionBlock:(void(^)(NSString *)) block;

@end
