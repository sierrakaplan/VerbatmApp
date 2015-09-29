 //
//  verbatmMediaPageViewController.h
//  Verbatm
//
//  Created by DERY MWINMAARONG LUCIO on 9/5/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MediaDevDelegate <NSObject>

-(void) backButtonPressed;

//passes up the method to create a preview view so that preview can come over the whole ADK and main scroll view
-(void) previewPOVFromPinchViews:(NSArray *)pinchViews andCoverPic:(UIImage *)coverPic andTitle: (NSString*) title;

@end

@interface MediaDevVC : UIViewController

@property (strong, nonatomic) id<MediaDevDelegate> delegate;

-(void)alertAddTitle;
-(void)alertAddCoverPhoto;

-(void) povPublished;

typedef NS_ENUM(NSInteger, ContentContainerViewMode) {
	ContentContainerViewModeFullScreen,
	ContentContainerViewModeBase
};

@end
