//
//  v_textPhoto.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

//PS use uitoolbar for blur effect should they want it
#import "v_textPhoto.h"
#import "ILTranslucentView.h"

@interface v_textPhoto()
@property (strong, nonatomic) v_textview* textLayer;
@property (strong, nonatomic) UIView* bgBlur;
@end
@implementation v_textPhoto

-(id)initWithFrame:(CGRect)frame andImage:(UIImage *)image andText:(NSString*)text
{
    if((self = [super initWithImage:image])){
        self.frame = frame;
        //Add the blur
        CGRect this_frame = CGRectMake(16, 16, self.frame.size.width - 32, self.frame.size.height/3);
        self.bgBlur = [[UIView alloc] initWithFrame:this_frame];
        self.bgBlur.backgroundColor = [UIColor blackColor];
        self.bgBlur.alpha = 0.5;
        self.bgBlur.layer.cornerRadius = 8.0f;
        [self addSubview:self.bgBlur];
        
        self.textLayer = [[v_textview alloc]initWithFrame: this_frame];
        NSMutableAttributedString* attributedText = [[NSMutableAttributedString alloc]initWithString: text];
        [attributedText setAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], /*NSStrokeWidthAttributeName : @-3, NSStrokeColorAttributeName : [UIColor blackColor],*/
                                        NSFontAttributeName :[UIFont fontWithName:@"Didot" size:17] } range: NSMakeRange(0, [text length])];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setLineSpacing:10] ;
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedText.length)];
        [self.textLayer setAttributedText:attributedText];
        [self addSubview: self.textLayer];
        
        [self setSizesToFit];
        self.userInteractionEnabled = YES;
        self.textLayer.backgroundColor = [UIColor clearColor];
        self.textLayer.textAlignment = NSTextAlignmentCenter;
        [self bringSubviewToFront:self.textLayer];        
    }
    return self;
}

-(void)addSwipeGesture
{
    UISwipeGestureRecognizer* swipeGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(repositionTextLayer:)];
    swipeGestureLeft.direction  = UISwipeGestureRecognizerDirectionLeft;
    [self.superview addGestureRecognizer: swipeGestureLeft];
    UISwipeGestureRecognizer* swipeGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(repositionTextLayer:)];
    swipeGestureRight.direction  = UISwipeGestureRecognizerDirectionRight;
    [self.superview addGestureRecognizer: swipeGestureRight];
}

//work on slow fading with movement of arm later
-(void)repositionTextLayer:(UISwipeGestureRecognizer*)sender
{
    if(!CGRectContainsPoint(self.textLayer.frame, [sender locationOfTouch:0 inView:self])) return;
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionFade];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    if(sender.direction == UISwipeGestureRecognizerDirectionRight){
        if(!self.textLayer.hidden) return;
        [animation setSubtype:kCATransitionFromLeft];
    }else{
        if(self.textLayer.hidden)return;
        [animation setSubtype:kCATransitionFromRight];
    }
    self.textLayer.hidden = !self.textLayer.hidden;
    self.bgBlur.hidden = !self.bgBlur.hidden;
    [self.bgBlur.layer addAnimation:animation forKey: @"transition"];
    [self.textLayer.layer addAnimation:animation forKey: @"transition"];
}

-(void)setSizesToFit
{
    [self.textLayer sizeToFit];
    if(self.textLayer.frame.size.height > self.frame.size.height - 32){
        CGRect this_frame = self.textLayer.frame;
        this_frame.size.height = self.frame.size.height - 32;
        self.textLayer.frame = this_frame;
    }
    self.bgBlur.frame = self.textLayer.frame;
}
@end
