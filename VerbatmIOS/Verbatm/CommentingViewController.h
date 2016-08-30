//
//  CommentingViewController.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 8/30/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//
//	Displays the comments and keyboard to allow user to add another one.

#import <UIKit/UIKit.h>

@interface CommentingViewController : UIViewController

-(void)presentCommentsForPost:(PFObject *)post;

@end
