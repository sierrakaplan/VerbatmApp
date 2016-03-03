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

-(void)countMediaContentFromPinchViews:(NSArray *)pinchViews{
    CGFloat totalProgressUnits = 0.f;
    for(PinchView * pv in pinchViews){
        if([pv isKindOfClass:[CollectionPinchView class]]){
            totalProgressUnits+= [(CollectionPinchView *)pv getNumPinchViews];
        }else{
            totalProgressUnits += [pv getTotalPiecesOfMedia];
        }
    }
    self.progressAccountant = [NSProgress progressWithTotalUnitCount: totalProgressUnits];
}

-(void)savingMediaFailed{
    self.currentlyPublishing = NO;
    [self.delegate publishingFailed];
}

-(BOOL)publishPostToChannel:(Channel *)channel withPinchViews:(NSArray *)pinchViews {
    
    if (self.currentlyPublishing) {
        return NO;
    } else {
        self.currentlyPublishing = YES;
    }
    
    self.channelManager = [[Channel_BackendObject alloc] init];
	[self countMediaContentFromPinchViews:pinchViews];
	Channel* newChannel = [self.channelManager createPostFromPinchViews:pinchViews              toChannel:channel withCompletionBlock:^(PFObject * parsePostObject) {
        
        self.currentParsePostObject = parsePostObject;
        
    }];
    if(channel.parseChannelObject){
		self.currentPublishingChannel = channel;
    } else {
		self.currentPublishingChannel = newChannel;
		self.newChannelCreated = YES;
	}
    return YES;
}


-(void)registerForNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaHasSaved:)
                                                 name:NOTIFICATION_MEDIA_SAVING_SUCCEEDED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaHasFailedSaving:)
                                                 name:NOTIFICATION_MEDIA_SAVING_FAILED
                                               object:nil];
}



-(void)mediaHasSaved:(NSNotification *) notification {
    self.progressAccountant.completedUnitCount ++;
	if (self.progressAccountant.completedUnitCount == self.progressAccountant.totalUnitCount && self.currentlyPublishing) {
        if(self.currentParsePostObject) {
            [self.currentParsePostObject setObject:[NSNumber numberWithBool:YES] forKey:POST_COMPLETED_SAVING];
            [self.currentParsePostObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded){
                    [self.delegate publishingComplete];
                    self.currentPublishingChannel = NULL;
                    self.currentParsePostObject = nil;
                    self.currentlyPublishing = NO;
                }
            }];
        }
	}
}

-(void)mediaHasFailedSaving:(NSNotification *) notification {
    if(self.currentlyPublishing){
        self.progressAccountant.completedUnitCount = 0;
        [self.delegate publishingFailed];
        self.currentPublishingChannel = NULL;
        self.currentlyPublishing = NO;
    }
}

@end






