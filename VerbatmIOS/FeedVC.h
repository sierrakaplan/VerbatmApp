//
//  feedDisplayTVC.h
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//


// DEPRECATED: TODO: DELETE

#import <UIKit/UIKit.h>
#import <Parse/PFObject.h>

@protocol FeedVCDelegate <NSObject>

-(void) showTabBar: (BOOL) show;

@end

@interface FeedVC : UIViewController

@property (weak, nonatomic) id<FeedVCDelegate> delegate;

-(void) addPostListVC;

@end
