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
	});
	return sharedInstance;
}

// Blocks is publishing something else, no network
-(void)publishPostToChannel:(Channel *)channel andFacebook:(BOOL)externalShare withCaption:(NSString *)caption withPinchViews:(NSArray *)pinchViews
		withCompletionBlock:(void(^)(BOOL, BOOL))block {
    
    self.es = [[ExternalShare alloc]initWithCaption:caption];
    self.shareToFB = externalShare;

	if (self.currentlyPublishing) {
		block (YES, NO);
		return;
	} else {
		self.currentlyPublishing = YES;
	}

	self.channelManager = [[Channel_BackendObject alloc] init];
	[self countMediaContentFromPinchViews:pinchViews];
	[self.channelManager createPostFromPinchViews:pinchViews
										toChannel:channel
							  withCompletionBlock:^(PFObject *parsePostObject) {
								  if (!parsePostObject) {
									  block (NO, YES);
									  return;
								  }
								  self.currentParsePostObject = parsePostObject;
								  self.currentPublishingChannel = channel;
								  block(NO, NO);
							  }];
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

-(void)savingMediaFailedWithError:(NSError*)error {
	self.progressAccountant.completedUnitCount = 0;
	self.currentPublishingChannel = NULL;
	self.currentlyPublishing = NO;
	self.currentlyPublishing = NO;
	[self.delegate publishingFailedWithError:error];
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

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end






