//
//  v_photoVideoText.m
//  tester
//
//  Created by Iain Usiri on 12/20/14.
//  Copyright (c) 2014 IainAndLucio. All rights reserved.
//

#import "v_photoVideoText.h"
#import "v_videoview.h"

@interface v_photoVideoText()
@property (strong, nonatomic) v_videoview* videoView;
@end
@implementation v_photoVideoText

-(id)initWithFrame:(CGRect)frame forImage:(UIImage *)image andText:(NSString *)text andAssets:(NSArray*)assetList
{
    if((self = [super initWithFrame:frame andImage:image andText:text])){
        self.videoView = [[v_videoview alloc] initWithFrame:self.bounds andAssets: assetList];
        [self insertSubview: self.videoView atIndex:0];
        self.videoView.hidden = YES;
    }
    return self;
}

-(void)createGestures
{
    [self addSwipeGesture];
    [self createLongPressGesture];
}

-(void)createLongPressGesture
{
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action: @selector(showVideo:)];
    longPress.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longPress];
}

-(void)showVideo:(UILongPressGestureRecognizer*)sender
{
    if(sender.state != UIGestureRecognizerStateBegan && sender.state != UIGestureRecognizerStateEnded) return;
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.6];
    [animation setType:kCATransitionFade];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    self.videoView.hidden = !self.videoView.hidden;
    [self.layer addAnimation:animation forKey: @"transition"];
}


@end
