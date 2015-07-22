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
#import "Durations.h"
#import "UIEffects.h"

//just a ratio from the midpoint that the gesture should be past before we go to auto adjust
#define THRESHOLD 1.8


@interface TextAndOtherAves()
//an invisible bar that sits on the edge of the textview to catch gestures
@property (strong,nonatomic) UIView* pullBar;
//the view that's showing the dark text
@property (strong,nonatomic) TextViewOverAve * textView;
@property (strong,nonatomic) UIView * textViewContainer;
@property (nonatomic)CGRect pullBarStartFrame;
@property (nonatomic)CGRect pullBarBottomFrame;
@property (nonatomic)CGRect textViewStartFrame;
@property (nonatomic)CGRect textViewBottomFrame;
@property (nonatomic)float textViewContentSize;

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
        [self setUpTextViewWithText:text];
    }
    return self;
}

-(void)setUpTextViewWithText:(NSString *) text
{
	self.textViewStartFrame = CGRectMake(0,TEXT_OVER_AVE_TOP_OFFSET,self.frame.size.width,TEXT_OVER_AVE_STARTING_HEIGHT);

	self.textViewContainer = [[UIView alloc] initWithFrame:self.textViewStartFrame];
	[UIEffects createBlurViewOnView:self.textViewContainer];

    self.textView = [[TextViewOverAve alloc] init];
	[self setTextViewFrame];
	self.textView.text = text;
	self.textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//	[self.textView disableScrolling];

	[self.textViewContainer addSubview:self.textView];
	[self.textViewContainer bringSubviewToFront:self.textView];
	[self addSubview:self.textViewContainer];
	[self bringSubviewToFront:self.textViewContainer];

	// have text view resizable to size of its content or full screen
	self.textViewContentSize = [UIEffects measureHeightOfUITextView:self.textView];
	float heightForTextView = self.frame.size.height-TEXT_OVER_AVE_TOP_OFFSET*2;
	if (self.textViewContentSize < heightForTextView) {
		heightForTextView = self.textViewContentSize;
	}
	self.textViewBottomFrame = CGRectMake(0,TEXT_OVER_AVE_TOP_OFFSET,self.frame.size.width, heightForTextView);

	if(self.textViewContentSize > TEXT_OVER_AVE_STARTING_HEIGHT) {
		[self addPullDownBarToText];
	}
}

-(int)numberOfLinesInTextView:(UITextView *)textView
{
    return textView.contentSize.height/textView.font.lineHeight;
}


-(void)addPullDownBarToText {
	float pullBarTopY = self.textViewStartFrame.origin.y+self.textViewStartFrame.size.height - TEXT_OVER_AVE_PULLBAR_HEIGHT/2.f;
	float pullBarBottomY = self.textViewBottomFrame.origin.y + self.textViewBottomFrame.size.height - TEXT_OVER_AVE_PULLBAR_HEIGHT/2.f;
	self.pullBarStartFrame = CGRectMake(0,pullBarTopY, self.frame.size.width, TEXT_OVER_AVE_PULLBAR_HEIGHT);
	self.pullBarBottomFrame = CGRectMake(0,pullBarBottomY, self.frame.size.width, TEXT_OVER_AVE_PULLBAR_HEIGHT);

	self.pullBar =[[UIView alloc] init];
	self.pullBar.frame = self.pullBarStartFrame;
	self.pullBar.backgroundColor = [UIColor TEXT_OVER_AVE_PULLBAR_COLOR];

	// add pull down icon
	float iconSize = TEXT_OVER_AVE_PULLBAR_HEIGHT;
	UIImageView *pullBarIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:PULLDOWN_TEXT_ICON]];
	float iconXposition = self.pullBar.bounds.size.width/2.f - iconSize/2.f;
	pullBarIcon.frame = CGRectMake(iconXposition, self.pullBar.bounds.origin.y, iconSize, iconSize);
	[self.pullBar addSubview:pullBarIcon];

    [self addSubview: self.pullBar];
    [self bringSubviewToFront:self.pullBar];
    [self addSwipeGestureToView:self.pullBar];
}

