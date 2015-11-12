 //
//  verbatmMediaPageViewController.h
//  Verbatm
//
//  Created by DERY MWINMAARONG LUCIO on 9/5/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

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
