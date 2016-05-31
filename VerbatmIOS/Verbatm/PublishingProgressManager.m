//
//  PublishingProgressManager.m
//  Verbatm
//
//  Created by Iain Usiri on 2/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "PinchView.h"
#import "CollectionPinchView.h"
#import "PublishingProgressManager.h"
#import "Notifications.h"
#import "Channel_BackendObject.h"
#import "ParseBackendKeys.h"
#import "Post_Channel_RelationshipManager.h"
#import "PostInProgress.h"
#import "Page_BackendObject.h"
#import "Photo_BackendObject.h"
#import "Video_BackendObject.h"
#import "PageTypeAnalyzer.h"
#import "ExternalShare.h"

@interface PublishingProgressManager()
//how many media pieces we are trying to publish in total
@property(nonatomic)CGFloat totalMediaCount;
//how much has been published so far
//when done totalMediaSaved == totalMediaCount
@property (nonatomic) CGFloat totalMediaSavedSoFar;
@property (nonatomic, readwrite) BOOL currentlyPublishing;
//the first "domino" of parse saving
//should be made nil when saving is done or when it fails
@property (nonatomic) Channel_BackendObject * channelManager;
@property (nonatomic, readwrite) Channel* currentPublishingChannel;
@property (nonatomic, readwrite) NSProgress * progressAccountant;
@property (nonatomic) PFObject * currentParsePostObject;
@property (nonatomic) ExternalShare* es;
@property (nonatomic) BOOL shareToFB;

@end

@implementation PublishingProgressManager


+(instancetype)sharedInstance{
	static PublishingProgressManager *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[PublishingProgressManager alloc] init];
		[sharedInstance registerForNotifications];
	});
	return sharedInstance;
}

-(void)publishPostToChannel:(Channel *)channel withPinchViews:(NSArray *)pinchViews
		withCompletionBlock:(void(^)(BOOL))block {

	if (self.currentlyPublishing) {
		block (NO);
		return;
	} else {
		self.currentlyPublishing = YES;
	}

	self.channelManager = [[Channel_BackendObject alloc] init];
	[self countMediaContentFromPinchViews:pinchViews];
	if(!channel.parseChannelObject) {
		self.newChannelCreated = YES;
	}
	[self.channelManager createPostFromPinchViews:pinchViews
										toChannel:channel
							  withCompletionBlock:^(PFObject *parsePostObject) {
								  if (!parsePostObject) {
									  self.newChannelCreated = NO;
									  block (NO);
									  return;
								  }
								  self.currentParsePostObject = parsePostObject;
								  self.currentPublishingChannel = channel;
								  //todo let the pv's know they are being published so they can releae excess media
//								  for(PinchView * pinchView in pinchViews){
//									  [pinchView publishingPinchView];
//								  }
								  block(YES);
							  }];
}

-(void)publishPostToChannel:(Channel *)channel  andFacebook:(BOOL)externalShare withCaption:(NSString *)caption withPinchViews:(NSArray *)pinchViews
        withCompletionBlock:(void(^)(BOOL))block {
    
    self.es = [[ExternalShare alloc]initWithCaption:caption];
    self.shareToFB = externalShare;
   
    
    if (self.currentlyPublishing) {
        block (nil);
        return;
    } else {
        self.currentlyPublishing = YES;
    }
    
    self.channelManager = [[Channel_BackendObject alloc] init];
    [self countMediaContentFromPinchViews:pinchViews];
    if(!channel.parseChannelObject) {
        self.newChannelCreated = YES;
    }
    [self.channelManager createPostFromPinchViews:pinchViews
                                        toChannel:channel
                              withCompletionBlock:^(PFObject *parsePostObject) {
                                  if (!parsePostObject) {
                                      self.newChannelCreated = NO;
                                      block (nil);
                                      return;
                                  }
                                  self.currentParsePostObject = parsePostObject;
                                  self.currentPublishingChannel = channel;
                                  block(YES);
                                  
              }];
                    
}

-(void)registerForNotifications{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(mediaSavingFailed:)
												 name:NOTIFICATION_MEDIA_SAVING_FAILED
											   object:nil];
}

-(void)countMediaContentFromPinchViews:(NSArray *)pinchViews{
	CGFloat totalProgressUnits = INITIAL_PROGRESS_UNITS;
	for(PinchView * pinchView in pinchViews){
		if([pinchView isKindOfClass:[CollectionPinchView class]]){
			totalProgressUnits+= [(CollectionPinchView *)pinchView imagePinchViews].count * IMAGE_PROGRESS_UNITS;
			totalProgressUnits+= [(CollectionPinchView *)pinchView videoPinchViews].count > 0 ? (VIDEO_PROGRESS_UNITS + IMAGE_PROGRESS_UNITS) : 0;
		} else {
			//Saves thumbnail for every video too
			totalProgressUnits += ([pinchView isKindOfClass:[VideoPinchView class]]) ? (VIDEO_PROGRESS_UNITS + IMAGE_PROGRESS_UNITS) : IMAGE_PROGRESS_UNITS;
		}
	}
	self.progressAccountant = [NSProgress progressWithTotalUnitCount: totalProgressUnits];
	self.progressAccountant.completedUnitCount = INITIAL_PROGRESS_UNITS;
}

-(void)savingMediaFailed{
	self.currentlyPublishing = NO;
	[self.delegate publishingFailed];
}

