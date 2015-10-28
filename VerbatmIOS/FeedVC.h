//
//  feedDisplayTVC.h
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedVC : UIViewController

// animates the fact that a recent POV is publishing
-(void) showPOVPublishingWithUserName: (NSString*)userName andTitle: (NSString*) title andCoverPic: (UIImage*) coverPic
					andProgressObject:(NSProgress *)publishingProgress;

@end
