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



typedef enum
{
    shareToFacebook = 1,
    shareToTwitter = 2,
    bothFacebookAndTwitter = 3
} SelectedPlatformsToShareLink;

@interface ExternalShare : NSObject

-(instancetype) initWithCaption:(NSString *) caption;
-(instancetype) init;

-(void)storeShareLinkToPost:(PFObject *)postObject withCaption:(NSString *) caption withCompletionBlock:(void(^)(bool, PFObject *))block ;

-(void) sharePostLink: (NSString *) url  toPlatform:(SelectedPlatformsToShareLink) platform ;
@end
