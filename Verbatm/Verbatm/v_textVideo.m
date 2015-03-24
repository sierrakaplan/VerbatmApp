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
@property (strong, nonatomic) v_textview* textLayer;
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
@implementation v_textVideo

//very same as the photo text yeah
-(id)initWithFrame:(CGRect)frame andAssets:(NSArray *)assetList andText:(NSString*)text
{
    if((self = [super initWithFrame:frame andAssets:assetList])){
        self.frame = frame;
        
        CGRect textFrame = CGRectMake(SIDE_BORDER, OFFSET_FROM_TOP + 2*EXTRA, self.frame.size.width - 2*SIDE_BORDER, self.frame.size.height - OFFSET_FROM_TOP - 2*EXTRA);
        self.textLayer = [[v_textview alloc]initWithFrame: textFrame];
        [self.textLayer setTextViewText: text];
        self.textLayer.textColor = [UIColor whiteColor];
        [self addSubview: self.textLayer];
        
        
        [self checkWordCount:text];
        //[self setSizesToFit];
        self.userInteractionEnabled = YES;
        self.textLayer.backgroundColor = [UIColor clearColor];
        self.textLayer.showsVerticalScrollIndicator = NO;
        
        self.textLayer.textAlignment = NSTextAlignmentCenter;
        [self bringSubviewToFront:self.textLayer];
        [self bringSubviewToFront: self.pullBarView];
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
        self.isTitle = YES;
        [self.textLayer setFont:[UIFont fontWithName:DEFAULT_FONT_FAMILY size:DEFAULT_FONT_SIZE]];
        [self.textLayer removeTextVerticalCentering];
    }else{
        //add pullbar
        self.pullBarView = [[UIView alloc] initWithFrame:CGRectMake(0, OFFSET_FROM_TOP ,self.frame.size.width, 2*EXTRA)];
        self.pullBarView.backgroundColor = [UIColor grayColor];
        self.absoluteFrame = self.pullBarView.frame;
        [self addSubview: self.pullBarView];
        
        //Add the blur
        UIBlurEffect* blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.bgBlurImage = [[UIVisualEffectView  alloc]initWithEffect:blur];
        self.bgBlurImage.frame = CGRectMake(0, OFFSET_FROM_TOP + 2*EXTRA, self.frame.size.width, self.frame.size.height - OFFSET_FROM_TOP - 2*EXTRA);
        self.bgBlurImage.alpha = 1.0;
        [self insertSubview:self.bgBlurImage belowSubview:self.textLayer];
    }
}

-(void)addSwipeGesture
{
    if(self.isTitle)return;
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc]initWithTarget: self action:@selector(repositionTextLayer:)];
    [self.pullBarView addGestureRecognizer:panGesture];
}


//makes text and blur view move up and down as pull bar is pulled up/down.
-(void)repositionTextLayer:(UIPanGestureRecognizer*)sender
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
                self.textLayer.frame = CGRectMake(SIDE_BORDER, self.frame.size.height, self.frame.size.width - 2*SIDE_BORDER, self.frame.size.height - OFFSET_FROM_TOP - 3*EXTRA);
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
    self.textLayer.frame = CGRectOffset(self.textLayer.frame,  0, translation.y - self.lastPoint.y );
    self.lastPoint = translation;
}

-(void)resetFrames
{
    self.pullBarView.frame = self.absoluteFrame;
    self.textLayer.frame = CGRectMake(SIDE_BORDER, OFFSET_FROM_TOP + 2*EXTRA, self.frame.size.width - 2*SIDE_BORDER, self.frame.size.height - OFFSET_FROM_TOP - 2*EXTRA);
    self.bgBlurImage.frame = CGRectMake(0, OFFSET_FROM_TOP + 2*EXTRA, self.frame.size.width, self.frame.size.height - OFFSET_FROM_TOP - 2*EXTRA);
}

/*This function sets the textLayer's size to fit superview's frame.
 *It ensures that the text layer is always centered in the super view and
 *it text fits in perfectly.
 */
-(void)setSizesToFit
{
    self.textLayer.textAlignment = NSTextAlignmentCenter;
    [self.textLayer sizeToFit];
}
@end