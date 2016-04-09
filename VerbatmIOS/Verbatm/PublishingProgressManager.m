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

	//let the pv's know they are being published so they can releae excess media
	for(PinchView * pv in pinchViews){
		[pv publishingPinchView];
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
			totalProgressUnits+= [(CollectionPinchView *)pinchView videoPinchViews].count > 1 ? (VIDEO_PROGRESS_UNITS + IMAGE_PROGRESS_UNITS) : 0;
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
		[self.delegate publishingComplete];
		NSNotification * not = [[NSNotification alloc]initWithName:NOTIFICATION_POST_PUBLISHED object:nil userInfo:nil];
		[[NSNotificationCenter defaultCenter] postNotification:not];
		self.progressAccountant.completedUnitCount = 0;
		self.currentlyPublishing = NO;
		self.currentParsePostObject = nil;
		self.currentPublishingChannel = nil;
		[[PostInProgress sharedInstance] clearPostInProgress];
	}];
}

-(void)mediaSavingFailed:(NSNotification *) notification {
	if(self.currentlyPublishing){
		self.progressAccountant.completedUnitCount = 0;
		[self.delegate publishingFailed];
		self.currentPublishingChannel = NULL;
		self.currentlyPublishing = NO;
	}
}

@end






