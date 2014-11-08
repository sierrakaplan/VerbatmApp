//
//  verbatmPinchPageViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 10/5/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmPinchPageViewController.h"
#import "ILTranslucentView.h"


@interface verbatmPinchPageViewController ()
@property (weak, nonatomic) IBOutlet ILTranslucentView *blurView;//the blurred background view
@end

@implementation verbatmPinchPageViewController

//Iain
-(void) viewDidAppear:(BOOL)animated
{
    //make sure the blur is correctly formated
    [self formatBlurView];
}


//Format blurview
-(void) formatBlurView
{
    self.blurView.translucentStyle = UIBarStyleBlack;
    self.blurView.translucentAlpha = 1;
}
@end
