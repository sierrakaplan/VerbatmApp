//
//  ExternalShare.h
//  Verbatm
//
//  Created by Damas on 5/29/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Branch/BranchUniversalObject.h>
#import <Branch/BranchLinkProperties.h>
#import <Parse/PFObject.h>

@interface ExternalShare : NSObject

-(instancetype) initWithCaption:(NSString *) caption;
-(instancetype) init;

-(BranchUniversalObject *) generateShareObjectForPost:(PFObject *)postObject;
-(void) sharePostToFacebook:(PFObject *)postObject;

@end
