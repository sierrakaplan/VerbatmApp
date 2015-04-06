//
//  v_multimediaTextVIew.m
//  Verbatm
//
//  Created by Iain Usiri on 3/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "v_multimediaTextVIew.h"
#import "v_textview.h"


//not being used right now- idk why the class isn't working x_x
@interface v_multimediaTextVIew ()

@property (strong, nonatomic) v_textview* textView;
@property (strong, nonatomic) UIVisualEffectView* bgBlurImage;
@property (nonatomic) CGPoint lastPoint;
@property (strong, nonatomic) UIView* pullBarView;
@property (strong, nonatomic) UIView* whiteBorderBar;

@property (nonatomic) BOOL isTitle;
@property (nonatomic) CGRect absoluteFrame;
#define BORDER_HEIGHT 2
#define BORDER_COLOR whiteColor
#define WHITE_BORDER_FRAME CGRectMake(0, self.pullBarView.frame.size.height - BORDER_HEIGHT, self.frame.size.width, BORDER_HEIGHT)
#define OFFSET_FROM_TOP 80
#define SIDE_BORDER 30
#define EXTRA  20
#define TEXT_CONTENT_OFFSET 100
#define MIN_WORDS 20
#define DEFAULT_FONT_FAMILY @"AmericanTypewriter-Light"
#define DEFAULT_FONT_SIZE 20
#define THRESHOLD 1.8
#define PULLBAR_COLOR clearColor
#define TEXT_VIEW_DEFAULT_FRAME CGRectMake(SIDE_BORDER, OFFSET_FROM_TOP + 2*EXTRA, self.frame.size.width - 2*SIDE_BORDER, self.frame.size.height - OFFSET_FROM_TOP - 3*EXTRA)
#define BLUR_VIEW_FRAME CGRectMake(0, OFFSET_FROM_TOP + 2*EXTRA, self.frame.size.width, self.frame.size.height - OFFSET_FROM_TOP)

@end
@implementation v_multimediaTextVIew

-(instancetype)initWithFrame:(CGRect)frame andText:(NSString*)text
{
    
    if((self = [super initWithFrame:frame]))
    {
         [self handleTexViewDetailsFromText:text];
    }
    return self;
}


-(void)handleTexViewDetailsFromText:(NSString *) text
{
    [self formatTextViewWithText: text];
    [self checkWordCount:text];
    [self setSizesToFit];
    self.userInteractionEnabled = YES;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.showsVerticalScrollIndicator = NO;
    self.textView.textAlignment = NSTextAlignmentCenter;
    [self bringSubviewToFront:self.textView];
    [self bringSubviewToFront: self.pullBarView];
}

-(void)createBorderPath
{
    self.whiteBorderBar = [[UIView alloc] initWithFrame:WHITE_BORDER_FRAME];
    self.whiteBorderBar.backgroundColor = [UIColor BORDER_COLOR];
    [self.pullBarView addSubview:self.whiteBorderBar];
}

//everytime we reset the pullbar frame we call this to reset the white bar
-(void)setWhiteBarFrame
{
    self.whiteBorderBar.frame = WHITE_BORDER_FRAME;
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
        [self.textView setFont:[UIFont fontWithName:DEFAULT_FONT_FAMILY size:DEFAULT_FONT_SIZE]];
        [self.textView removeTextVerticalCentering];
    }else{
        
        [self createPullBar];
        [self createBlur];
    }
}

-(void)formatTextViewWithText:(NSString*) text
{
    self.textView = [[v_textview alloc]initWithFrame: TEXT_VIEW_DEFAULT_FRAME];
    [self.textView setTextViewText: text];
    self.textView.textColor = [UIColor whiteColor];
    [self addSubview: self.textView];
    [self.textView setFont:[UIFont fontWithName:DEFAULT_FONT_FAMILY size:DEFAULT_FONT_SIZE]];
}

-(void) createPullBar
{
    //add pullbar
    self.pullBarView = [[UIView alloc] initWithFrame:CGRectMake(0, OFFSET_FROM_TOP ,self.frame.size.width,EXTRA*2)];
    self.pullBarView.backgroundColor = [UIColor PULLBAR_COLOR];
    self.absoluteFrame = self.pullBarView.frame;
    [self addSubview: self.pullBarView];
    [self.bgBlurImage bringSubviewToFront:self.pullBarView];
    [self createBorderPath];
}

-(void)createBlur
{
    //Add the blur
    UIBlurEffect* blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.bgBlurImage = [[UIVisualEffectView  alloc]initWithEffect:blur];
    self.bgBlurImage.frame = BLUR_VIEW_FRAME;
    self.bgBlurImage.alpha = 1.0;
    [self insertSubview:self.bgBlurImage belowSubview:self.textView];
}
-(void)resetFrames
{
    self.pullBarView.frame = self.absoluteFrame;
    self.textView.frame = TEXT_VIEW_DEFAULT_FRAME;
    self.bgBlurImage.frame = BLUR_VIEW_FRAME;
    [self setWhiteBarFrame];
}
-(void)addSwipeGesture
{
    if(self.isTitle)return;
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc]initWithTarget: self action:@selector(repositiontextView:)];
    [self.pullBarView addGestureRecognizer:panGesture];
}


//makes text and blur view move up and down as pull bar is pulled up/down.
-(void)repositiontextView:(UIPanGestureRecognizer *)sender
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
                [self setWhiteBarFrame];
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



/*This function sets the textView's size to fit superview's frame.
 *It ensures that the text layer is always centered in the super view and
 *it text fits in perfectly.
 */
-(void)setSizesToFit
{
    self.textView.textAlignment = NSTextAlignmentCenter;
    [self.textView sizeToFit];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
