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
@end

@interface FeedVC : UIViewController

@property(strong, nonatomic) id<FeedVCDelegate> delegate;

-(void) refreshFeed;

@end
