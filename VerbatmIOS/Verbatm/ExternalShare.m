//
//  ExternalShare.m
//  Verbatm
//
//  Created by Damas on 5/29/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//
#import "Channel_BackendObject.h"
#import <Crashlytics/Crashlytics.h>

#import "ExternalShare.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "ParseBackendKeys.h"
#import "Page_BackendObject.h"
#import "Photo_BackendObject.h"
#import "PageTypeAnalyzer.h"

#import <Social/SLRequest.h>
#import "StringsAndAppConstants.h"

#import "Video_BackendObject.h"


@interface ExternalShare()
@property (nonatomic) NSCondition *storeLinkCondition;
@property (nonatomic) NSString* link;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* caption;
@property (nonatomic) BOOL aquiredURLSuccesfully;
@property (nonatomic) BOOL waitingForUrlBranchResponse;

@end

@implementation ExternalShare

-(instancetype) initWithCaption:(NSString *)caption {
    self.caption = caption;
    return self;
}

-(instancetype) init {
    
    return self;
}

-(void)storeShareLinkToPost:(PFObject *)postObject withCaption:(NSString *) caption withCompletionBlock:(void(^)(bool, PFObject *))block {

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
                [self storeLinkWithCaption:caption  channelName:channelName postObject:postObject andBranchUniversalObject:branchUniversalObject withCompletionBlock:block];
            }];
        } else if(type == PageTypeVideo){
            [Video_BackendObject getVideoForPage:po andCompletionBlock:^(PFObject * videoObject) {
                NSString * thumbNailUrl = [videoObject valueForKey:VIDEO_THUMBNAIL_KEY];
                self.link = thumbNailUrl;
                [self storeLinkWithCaption:caption channelName:channelName  postObject:postObject andBranchUniversalObject:branchUniversalObject withCompletionBlock:block];
            }];
        }
    }];
    
}


-(void)storeLinkWithCaption:(NSString *) caption channelName:(NSString *) channelName postObject:(PFObject *) postObject andBranchUniversalObject: (BranchUniversalObject*) branchUniversalObject withCompletionBlock:(void(^)(bool, PFObject *))block {

    NSString * title = [NSString stringWithFormat:@"%@ posted on their Verbatm blog : %@!", self.name, channelName];
	branchUniversalObject.title = title;
    branchUniversalObject.contentDescription = VERBATM_DESCRIPTION;
    branchUniversalObject.imageUrl = self.link;
    
    BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];
    linkProperties.feature = @"share";
    // we say facebook but the link can be shared anywhere
    linkProperties.channel = @"facebook";
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //we are going to try to get the link 10 times -- at least one should work
        for (int i = 0; i < 10; i ++){
            [self.storeLinkCondition lock];
            self.waitingForUrlBranchResponse = YES;
            [self.storeLinkCondition unlock];
            [branchUniversalObject getShortUrlWithLinkProperties:linkProperties andCallback:^(NSString *url, NSError *error) {
                [self.storeLinkCondition lock];
                if (!error) {
                    self.aquiredURLSuccesfully = YES;
//                    NSLog(@"Successfully acquired my Branch invite link to share: %@", url);
                    //we save the link to the PFObject
                    [postObject setObject:url forKey:POST_SHARE_LINK];
                    [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if(block) block(succeeded, postObject);
                    }];
                } else {
                    self.aquiredURLSuccesfully = NO;
					[[Crashlytics sharedInstance] recordError:error];
//                    NSLog(@"An error occured %@", error);
                }
                self.waitingForUrlBranchResponse = NO;
                [self.storeLinkCondition unlock];
            }];
            
            
            //stop the thread and wait to be woken by the other thread
            //not really how you're supposed to use locks though
            [self.storeLinkCondition lock];
            while(self.waitingForUrlBranchResponse){
                [self.storeLinkCondition wait];
            }
            [self.storeLinkCondition unlock];
            
            //on success get out of this loop
            if(self.aquiredURLSuccesfully){
                break;
            }
        }
        //call the block and tell them that saving failed
        if(block)block(NO, postObject);
    });
    
}



-(void) sharePostLink: (NSString *) url  toPlatform:(SelectedPlatformsToShareLink) platform {
    switch (platform) {
        case shareToTwitter:
            [self sharePostToTwitter:url];
        case shareToFacebook:
           //facebook not working right now
            //[self sharePostToFacebook:url];
            break;
        default:
//            [self sharePostToTwitter:url];
//            [self sharePostToFacebook:url];
            break;
    }
}


-(void)sharePostToTwitter:(NSString *)url{

        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:
                                      ACAccountTypeIdentifierTwitter];
    
        [account requestAccessToAccountsWithType:accountType options:nil
                                      completion:^(BOOL granted, NSError *error)
         {
             if (granted == YES)
             {
                 NSArray *arrayOfAccounts = [account
                                             accountsWithAccountType:accountType];
    
                 if ([arrayOfAccounts count] > 0)
                 {
                     ACAccount *twitterAccount = [arrayOfAccounts lastObject];
    
                     NSURL *requestURL2 = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
                     NSDictionary *message2 = @{@"status": url};
                     SLRequest *postRequest2 = [SLRequest
                                                requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:SLRequestMethodPOST
                                                URL:requestURL2 parameters:message2];
                     postRequest2.account = twitterAccount;
    
                     [postRequest2
                      performRequestWithHandler:^(NSData *responseData,
                                                  NSHTTPURLResponse *urlResponse, NSError *error)
                      {
                          // DONE!!!
                      }];
                 }
             }
         }];
}

-(void)sharePostToFacebook:(NSString *)url{
//    NSLog(@"got my Branch invite link to share: %@", url);
    NSURL *link = [NSURL URLWithString:url];
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                       self.name, @"name",
//                                       self.caption, @"caption",
                                       link, @"link",
                                       
                                       nil];
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:params HTTPMethod:@"POST"];
        
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
//                NSLog(@"fetched user:%@", result);
            } else {
				[[Crashlytics sharedInstance] recordError:error];
            }
        }];
        
    } else {
        NSLog(@"User has not granted publish_action permission");
    }

}


-(NSCondition *)storeLinkCondition{
    if(!_storeLinkCondition)_storeLinkCondition=[[NSCondition alloc] init];
    return _storeLinkCondition;
}


@end