-(void)mediaSavingProgressed:(int64_t) newProgress {
	self.progressAccountant.completedUnitCount += newProgress;
	NSLog(@"Media saving progressed %lld new units to completed %lld units of total %lld units", newProgress,
		  self.progressAccountant.completedUnitCount, self.progressAccountant.totalUnitCount);
	if (self.progressAccountant.completedUnitCount >= self.progressAccountant.totalUnitCount
		&& self.currentlyPublishing && self.currentParsePostObject) {
		[self postPublishedSuccessfully];
	}
}

-(void)postPublishedSuccessfully {
	[self.currentParsePostObject setObject:[NSNumber numberWithBool:YES] forKey:POST_COMPLETED_SAVING];
	[self.currentParsePostObject saveInBackground];
	//register the relationship
	[Post_Channel_RelationshipManager savePost:self.currentParsePostObject toChannels:[NSMutableArray arrayWithObject:self.currentPublishingChannel] withCompletionBlock:^{
        
        if(self.shareToFB){
            [self.es sharePostToFacebook:self.currentParsePostObject];
        }
        
		self.progressAccountant.completedUnitCount = 0;
		self.progressAccountant.totalUnitCount = 0;
		self.currentlyPublishing = NO;
		[[PostInProgress sharedInstance] clearPostInProgress];
		[self.delegate publishingComplete];
		NSNotification *notification = [[NSNotification alloc]initWithName:NOTIFICATION_POST_PUBLISHED object:nil userInfo:nil];
		[[NSNotificationCenter defaultCenter] postNotification: notification];
		self.currentParsePostObject = nil;
		self.currentPublishingChannel = nil;
	}];
}

//-(void) postToFacebookWithCaption:(NSString *) caption {
//    __block NSString *imageLink = nil;
//    __block NSString *videoLink = nil;
//    
//    [Page_BackendObject getPagesFromPost:self.currentParsePostObject andCompletionBlock:^(NSArray *pages){
//        PFObject *po = pages[0];
//        PageTypes type = [((NSNumber *)[po valueForKey:PAGE_VIEW_TYPE]) intValue];
//        
//        if(type == PageTypePhoto || type == PageTypePhotoVideo){
//            [Photo_BackendObject getPhotosForPage:po andCompletionBlock:^(NSArray * photoObjects) {
//                PFObject *photo = photoObjects[0];
//                NSString *photoLink = [photo valueForKey:PHOTO_IMAGEURL_KEY];
//                imageLink = photoLink;
//                
//            }];
//        } else if(type == PageTypeVideo){
//            [Video_BackendObject getVideoForPage:po andCompletionBlock:^(PFObject * videoObject) {
//                NSString * thumbNailUrl = [videoObject valueForKey:VIDEO_THUMBNAIL_KEY];
//                videoLink = thumbNailUrl;
//                
//            }];
//        }
//    }];
//    
//    NSString *name = [[PFUser currentUser] valueForKey:VERBATM_USER_NAME_KEY];
////    NSString *channelName = [self.currentPublishingChannel valueForKey:CHANNEL_NAME_KEY];
//    NSString *channelName = @"testChannel";
//    NSString *postId = self.currentParsePostObject.objectId;
//    
//    BranchUniversalObject *branchUniversalObject = [[BranchUniversalObject alloc]initWithCanonicalIdentifier:postId];
//    branchUniversalObject.title = [NSString stringWithFormat:@"%@ shared a post from '%@' Verbatm blog", name, channelName];
//    branchUniversalObject.contentDescription = @"Verbatm is a blogging app that allows users to create, curate, and consume multimedia content. Find Verbatm in the App Store!";
//    
//    if(videoLink == nil || [videoLink length] == 0){
//        branchUniversalObject.imageUrl = imageLink;
//    }else{
//        branchUniversalObject.imageUrl = videoLink;
//    }
//    //        [self.branchUniversalObject addMetadataKey:@"userId" value:@"12345"];
//    //        [self.branchUniversalObject addMetadataKey:@"userName" value:@"UserName"];
//    
//    BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];
//    linkProperties.feature = @"share";
//    linkProperties.channel = @"facebook";
//    
//    [branchUniversalObject getShortUrlWithLinkProperties:linkProperties andCallback:^(NSString *url, NSError *error) {
//        if (!error) {
//            NSLog(@"got my Branch invite link to share: %@", url);
//            NSURL *link = [NSURL URLWithString:url];
//            if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
//                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                               @"Damas", @"name",
//                                               caption, @"caption",
//                                               @"Verbatm is a blogging app that allows users to create, curate, and consume multimedia content.", @"description",
//                                               link, @"link",
//                                               
//                                               nil];
//                FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:params HTTPMethod:@"POST"];
//                
//                
//                
//                [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//                    if (!error) {
//                        NSLog(@"fetched user:%@", result);
//                    } else {
//                        NSLog(@"An error has occured %@", error);
//                    }
//                }];
//            }
//            
//        } else {
//            NSLog(@"An eerror occured %@", error);
//        }
//    }];
//
//}

-(void)mediaSavingFailed:(NSNotification *) notification {
	if(self.currentlyPublishing){
		self.progressAccountant.completedUnitCount = 0;
		[self.delegate publishingFailed];
		self.currentPublishingChannel = NULL;
		self.currentlyPublishing = NO;
	}
}

@end






