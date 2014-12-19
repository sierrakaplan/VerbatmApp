//
//  v_textVideo.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "v_textVideo.h"
#import "v_textview.h"


@interface v_textVideo()
@property (strong, nonatomic) v_textview* textView;
@end
@implementation v_textVideo

-(id)initWithFrame:(CGRect)frame andAssets:(NSArray *)assetList andText:(NSString*)text
{
    if((self = [super initWithFrame:frame andAssets:assetList])){
        self.textView = [[v_textview alloc]initWithFrame:self.bounds];
        NSMutableAttributedString* attributedText = [[NSMutableAttributedString alloc]initWithString: text];
        [attributedText setAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSStrokeWidthAttributeName : @-2, NSStrokeColorAttributeName : [UIColor blackColor],  } range: NSMakeRange(0, [attributedText length])];
        [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:11] range:NSMakeRange(0, [attributedText length])];
        [self.textView setAttributedText:attributedText];
        self.textView.backgroundColor = [UIColor clearColor];
        self.showProgressBar = NO;
        [self addSubview: self.textView];
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
        if(!self.textView.hidden) return;
        [animation setSubtype:kCATransitionFromRight];
    }else{
        if(self.textView.hidden)return;
        [animation setSubtype:kCATransitionFromLeft];
    }
    self.textView.hidden = !self.textView.hidden;
    [self.textView.layer addAnimation:animation forKey: @"transition"];
}

@end
