//
//  ExternalShare.m
//  Verbatm
//
//  Created by Damas on 5/29/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "ExternalShare.h"
#import "Channel_BackendObject.h"
#import "ParseBackendKeys.h"
#import "Page_BackendObject.h"
#import "Photo_BackendObject.h"
#import "Video_BackendObject.h"
#import "PageTypeAnalyzer.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface ExternalShare()

@property (nonatomic) NSString* link;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* caption;

@end

@implementation ExternalShare

-(instancetype) initWithCaption:(NSString *)caption {
    self.caption = caption;
    
    return self;
}

-(instancetype) init {
    
    return self;
}


-(void) sharePostToFacebook:(PFObject *)postObject  {
    
    NSString *postId = postObject.objectId;
    self.name = [[PFUser currentUser] valueForKey:VERBATM_USER_NAME_KEY];
    Channel_BackendObject *channelObj = [postObject valueForKey:POST_CHANNEL_KEY];
    NSString *channelName = [channelObj valueForKey:CHANNEL_NAME_KEY];
    
    BranchUniversalObject *branchUniversalObject = [[BranchUniversalObject alloc]initWithCanonicalIdentifier:postId];
    
    [Page_BackendObject getPagesFromPost:postObject andCompletionBlock:^(NSArray *pages){
        PFObject *po = pages[0];
        PageTypes type = [((NSNumber *)[po valueForKey:PAGE_VIEW_TYPE]) intValue];
        
        if(type == PageTypePhoto || type == PageTypePhotoVideo){
            [Photo_BackendObject getPhotosForPage:po andCompletionBlock:^(NSArray * photoObjects) {
                PFObject *photo = photoObjects[0];
                NSString *photoLink = [photo valueForKey:PHOTO_IMAGEURL_KEY];
                self.link = photoLink;
                
            }];
        } else if(type == PageTypeVideo){
            [Video_BackendObject getVideoForPage:po andCompletionBlock:^(PFObject * videoObject) {
                NSString * thumbNailUrl = [videoObject valueForKey:VIDEO_THUMBNAIL_KEY];
                self.link = thumbNailUrl;
                
            }];
        }
        
        branchUniversalObject.title = [NSString stringWithFormat:@"%@ shared a post from '%@' Verbatm blog", self.name, channelName];
        branchUniversalObject.contentDescription = @"Verbatm is a blogging app that allows users to create, curate, and consume multimedia content. Find Verbatm in the App Store!";
        
        
        branchUniversalObject.imageUrl = self.link;
        
        
        BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];
        linkProperties.feature = @"share";
        linkProperties.channel = @"facebook";
        
        
        [branchUniversalObject getShortUrlWithLinkProperties:linkProperties andCallback:^(NSString *url, NSError *error) {
            if (!error) {
                NSLog(@"got my Branch invite link to share: %@", url);
                NSURL *link = [NSURL URLWithString:url];
                if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
                    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   self.name, @"name",
                                                   self.caption, @"caption",
                                                   link, @"link",
                                                   
                                                   nil];
                    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:params HTTPMethod:@"POST"];
                    
                    
                    
                    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                        if (!error) {
                            NSLog(@"fetched user:%@", result);
                        } else {
                            NSLog(@"An error has occured %@", error);
                        }
                    }];
                } else {
                    NSLog(@"User has not granted publish_action permission");
                }
                
                
            } else {
                NSLog(@"An eerror occured %@", error);
            }
        }];
        
    }];

}
@end
