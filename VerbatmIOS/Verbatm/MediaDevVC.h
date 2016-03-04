//
//  MediaDevVC.h
//  Verbatm
//
//  Created by DERY MWINMAARONG LUCIO on 9/5/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//
//	The media dev VC controls the process of capturing media. It has a camera view, the button to
//	take pictures and record videos, as well as the logic for different effects like flash, focusing
//	and switching between selfie and regular mode.

#import <UIKit/UIKit.h>

@import Photos;

@protocol MediaDevVCDelegate <NSObject>


@end

@interface MediaDevVC : UIViewController

@property (strong, nonatomic) id<MediaDevVCDelegate> delegate;

typedef NS_ENUM(NSInteger, ContentContainerViewMode) {
	ContentContainerViewModeFullScreen,
	ContentContainerViewModeBase
};

@end
