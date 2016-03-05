//
//  feedDisplayTVC.h
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/PFObject.h>
@protocol FeedVCDelegate <NSObject>

-(void) showTabBar: (BOOL) show;
-(void) shareButtonSelectedForPostObject: (PFObject* ) post;
-(void) likeButtonLiked:(BOOL) liked forPostObject: (PFObject* ) post;

@end

@interface FeedVC : UIViewController

@property (strong, nonatomic) id<FeedVCDelegate> delegate;

@end
