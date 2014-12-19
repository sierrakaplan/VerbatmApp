//
//  v_textPhoto.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "v_textPhoto.h"

@interface v_textPhoto()
@property (strong, nonatomic) v_textview* textLayer;
@end
@implementation v_textPhoto

-(id)initWithImage:(UIImage *)image andText:(NSString*)text
{
    if((self = [super initWithImage:image])){
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.textLayer = [[v_textview alloc]initWithFrame: self.bounds];
        self.textLayer.backgroundColor = [UIColor clearColor];
        NSMutableAttributedString* attributedText = [[NSMutableAttributedString alloc]initWithString: text];
        [attributedText setAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSStrokeWidthAttributeName : @-2, NSStrokeColorAttributeName : [UIColor blackColor],  } range: NSMakeRange(0, [attributedText length])];
        [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:11] range:NSMakeRange(0, [attributedText length])];
        [self.textLayer setAttributedText:attributedText];
        [self addSubview: self.textLayer];
        [self addSwipeGesture];
    }
    return self;
}

-(void)addSwipeGesture
{
    UISwipeGestureRecognizer* swipeGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(repositionTextLayer:)];
    swipeGestureLeft.direction  = UISwipeGestureRecognizerDirectionLeft;
    swipeGestureLeft.cancelsTouchesInView = NO;
    UISwipeGestureRecognizer* swipeGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(repositionTextLayer:)];
    swipeGestureRight.direction  = UISwipeGestureRecognizerDirectionRight;
    swipeGestureRight.cancelsTouchesInView = NO;
    [self addGestureRecognizer: swipeGestureLeft];
    [self addGestureRecognizer: swipeGestureRight];
}

-(void)repositionTextLayer:(UISwipeGestureRecognizer*)sender
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionPush];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    if(sender.direction == UISwipeGestureRecognizerDirectionRight){
        if(!self.textLayer.hidden) return;
        [animation setSubtype:kCATransitionFromRight];
    }else{
        if(self.textLayer.hidden)return;
        [animation setSubtype:kCATransitionFromLeft];
    }
    self.textLayer.hidden = !self.textLayer.hidden;
    [self.textLayer.layer addAnimation:animation forKey: @"transition"];
}
@end
