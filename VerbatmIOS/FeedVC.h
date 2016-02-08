//
//  feedDisplayTVC.h
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FeedVCDelegate <NSObject>

-(void) showTabBar: (BOOL) show;
-(void)feedPovShareButtonSeletedForPOV:(PovInfo *) pov;
-(void)feedPovLikeLiked:(BOOL) liked forPOV:(PovInfo *) pov;

@end

@interface FeedVC : UIViewController

@property (strong, nonatomic) id<FeedVCDelegate> delegate;

// animates the fact that a recent POV is publishing
-(void) showPOVPublishingWithUserName: (NSString*)userName andTitle: (NSString*) title
					andProgressObject:(NSProgress *)publishingProgress;




@end
