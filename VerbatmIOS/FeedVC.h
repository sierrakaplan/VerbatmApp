//
//  feedDisplayTVC.h
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FeedVCDelegate <NSObject>
-(void) profileButtonPressed;
-(void) adkButtonPressed;
-(void) displayPOVWithIndex:(NSInteger)index fromLoadManager:(POVLoadManager *)loadManager;
@end

@interface FeedVC : UIViewController

@property(strong, nonatomic) id<FeedVCDelegate> delegate;

// animates the fact that a recent POV is publishing
-(void) showPOVPublishingWithTitle: (NSString*) title andCoverPic: (UIImage*) coverPic;

//Makes sure selected cell is deselected (resets formatting for it)
-(void) deSelectCell;

@end