-(void)addSwipeGestureToView:(UIView *) view
{
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc]initWithTarget: self action:@selector(repositionTextView:)];
    [view addGestureRecognizer:panGesture];
}

-(void)setTextFramesTop {
    self.pullBar.frame = self.pullBarStartFrame;
    self.textViewContainer.frame = self.textViewStartFrame;
	[self setTextViewFrame];
}

-(void) setTextFramesBottom {
	self.pullBar.frame = self.pullBarBottomFrame;
	self.textViewContainer.frame = self.textViewBottomFrame;
	[self setTextViewFrame];
}

-(void) setTextViewFrame {
//	CGRect frameWithTopBottomBorder = CGRectMake(self.textViewContainer.bounds.origin.x + TEXT_OVER_AVE_BORDER, self.textViewContainer.bounds.origin.y + TEXT_OVER_AVE_BORDER, self.textViewContainer.bounds.size.width - TEXT_OVER_AVE_BORDER*2, self.textViewContainer.bounds.size.height - TEXT_OVER_AVE_BORDER - TEXT_OVER_AVE_PULLBAR_HEIGHT/2.f);

	self.textView.frame = CGRectMake(self.textViewContainer.bounds.origin.x + TEXT_OVER_AVE_BORDER, self.textViewContainer.bounds.origin.y, self.textViewContainer.bounds.size.width - TEXT_OVER_AVE_BORDER*2, self.textViewContainer.bounds.size.height);
}

//makes text and blur view move up and down as pull bar is pulled up/down.
-(void)repositionTextView:(UIPanGestureRecognizer *)gesture {
	switch (gesture.state) {
		case UIGestureRecognizerStateBegan: {
//			[self.textView disableScrolling];
			break;
		}
		case UIGestureRecognizerStateChanged: {
			[self changeFramesFromGesture:gesture];
			break;
		}
		case UIGestureRecognizerStateEnded: {
			[self changeFramesFromGesture:gesture];

			//if it's close to the top or bottom animate to the top or bottom
			if (fabs(self.pullBar.frame.origin.y - self.pullBarStartFrame.origin.y) <= TEXT_OVER_AVE_ANIMATION_THRESHOLD) {
//				[UIView animateWithDuration:TEXT_OVER_AVE_ANIMATION_DURATION animations:^ {
//
//					[self setTextFramesTop];
//				}];
			} else if(fabs(self.pullBar.frame.origin.y - self.pullBarBottomFrame.origin.y) <= TEXT_OVER_AVE_ANIMATION_THRESHOLD) {
//				[UIView animateWithDuration:TEXT_OVER_AVE_ANIMATION_DURATION animations:^ {
//
//					[self setTextFramesBottom];
//				}];
				if(self.textViewContentSize > self.textView.frame.size.height) {
//					[self.textView enableScrollingWithIndicator:YES];
				}
			}
			break;
		}
		default: {
			break;
		}
	}
}

//reset the frames of the pull bar and text view
-(void)changeFramesFromGesture:(UIPanGestureRecognizer *)gesture {

	CGPoint translation = [gesture translationInView:self];

	float newYPos = self.pullBar.frame.origin.y + translation.y;
	//only change frames if pull bar is being pulled within acceptable range
	if (newYPos < self.pullBarBottomFrame.origin.y && newYPos > self.pullBarStartFrame.origin.y) {
		[UIView animateWithDuration:TEXT_OVER_AVE_ANIMATION_DURATION animations:^ {

			self.pullBar.frame = CGRectMake(self.pullBar.frame.origin.x, newYPos, self.pullBar.frame.size.width, self.pullBar.frame.size.height);
			self.textViewContainer.frame = CGRectMake(self.textViewContainer.frame.origin.x, self.textViewContainer.frame.origin.y,self.textViewContainer.frame.size.width, self.textViewContainer.frame.size.height + translation.y);
			[self setTextViewFrame];
		}];
		[gesture setTranslation:CGPointZero inView:self.pullBar];
	}
}


@end
