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

-(void) setPovLoadManager:(POVLoadManager *)povLoader;

-(void) showPOVPublishingWithUserName: (NSString*)userName andTitle: (NSString*) title
						  andCoverPic: (UIImage*) coverPic andProgressObject: (NSProgress*) publishingProgress;

// Notify cell to update its appearance based on the current user liking or unliking it
-(void) userHasLikedPOV: (BOOL) liked withPovInfo: (PovInfo*) povInfo;

@end
