//
//  TextAndOtherAves.m
//  Verbatm
//
//  Created by Iain Usiri on 7/18/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "TextAndOtherAves.h"
#import "MultiplePhotoAVE.h"
#import "Styles.h"
#import "SizesAndPositions.h"
#import "Icons.h"

//just a ratio from the midpoint that the gesture should be past before we go to auto adjust
#define THRESHOLD 1.8


@interface TextAndOtherAves()
//an invisible bar that sits on the edge of the textview to catch gestures
@property (strong,nonatomic) UIView* pullBar;
//the view that's showing the dark text
@property (strong,nonatomic) UITextView * textView;
@property (nonatomic)CGRect pullBarStartFrame;
@property (nonatomic)CGRect textViewStartFrame;

//stores the previous point in a pulldown gesture
@property (nonatomic) CGPoint lastPoint;

@end


@implementation TextAndOtherAves

/*we pass in the text for the text view and also the AVE type.
 */
-(instancetype)initWithFrame:(CGRect) frame text:(NSString*)text aveType:(AVEType)aveType aveMedia: (NSArray *)media {

    self = [super initWithFrame:frame];
    if(self) {
		switch (aveType) {
			case AVETypePhoto: {
				MultiplePhotoAVE *photoAve = [[MultiplePhotoAVE alloc] initWithFrame:frame andPhotoArray:[NSMutableArray arrayWithArray:media]];
				[self addSubview: photoAve];
				break;
			}
			case AVETypeVideo: {
				break;
			}
			case AVETypePhotoVideo: {
				break;
			}
			default: {
				break;
			}
		}
        [self setUpTextViewWithString:text];
    }
    return self;
}

-(void)setUpTextViewWithString:(NSString *) text
{
	self.textViewStartFrame = CGRectMake(0,TEXT_OVER_AVE_TOP_OFFSET,self.frame.size.width,TEXT_OVER_AVE_STARTING_HEIGHT);
    self.textView = [[UITextView alloc] initWithFrame:self.textViewStartFrame];
    self.textView.text = text;
    self.textView.textColor = [UIColor TEXT_OVER_AVE_COLOR];

	self.textView.backgroundColor = [UIColor colorWithWhite:0 alpha:TEXT_OVER_AVE_BACKGROUND_ALPHA];
	self.textView.userInteractionEnabled = YES;
	self.textView.showsVerticalScrollIndicator = NO;
	self.textView.textAlignment = NSTextAlignmentCenter;
	[self.textView setFont:[UIFont fontWithName:TEXT_AVE_FONT size:TEXT_AVE_FONT_SIZE]];
	if(self.textView.contentSize.height > TEXT_OVER_AVE_STARTING_HEIGHT) {
		[self addGestureToView];
	}

    [self addSubview:self.textView];
    [self bringSubviewToFront:self.textView];
}

-(int)numberOfLinesInTextView:(UITextView *)textView
{
    return textView.contentSize.height/textView.font.lineHeight;
}


-(void)addGestureToView
{
    self.pullBar =[[UIView alloc] init];



    self.pullBarStartFrame = CGRectMake(0,self.textView.frame.origin.y+self.textView.frame.size.height - TEXT_OVER_AVE_PULLBAR_HEIGHT/2.f,
									self.frame.size.width, TEXT_OVER_AVE_PULLBAR_HEIGHT);

	float iconSize = TEXT_OVER_AVE_PULLBAR_HEIGHT;
	UIImageView *pullBarIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:PULLDOWN_TEXT_ICON]];
	float iconXposition = self.pullBarStartFrame.size.width/2.f - iconSize/2.f;
	pullBarIcon.frame = CGRectMake(iconXposition, self.pullBarStartFrame.origin.y, iconSize, iconSize);

	[self.pullBar addSubview:pullBarIcon];
	self.pullBar.frame = self.pullBarStartFrame;
	self.pullBar.backgroundColor = [UIColor TEXT_OVER_AVE_PULLBAR_COLOR];
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

@end
