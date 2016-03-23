//
//  LoadingIndicator.m
//  Verbatm
//
//  Created by Iain Usiri on 3/8/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "LoadingIndicator.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>


@interface LoadingIndicator ()
@property (nonatomic) UIImageView * customActivityIndicator;

@end

@implementation LoadingIndicator



#define LOAD_ICON_WIDTH 50.f
#define LOAD_ICON_IMAGE @"spinner_5"

-(instancetype)initWithCenter:(CGPoint ) center{
    
    CGRect frame = CGRectMake(0, 0, LOAD_ICON_WIDTH, LOAD_ICON_WIDTH);
    
    self = [super initWithFrame:frame];
    if(self){
        self.center = center;
        self.backgroundColor = [UIColor clearColor];
       self.hidden = YES;
    }
    
    return self;
}

-(void)layoutSubviews{
    if(self.hidden == NO)[self spin];
}


- (void)startCustomActivityIndicator {
   self.hidden = NO;
}

-(void)spin{
    CABasicAnimation *rotation;
    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = [NSNumber numberWithFloat:0];
    rotation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
    rotation.duration = 1.f; // Speed
    rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
    
    
    CABasicAnimation *pulse;
    pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulse.duration = 0.7f;
    pulse.autoreverses = YES;
    pulse.fromValue = [NSNumber numberWithFloat:1.f];
    pulse.toValue =[NSNumber numberWithFloat:1.2f];
    pulse.repeatCount = HUGE_VALF;
    
    
    [self.customActivityIndicator.layer removeAllAnimations];
    [self.customActivityIndicator.layer addAnimation:rotation forKey:@"Spin"];
    [self.customActivityIndicator.layer addAnimation:pulse forKey:@"Pulse"];
    [self addSubview:self.customActivityIndicator];
    [self bringSubviewToFront:self.customActivityIndicator];
}

-(void)stopCustomActivityIndicator{
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAnimationsAndHide];
        });
    }else{
        [self stopAnimationsAndHide];
    }
    
}

-(void)stopAnimationsAndHide{
    if(self.customActivityIndicator && !self.hidden){
        [self.customActivityIndicator.layer removeAllAnimations];
        //[self.customActivityIndicator.layer removeFromSuperlayer];
    }
    self.hidden = YES;
}

-(UIImageView *)customActivityIndicator{
    if(!_customActivityIndicator){
        _customActivityIndicator = [[UIImageView alloc] initWithFrame:self.bounds];
        [_customActivityIndicator setImage:[UIImage imageNamed:LOAD_ICON_IMAGE]];
        _customActivityIndicator.backgroundColor = [UIColor clearColor];
        [self addSubview:_customActivityIndicator];
    }
    return _customActivityIndicator;
}


@end
