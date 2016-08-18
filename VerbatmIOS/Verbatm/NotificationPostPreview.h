//
//  NotificationPostPreview.h
//  Verbatm
//
//  Created by Iain Usiri on 7/6/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostView.h"
#import <Parse/PFObject.h>

@protocol NotificationPostPreviewProtocol <NSObject>

-(void)exitPreview;
-(void)presentCommentListForPost:(PFObject *)post;

@end

@interface NotificationPostPreview : UIView

-(void)clearViews;
-(void)presentPost:(PFObject *) post andChannel:(Channel *) channel;
@property (nonatomic, weak) id<NotificationPostPreviewProtocol> delegate;

@end
