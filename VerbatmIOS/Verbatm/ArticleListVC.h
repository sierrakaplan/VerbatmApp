//
//  verbatmArticleListControlerViewController.h
//  Verbatm
//
//  Created by Iain Usiri on 4/6/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PovInfo;
@class POVLoadManager;
@class FeedTableViewCell;

@protocol ArticleListVCDelegate <NSObject>

-(void) displayPOVOnCell:(FeedTableViewCell *)cell withLoadManager:(POVLoadManager *)loadManager;
-(void) failedToRefreshFeed;
@end

@interface ArticleListVC : UIViewController
@property (strong, nonatomic) id<ArticleListVCDelegate> delegate;

// sets the load manager from which to load the povs and the background color of the cells
-(void) setPovLoadManager:(POVLoadManager *) povLoader andCellBackgroundColor: (UIColor*) cellBackgroundColor ;

-(void) showPOVPublishingWithUserName: (NSString*)userName andTitle: (NSString*) title
						  andProgressObject: (NSProgress*) publishingProgress;

// Notify cell to update its appearance based on the current user liking or unliking it
-(void) userHasLikedPOV: (BOOL) liked withPovInfo: (PovInfo*) povInfo;

@end
