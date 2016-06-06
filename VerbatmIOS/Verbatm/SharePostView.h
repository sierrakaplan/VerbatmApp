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

@protocol SharePostViewDelegate <NSObject>

-(void) cancelButtonSelected;
-(void) reblogToVerbatm:(BOOL)verbatm andFacebook:(BOOL)facebook;

@end

@interface SharePostView : UIView

-(instancetype) initWithFrame:(CGRect)frame;

@property (nonatomic, weak) id <SharePostViewDelegate> delegate;

@end
