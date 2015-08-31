//
//  testerTransitionDelegate.m
//  Verbatm
//
//  Created by Iain Usiri on 9/20/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "testerTransitionDelegate.h"
#import "testerAnimation.h"

@implementation testerTransitionDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    testerAnimation *transitioning = [testerAnimation new];
    return transitioning;
}


- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    testerAnimation *transitioning = [testerAnimation new];
    transitioning.reverse = YES;
    return transitioning;
}
@end
