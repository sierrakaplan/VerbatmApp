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

@interface PublishingProgressManager()
//how many media pieces we are trying to publish in total
@property(nonatomic)CGFloat totalMediaCount;
//how much has been published so far
//when done totalMediaSaved == totalMediaCount
@property (nonatomic) CGFloat totalMediaSavedSoFar;
@property (nonatomic) BOOL currentlyPublishing;
//the first "domino" of parse saving
//should be made nil when saving is done or when it fails
@property (nonatomic) Channel_BackendObject * currentPublishingChannel;
@property (nonatomic, readwrite) NSProgress * progressAccountant;
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

-(BOOL)publishPostToChannel:(Channel *) channel withPinchViews:(NSArray *)pinchViews {
    
    if(self.currentlyPublishing){
        return NO;
    }else{
        self.currentlyPublishing = YES;
    }
    
    self.currentPublishingChannel = [[Channel_BackendObject alloc] init];
    if(channel){
        [self countMediaContentFromPinchViews:pinchViews];
        channel = [self.currentPublishingChannel createPostFromPinchViews:pinchViews toChannel:channel];
        if(channel){
            //notify the profile that a new channel is created-- TODO
        }
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
    [self.delegate postPublishProgressAt:self.progressAccountant];
}

-(void)mediaHasFailedSaving:(NSNotification *) notification {
    self.progressAccountant.completedUnitCount = 0;
    [self.delegate publishingFailed];
}

@end






