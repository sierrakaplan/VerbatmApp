//
//  PublishingProgressManager.h
//  Verbatm
//
//  Created by Iain Usiri on 2/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Channel.h"
/*
 Manages the publishing of content (by starting the parse domino effect)
 but is mainly used to track progress and to notify relevant ui. Because you can
 only publish one post at a time and because we only have one publishing UI bar
 we simply rely on a delegate to communite progress completion.
 You track the NSProgress Accountant to see how far we're progressing with media saving.
 */


@protocol PublishingProgressProtocol <NSObject>

//scale is  0-1
-(void)postPublishProgressAt:(NSProgress *) progress;
-(void)publishingComplete;
-(void)publishingFailed;
@end

@interface PublishingProgressManager : NSObject
+(instancetype)sharedInstance;
//the returns NO if there is publishing taking place already or if there is not internet TODO
-(BOOL)publishPostToChannel:(Channel *) channel withPinchViews:(NSArray *)pinchViews;
-(void)registerForNotifications;
@property (nonatomic) id<PublishingProgressProtocol> delegate;
@property (nonatomic, readonly) NSProgress * progressAccountant;

@end








