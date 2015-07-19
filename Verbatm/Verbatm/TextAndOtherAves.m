//
//  TextAndOtherAves.m
//  Verbatm
//
//  Created by Iain Usiri on 7/18/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "TextAndOtherAves.h"
#import "constants.h"
#import "MultiplePhotoAVE.h"
#import "verbatmAveTextView.h"
#pragma mark -constants-
#define TEXT_TOP_OFFSET 40
#define TEXTVIEW_STARTING_HEIGHT 20 //This is supposed to be enough for two lines
#define TEXTVIEW_STARTFRAME CGRectMake(0,TEXT_TOP_OFFSET,self.frame.size.width,TEXTVIEW_STARTING_HEIGHT)
#define DEFAULT_FONT_FAMILY @"AmericanTypewriter-Light"
#define DEFAULT_FONT_SIZE 20
#define DEFAULT_LINE_NUMBER 2
#define MIN_WORDS 20
#define PULL_BAR_HEIGHT 20
#define PULLBAR_COLOR clearColor
//just a ratio from the midpoint that the gesture should be past before we go to auto adjust
#define THRESHOLD 1.8
#define TEXTVIEW_BACKGROUND_ALPHA 0.8
#define TEXT_COLOR [UIColor whiteColor]

@interface TextAndOtherAves()
//an invisible bar that sits on the edge of the textview to catch gestures
@property (strong,nonatomic)UIView * pullBar;
//the view that's showing the dark text
@property (strong,nonatomic) verbatmAveTextView * textView;
@property (nonatomic)CGRect pullBarStartFrame;
@property (nonatomic)CGRect textViewStartFrame;

//stores the previous point in a pulldown gesture
@property (nonatomic) CGPoint lastPoint;

@end


@implementation TextAndOtherAves

/*we pass in the text for the text view and also the AVE type. The Ave can be one of 3
 -PHOTO
 -VIDEO
 -PHOTOVIDEO
 from this string we create and place the appropriate ave as a subview
 */
-(instancetype)initWithFrame:(CGRect) frame text:(NSString*)text aveType:(NSString*)AVE aveMedia: (NSArray *)media
{
    self = [super initWithFrame:frame];
    if(self)
    {
       if([AVE isEqualToString:PHOTO_AVE])
       {
           MultiplePhotoAVE * photoAve = [[MultiplePhotoAVE alloc] initWithFrame:frame andPhotoArray:[NSMutableArray arrayWithArray:media]];
           [self addSubview:photoAve];
       }else if([AVE isEqualToString:VIDEO_AVE])
       {
           
       }else if ([AVE isEqualToString:PHOTO_VIDEO_AVE])
       {
           
       }
        [self setUpTextViewWithString:text];
    }
    return self;
}

-(void)setUpTextViewWithString:(NSString *) text
{
    self.textView = [[verbatmAveTextView alloc] initWithFrame:TEXTVIEW_STARTFRAME];
    self.textView.text = text;
    self.textView.textColor = TEXT_COLOR;
    self.textViewStartFrame = self.textView.frame;
    [self formatTextView:self.textView];
    [self addSubview:self.textView];
    [self bringSubviewToFront:self.textView];
}

-(void)formatTextView:(UITextView *)textView
{
    self.textView.backgroundColor = [UIColor colorWithWhite:0 alpha:TEXTVIEW_BACKGROUND_ALPHA];
    self.textView.userInteractionEnabled = YES;
    
    
    self.textView.showsVerticalScrollIndicator = NO;
    self.textView.textAlignment = NSTextAlignmentCenter;
    [self.textView setFont:[UIFont fontWithName:DEFAULT_FONT_FAMILY size:DEFAULT_FONT_SIZE]];
    if([self numberOfLinesInTextView:self.textView]==DEFAULT_LINE_NUMBER)
    {
        [self addGestureToView];
    }
}
-(int)numberOfLinesInTextView:(UITextView *)textView
{
    return textView.contentSize.height/textView.font.lineHeight;
}


-(void)addGestureToView
{
    self.pullBar =[[UIView alloc] init];
    self.pullBar.frame = CGRectMake(0,self.textView.frame.origin.y+self.textView.frame.size.height,
                                    self.frame.size.width, PULL_BAR_HEIGHT);
    self.pullBarStartFrame = self.pullBar.frame;
    self.pullBar.backgroundColor = [UIColor PULLBAR_COLOR];
    [self addSubview: self.pullBar];
    [self bringSubviewToFront:self.pullBar];
    [self addSwipeGestureToView:self.pullBar];
}

-(void)addSwipeGestureToView:(UIView *) view
{
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc]initWithTarget: self action:@selector(repositiontextView:)];
    [view addGestureRecognizer:panGesture];
}

-(void)resetFrames
{
    self.pullBar.frame = self.pullBarStartFrame;
    self.textView.frame = self.textViewStartFrame;
}


//makes text and blur view move up and down as pull bar is pulled up/down.
-(void)repositiontextView:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:self];
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        BOOL atTopmostLevel = self.pullBar.frame.origin.y == self.pullBarStartFrame.origin.y;
        if(translation.y < 0 && atTopmostLevel) return; //prevent pulling up beyond original position
        
        BOOL atLowestLevel = (self.pullBar.frame.origin.y + self.pullBar.frame.size.height) == self.frame.size.height;
        if(translation.y >  0 && atLowestLevel) return; //prevents pulling pullbar down below screen
        self.lastPoint = translation;
        return;
    }else if(sender.state == UIGestureRecognizerStateEnded)
    {
        self.lastPoint = translation;
        [UIView animateWithDuration:0.2 animations:^
        {
            int y_location = self.pullBar.frame.origin.y + self.pullBar.frame.size.height;
            int mid_pt = self.frame.size.height/2;
            if(y_location < THRESHOLD*mid_pt)
            {
                [self resetFrames];
            }else{
                self.textView.frame = CGRectMake(0, self.textView.frame.origin.y, self.textView.frame.size.width, self.frame.size.height - self.textView.frame.origin.y - self.pullBar.frame.size.height);
                self.pullBar.frame = CGRectMake(0, self.frame.size.height-self.pullBar.frame.size.height, self.frame.size.width,self.pullBar.frame.size.height);
            }
        } completion:^(BOOL finished) {
            self.lastPoint = CGPointZero;
        }];
        return;
    }
    //we reach here if it's UIGestureRecognizerStateChanged
    self.pullBar.frame = CGRectOffset(self.pullBar.frame, 0, translation.y - self.lastPoint.y);
    //if we pull the bar above its original position the view should autoreset to its standard position
    if(self.pullBarStartFrame.origin.y > self.pullBar.frame.origin.y)
    {
        [self resetFrames];
        self.lastPoint = CGPointZero;
        return;
    }
    self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y,self.textView.frame.size.width, self.textView.frame.size.height +(translation.y - self.lastPoint.y));
    self.lastPoint = translation;
}



//
//-(void)wordCount:(NSString*)text
//{
//    int words = 0;
//    NSArray * string_array = [text componentsSeparatedByString: @" "];
//    words += [string_array count];
//    //Make sure to discount blanks in the array
//    for (NSString * string in string_array)
//    {
//        if([string isEqualToString:@""] && words != 0) words--;
//    }
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
