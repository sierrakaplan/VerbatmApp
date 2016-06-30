//
//  SharePostView.h
//  Verbatm
//
//  Created by Iain Usiri on 1/2/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//
//	Presents the user with options to share the the post they are seeing either
//	to their social media or to Verbatm.

#import <UIKit/UIKit.h>
#import "Channel.h"
#import "SelectSharingOption.h"


/*
 Reblog screen. Selected on a post and slides up to prompt a user to share.
 */

@protocol SharePostViewDelegate <NSObject>

-(void) cancelButtonSelected;

@optional
-(void) shareToShareOption:(ShareOptions) shareOption;

@end

@interface SharePostView : UIView

-(instancetype) initWithFrame:(CGRect)frame;

@property (nonatomic, weak) id <SharePostViewDelegate> delegate;

@end
