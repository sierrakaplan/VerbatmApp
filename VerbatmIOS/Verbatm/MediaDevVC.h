 //
//  verbatmMediaPageViewController.h
//  Verbatm
//
//  Created by DERY MWINMAARONG LUCIO on 9/5/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Photos;

@interface MediaDevVC : UIViewController

// Shows alert to the user that they must add title to their story
-(void)alertAddTitle;

// Shows alert to the user that they must add a cover picture to their story
-(void)alertAddCoverPhoto;

// Cleans up the adk after a story has published
-(void)povPublished;

typedef NS_ENUM(NSInteger, ContentContainerViewMode) {
	ContentContainerViewModeFullScreen,
	ContentContainerViewModeBase
};

@end
