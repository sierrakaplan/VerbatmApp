//
//  CoverPhoto.m
//  Verbatm
//
//  Created by Iain Usiri on 11/11/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "CoverPhoto.h"

@interface CoverPhoto ()
    @property (strong, nonatomic) UIImageView * imageView;
    @property (nonatomic) CGPoint  lastPanPoint;
@end

@implementation CoverPhoto


-(instancetype) initWithFrame:(CGRect)frame andImage:(UIImage *) image{
    self = [super init];
    if(self){
        self.imageView = [[UIImageView alloc] initWithFrame:frame];
        self.imageView.image = image;
        [self addSubview:self.imageView];
        [self addPanGesture];
    }
    
    return self;
}

-(void) addPanGesture{
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(adjustPhotoPan:)];
    [self addGestureRecognizer:pan];
    
}
 
-(void)adjustPhotoPan:(UIPanGestureRecognizer *) pan {
    if([pan numberOfTouches] == 1){
        CGPoint touch = [pan locationOfTouch:0 inView:self];
        if(pan.state == UIGestureRecognizerStateBegan){
            self.lastPanPoint = touch;
        }else if (pan.state == UIGestureRecognizerStateChanged){
            
            CGFloat diff = touch.y - self.lastPanPoint.y;
            self.imageView.frame = CGRectMake(0, self.imageView.frame.origin.y + diff,self.imageView.frame.size.width, self.imageView.frame.size.height);
            self.lastPanPoint = touch;
        }else if (pan.state == UIGestureRecognizerStateEnded ||
                  pan.state == UIGestureRecognizerStateCancelled){
            
        }
    }
}

-(void)changeImage:(UIImage *) image{
    if(image){
        self.imageView.image = image;
    }
}

@end
