//
//  Commenting_BackendObject.h
//  Verbatm
//
//  Created by Iain Usiri on 8/16/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/PFObject.h>
/*
 Used to get and store comment objects from the database
 */

@interface Commenting_BackendObject : NSObject
+(void)getCommentsForObject:(PFObject *) postParseObject withCompletionBlock:(void(^)(NSArray *))block;
+(void)storeComment:(NSString *) commentString forPost:(PFObject *) postParseObject;
@end
