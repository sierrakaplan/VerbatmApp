//
//  v_photoVideoText.m
//  tester
//
//  Created by Iain Usiri on 12/20/14.
//  Copyright (c) 2014 IainAndLucio. All rights reserved.
//

#import "v_photoVideoText.h"
#import "v_videoview.h"
#import "verbatmPhotoVideoAve.h"

@interface v_photoVideoText()
@property (strong, nonatomic) verbatmPhotoVideoAve * photoVideoView;

@property (strong, nonatomic) v_textview * textView;
@property (strong, nonatomic) UIVisualEffectView* bgBlurImage;
@property (nonatomic) CGPoint lastPoint;
@property (strong, nonatomic) UIView* pullBarView;
@property (nonatomic) BOOL isTitle;
@property (nonatomic) CGRect absoluteFrame;

#define OFFSET_FROM_TOP 80
#define SIDE_BORDER 30
#define EXTRA  10
#define MIN_WORDS 20
#define DEFAULT_FONT_FAMILY @"ArialMT"
#define DEFAULT_FONT_SIZE 23
#define THRESHOLD 1.8
@end
@implementation v_photoVideoText

-(id)initWithFrame:(CGRect)frame forImage:(UIImage *)image andText:(NSString *)text andAssets:(NSData*)video
{
    if(self = [super initWithFrame:frame])
    {
        self.photoVideoView = [[verbatmPhotoVideoAve alloc] initWithFrame:frame Image:image andVideo:video];
        [self addSubview:self.photoVideoView];
        [self createTextViewWithText:text];
        [self initPullBarAndBlur];
        
    }
    return self;
}

-(void)createTextViewWithText:(NSString *) text
{
    CGRect textFrame = CGRectMake(SIDE_BORDER, OFFSET_FROM_TOP + 2*EXTRA, self.frame.size.width - 2*SIDE_BORDER, self.frame.size.height - OFFSET_FROM_TOP - 2*EXTRA);
    self.textView = [[v_textview alloc]initWithFrame: textFrame];
    [self.textView setTextViewText: text];
    self.textView.textColor = [UIColor whiteColor];
    [self addSubview: self.textView];
}

-(void) initPullBarAndBlur
{
    //add pullbar
    self.pullBarView = [[UIView alloc] initWithFrame:CGRectMake(0, OFFSET_FROM_TOP ,self.frame.size.width, 2*EXTRA)];
    self.pullBarView.backgroundColor = [UIColor grayColor];
    self.absoluteFrame = self.pullBarView.frame;
    [self addSubview: self.pullBarView];
    [self addSwipeGestureToView:self.pullBarView];
    
    //Add the blur
    UIBlurEffect* blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.bgBlurImage = [[UIVisualEffectView  alloc]initWithEffect:blur];
    self.bgBlurImage.frame = CGRectMake(0, OFFSET_FROM_TOP + 2*EXTRA, self.frame.size.width, self.frame.size.height - OFFSET_FROM_TOP - 2*EXTRA);
    self.bgBlurImage.alpha = 1.0;
    [self insertSubview:self.bgBlurImage belowSubview:self.textView];
    
}

-(void)addSwipeGestureToView:(UIView *) view
{
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc]initWithTarget: self action:@selector(repositiontextView:)];
    [view addGestureRecognizer:panGesture];
}


//makes text and blur view move up and down as pull bar is pulled up/down.
-(void)repositiontextView:(UIPanGestureRecognizer*)sender
{
    CGPoint translation = [sender translationInView:self];
    if(sender.state == UIGestureRecognizerStateBegan){
        BOOL atTopmostLevel = self.pullBarView.frame.origin.y == self.absoluteFrame.origin.y;
        if(translation.y < 0 && atTopmostLevel){
            return; //prevent pulling up beyond original position
        }
        BOOL atLowestLevel = (self.pullBarView.frame.origin.y + self.pullBarView.frame.size.height) == self.frame.size.height;
        if(translation.y >  0 && atLowestLevel) return; //prevents pulling down below height of pullbar.
        self.lastPoint = translation;
        return;
    }else if(sender.state == UIGestureRecognizerStateEnded){
        self.lastPoint = translation;
        [UIView animateWithDuration:0.2 animations:^{
            int y_location = self.pullBarView.frame.origin.y + self.pullBarView.frame.size.height;
            int mid_pt = self.frame.size.height/2;
            if(y_location < THRESHOLD*mid_pt){
                [self resetFrames];
            }else{
                self.textView.frame = CGRectMake(SIDE_BORDER, self.frame.size.height, self.frame.size.width - 2*SIDE_BORDER, self.frame.size.height - OFFSET_FROM_TOP - 3*EXTRA);
                self.bgBlurImage.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height - OFFSET_FROM_TOP - 3*EXTRA);
                self.pullBarView.frame = CGRectMake(0, self.frame.size.height - 3*EXTRA, self.frame.size.width,3*EXTRA);
            }
        } completion:^(BOOL finished) {
            self.lastPoint = CGPointZero;
        }];
        return;
    }
    self.pullBarView.frame = CGRectOffset(self.pullBarView.frame, 0, translation.y - self.lastPoint.y );
    if(self.absoluteFrame.origin.y > self.pullBarView.frame.origin.y){
        [self resetFrames];
        self.lastPoint = CGPointZero;
        return;
    }
    self.bgBlurImage.frame = CGRectOffset(self.bgBlurImage.frame,  0, translation.y - self.lastPoint.y );
    self.textView.frame = CGRectOffset(self.textView.frame,  0, translation.y - self.lastPoint.y );
    self.lastPoint = translation;
}

-(void)resetFrames
{
    self.pullBarView.frame = self.absoluteFrame;
    self.textView.frame = CGRectMake(SIDE_BORDER, OFFSET_FROM_TOP + 2*EXTRA, self.frame.size.width - 2*SIDE_BORDER, self.frame.size.height - OFFSET_FROM_TOP - 2*EXTRA);
    self.bgBlurImage.frame = CGRectMake(0, OFFSET_FROM_TOP + 2*EXTRA, self.frame.size.width, self.frame.size.height - OFFSET_FROM_TOP - 2*EXTRA);
}


@end
