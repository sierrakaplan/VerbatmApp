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
			totalProgressUnits+= [(CollectionPinchView *)pinchView videoPinchViews].count * VIDEO_PROGRESS_UNITS;
		} else {
			totalProgressUnits += ([pinchView isKindOfClass:[VideoPinchView class]]) ? VIDEO_PROGRESS_UNITS : IMAGE_PROGRESS_UNITS;
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
	if (self.progressAccountant.completedUnitCount >= self.progressAccountant.totalUnitCount && self.currentlyPublishing) {
		if(self.currentParsePostObject) {
			[self.currentParsePostObject setObject:[NSNumber numberWithBool:YES] forKey:POST_COMPLETED_SAVING];
			[self.currentParsePostObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
				if(succeeded){
					//register the relationship
					[Post_Channel_RelationshipManager savePost:self.currentParsePostObject  toChannels:[NSMutableArray arrayWithObject:self.currentPublishingChannel]withCompletionBlock:^{
						[self.delegate publishingComplete];
						self.currentPublishingChannel = NULL;
						self.currentParsePostObject = nil;
						self.currentlyPublishing = NO;
					}];
				}
			}];
		}
	}
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






