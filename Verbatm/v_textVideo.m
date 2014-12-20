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
        [attributedText setAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], /*NSStrokeWidthAttributeName : @-3, NSStrokeColorAttributeName : [UIColor blackColor],*/
                                        NSFontAttributeName :[UIFont fontWithName:@"Didot" size:17] } range: NSMakeRange(0, [text length])];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setLineSpacing:10] ;
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedText.length)];
        [self.textView setAttributedText:attributedText];
        self.textView.textAlignment = NSTextAlignmentCenter;
        self.textView.backgroundColor = [UIColor clearColor];
        [self addSubview: self.textView];
        self.userInteractionEnabled = YES;
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
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    if(sender.direction == UISwipeGestureRecognizerDirectionRight){
        if(!self.textView.hidden) return;
        [animation setSubtype:kCATransitionFromLeft];
    }else{
        if(self.textView.hidden)return;
        [animation setSubtype:kCATransitionFromRight];
    }
    self.textView.hidden = !self.textView.hidden;
    [self.textView.layer addAnimation:animation forKey: @"transition"];
}

@end
