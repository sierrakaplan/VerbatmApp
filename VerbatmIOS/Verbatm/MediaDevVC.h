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

-(void) povPublishedWithUserName:(NSString*)userName andTitle:(NSString*)title andCoverPic:(UIImage*)coverPhoto andProgressObject:(NSProgress*)progress;

@end

@interface MediaDevVC : UIViewController

@property (strong, nonatomic) id<MediaDevVCDelegate> delegate;

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
