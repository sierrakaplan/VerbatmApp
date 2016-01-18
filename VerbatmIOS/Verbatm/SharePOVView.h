//
//  SharePOVView.h
//  Verbatm
//
//  Created by Iain Usiri on 1/2/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"
/*
 Presents the user with options to share the the post they are seeing either
 to their social media or to Verbatm.
 */


@protocol SharePOVViewDelegate <NSObject>
-(void)cancelButtonSelected;//tells the superview to remove the current presented view
-(void)postPOVToChannel:(Channel *) channel;
-(void)sharePostWithComment:(NSString *) comment;
@end



@interface SharePOVView : UIView
-(instancetype) initWithFrame:(CGRect)frame andChannels:(NSArray *) userChannels shouldStartOnChannels:(BOOL) showChannels;//this tells us if we should show

@property (nonatomic) id <SharePOVViewDelegate> delegate;
@end
