//
//  v_photoVideo.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "v_photoVideo.h"
#import "v_videoview.h"

@interface v_photoVideo()
@property (strong, nonatomic) v_videoview* videoView;
@end
@implementation v_photoVideo

-(id)initWithFrame:(CGRect)frame Assets:(NSArray*)assetList andImage:(UIImage*)image
{
    if((self = [super initWithFrame:frame])){
        [self setImage:image];
        self.videoView = [[v_videoview alloc]initWithFrame:self.bounds andAssets:assetList];
        self.videoView.showProgressBar = NO;
        [self createLongPressGesture];
    }
    return self;
}

-(void)createLongPressGesture
{
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action: @selector(showVideo:)];
    longPress.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longPress];
}

-(void)showVideo:(UILongPressGestureRecognizer*)sender
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionFade];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    if(sender.state == UIGestureRecognizerStateBegan){
        [self addSubview:self.videoView];
        [self bringSubviewToFront: self.videoView];
    }else{
        [self.videoView removeFromSuperview];
    }
    [animation setSubtype:kCATransitionFromTop];
    [self.layer addAnimation:animation forKey: @"transition"];
}
@end
