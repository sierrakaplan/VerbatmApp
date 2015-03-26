//
//  v_multiVidTextPhoto.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/25/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "v_multiVidTextPhoto.h"
#import "v_textview.h"

@interface v_multiVidTextPhoto()
@property (strong, nonatomic)v_textview* textLayer;
@property (strong, nonatomic) UIView* bgBlur;
@property (nonatomic) BOOL isTitle;
#define BORDER 20
#define MIN_WORDS 20
#define DEFAULT_FONT_FAMILY @"ArialMT"
#define DEFAULT_FONT_SIZE 28
@end
@implementation v_multiVidTextPhoto
@synthesize textLayer = _textLayer;
@synthesize bgBlur = _bgBlur;
@synthesize isTitle = _isTitle;

-(id)initWithFrame:(CGRect)frame andMedia:(NSArray *)media andText:(NSString*)text
{
    if((self = [super initWithFrame:frame andMedia:media])){
        
        _textLayer = [[v_textview alloc]initWithFrame: self.bounds];
        
        [_textLayer setTextViewText: text];
        [self addSubview: _textLayer];
        
        
        [self checkWordCount:text];
        [self setSizesToFit];
        
        self.userInteractionEnabled = YES;
        _textLayer.backgroundColor = [UIColor clearColor];
        _textLayer.showsVerticalScrollIndicator = NO;
        
        _textLayer.textAlignment = NSTextAlignmentJustified;
        [self bringSubviewToFront:_textLayer];
    }
    return self;
}


-(void)checkWordCount:(NSString*)text
{
    int words = 0;
    NSArray * string_array = [text componentsSeparatedByString: @" "];
    words += [string_array count];
    //Make sure to discount blanks in the array
    for (NSString * string in string_array)
    {
        if([string isEqualToString:@""] && words != 0) words--;
    }
    //make sure that the last word is complete by having a space after it
    if(![[string_array lastObject] isEqualToString:@""]) words --;
    if(words <= MIN_WORDS){
        _isTitle = YES;
        [_textLayer setFont:[UIFont fontWithName:DEFAULT_FONT_FAMILY size:DEFAULT_FONT_SIZE]];
    }else{
        //Add the blur
        _bgBlur = [[UIView alloc] initWithFrame: self.bounds];
        _bgBlur.backgroundColor = [UIColor blackColor];
        _bgBlur.alpha = 0.7;
        [self insertSubview:_bgBlur belowSubview:_textLayer];
    }
}

/*This function sets the textLayer's size to fit superview's frame.
 *It ensures that the text layer is always centered in the super view and
 *it text fits in perfectly.
 */
-(void)setSizesToFit
{
    _textLayer.textAlignment = NSTextAlignmentCenter;
    CGRect this_frame = _textLayer.frame;
    this_frame.origin.y += BORDER;
    this_frame.origin.x += BORDER;
    this_frame.size.width -= 2*BORDER;
    _textLayer.frame = this_frame;
    [_textLayer sizeToFit];
    if(_textLayer.frame.size.height > self.frame.size.height - 2*BORDER){
        this_frame.size.height = self.frame.size.height - 2*BORDER;
        _textLayer.frame = this_frame;
    }else if (!_isTitle){
        int translate = self.frame.size.height/2 - (_textLayer.frame.size.height/2 + _textLayer.frame.origin.y);
        _textLayer.frame = CGRectOffset(_textLayer.frame, 0, translate);
        return;
    }
}

-(void)addSwipeGesture
{
    if(_isTitle)return;
    UISwipeGestureRecognizer* swiper = [[UISwipeGestureRecognizer alloc]initWithTarget:self action: @selector(repositionTextLayer:)];
    swiper.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swiper];
    UISwipeGestureRecognizer* swiperL = [[UISwipeGestureRecognizer alloc]initWithTarget:self action: @selector(repositionTextLayer:)];
    swiper.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swiperL];
}

-(void)addTapGesture
{
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapGesture];
}

-(void)handleTapGesture:(UITapGestureRecognizer*)tap
{
    if(!_textLayer.hidden)return;
}

-(void)repositionTextLayer:(UISwipeGestureRecognizer*)sender
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionFade];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    if(sender.direction == UISwipeGestureRecognizerDirectionRight){
        if(!_textLayer.hidden) return;
        [animation setSubtype:kCATransitionFromLeft];
    }else{
        if(_textLayer.hidden)return;
        [animation setSubtype:kCATransitionFromRight];
    }
    if(_textLayer.hidden){
        [self bringSubviewToFront:_textLayer];
    }
    _textLayer.hidden = !_textLayer.hidden;
    _bgBlur.hidden = !_bgBlur.hidden;
    [_bgBlur.layer addAnimation:animation forKey: @"transition"];
    [_textLayer.layer addAnimation:animation forKey: @"transition"];
}


@end
