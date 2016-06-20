//
//  LoadingIndicator.m
//  Verbatm
//
//  Created by Iain Usiri on 3/8/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Icons.h"

#import "LoadingIndicator.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>


@interface LoadingIndicator ()

@end

@implementation LoadingIndicator

#define LOAD_ICON_WIDTH 70.f

-(instancetype)initWithCenter:(CGPoint ) center andImage: (UIImage *) loadImage {

	CGRect frame = CGRectMake(0, 0, LOAD_ICON_WIDTH, LOAD_ICON_WIDTH);
	self = [super initWithFrame:frame];
	if(self){
		self.center = center;
		self.backgroundColor = [UIColor clearColor];
		self.hidden = YES;
		[self setImage:loadImage];
	}
	return self;
}

-(void)layoutSubviews{
	if(self.hidden == NO) [self spin];
}

- (void)startCustomActivityIndicator {
	self.hidden = NO;
	[self spin];
}

-(void)spin {
	CABasicAnimation *rotation;
	rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	rotation.fromValue = [NSNumber numberWithFloat:0];
	rotation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
	rotation.duration = 1.f; // Speed
	rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.


	//    CABasicAnimation *pulse;
	//    pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	//    pulse.duration = 0.5f;
	//    pulse.autoreverses = YES;
	//    pulse.fromValue = [NSNumber numberWithFloat:1.f];
	//    pulse.toValue =[NSNumber numberWithFloat:1.2f];
	//    pulse.repeatCount = HUGE_VALF;


	[self.layer removeAllAnimations];
	[self.layer addAnimation:rotation forKey:@"Spin"];
	//[self.customActivityIndicator.layer addAnimation:pulse forKey:@"Pulse"];
}

-(void)stopCustomActivityIndicator{
	[self stopAnimationsAndHide];
}

-(void)stopAnimationsAndHide{
	if(!self.hidden){
		[self.layer removeAllAnimations];
	}
	self.hidden = YES;
}

@end
