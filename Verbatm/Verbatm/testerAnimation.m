//
//  testerAnimation.m
//  Verbatm
//
//  Created by Iain Usiri on 9/20/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "testerAnimation.h"

static NSTimeInterval const DETAnimatedTransitionDuration = 0.5f;
static NSTimeInterval const DETAnimatedTransitionDurationForMarco = 0.15f;

@implementation testerAnimation

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    if (self.reverse) {
        [container insertSubview:toViewController.view belowSubview:fromViewController.view];
    }
    else {
        toViewController.view.transform = CGAffineTransformMakeScale(0, 0.5);
        [container addSubview:toViewController.view];
    }
    
    [UIView animateKeyframesWithDuration:DETAnimatedTransitionDuration delay:0 options:0 animations:^{
        if (self.reverse) {
           // fromViewController.view.transform = CGAffineTransformMakeScale(0, 0);
        }
        else {
            toViewController.view.transform = CGAffineTransformIdentity;
        }
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return DETAnimatedTransitionDuration;
}


@end
