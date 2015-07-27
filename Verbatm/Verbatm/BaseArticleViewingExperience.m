//
//  TextAndOtherAves.m
//  Verbatm
//
//  Created by Iain Usiri on 7/18/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "BaseArticleViewingExperience.h"
#import "VideoAVE.h"
#import "PhotoAVE.h"
#import "MultiplePhotoVideoAVE.h"
#import "VerbatmImageScrollView.h"
#import "Styles.h"
#import "SizesAndPositions.h"
#import "Icons.h"
#import "Durations.h"

//just a ratio from the midpoint that the gesture should be past before we go to auto adjust
#define THRESHOLD 1.8


@interface BaseArticleViewingExperience()
//an invisible bar that sits on the edge of the textview to catch gestures
@property (strong,nonatomic) UIView* pullBar;
//the view that's showing the dark text

@property (strong,nonatomic) TextOverAVEView * textViewContainer;
@property (strong,nonatomic) UIView* mainContentView;
@property (nonatomic)CGRect oldMainContentViewFrame;
@property (strong, nonatomic) UIView* oldMainContentViewSuperview;

@property (nonatomic)CGRect pullBarStartFrame;
@property (nonatomic)CGRect pullBarBottomFrame;
@property (nonatomic)CGRect textViewStartFrame;
@property (nonatomic)CGRect textViewBottomFrame;
@property (nonatomic)float textViewContentSize;

//stores the previous point in a pulldown gesture
@property (nonatomic) CGPoint lastPoint;

@end


@implementation BaseArticleViewingExperience

/*we pass in the text for the text view and also the AVE type.
 */
-(instancetype)initWithFrame:(CGRect)frame andText:(NSString*)text andPhotos: (NSArray *)photos andVideos: (NSArray *)videos andAVEType:(AVEType)aveType {

    self = [super initWithFrame:frame];
    if(self) {
		switch (aveType) {
			case AVETypePhoto: {
				PhotoAVE* photoAve = [[PhotoAVE alloc] initWithFrame:frame andPhotoArray:photos];
				[self addSubview: photoAve];
				break;
			}
			case AVETypeVideo: {
				VideoAVE *videoAve = [[VideoAVE alloc] initWithFrame:frame andVideoAssetArray:videos];
				[self addSubview: videoAve];
				break;
			}
			case AVETypePhotoVideo: {
				MultiplePhotoVideoAVE *photoVideoAVE = [[MultiplePhotoVideoAVE alloc] initWithFrame:frame andPhotos:photos andVideos:videos];
				[self addSubview: photoVideoAVE];
				break;
			}
			default: {
				break;
			}
		}
		if (text && [text length]) {
			[self setUpTextViewWithText:text];
		}
    }
    return self;
}

-(void)setUpTextViewWithText:(NSString *) text {

	self.textViewStartFrame = CGRectMake(0,TEXT_OVER_AVE_TOP_OFFSET,self.frame.size.width,TEXT_OVER_AVE_STARTING_HEIGHT);
	self.textViewContainer = [[TextOverAVEView alloc] initWithFrame:self.textViewStartFrame];
	[self.textViewContainer setText:text];

	// have text view resizable to size of its content or full screen
	self.textViewContentSize = [self.textViewContainer getHeightOfText];
	float heightForTextView = self.frame.size.height-TEXT_OVER_AVE_TOP_OFFSET*2;
	if (self.textViewContentSize < heightForTextView) {
		heightForTextView = self.textViewContentSize;
	}
	self.textViewBottomFrame = CGRectMake(0,TEXT_OVER_AVE_TOP_OFFSET,self.frame.size.width, heightForTextView);
	[self addSubview:self.textViewContainer];
	[self bringSubviewToFront:self.textViewContainer];

	if(self.textViewContentSize > TEXT_OVER_AVE_STARTING_HEIGHT) {
		[self addPullDownBarForText];
	}
}

-(int)numberOfLinesInTextView:(UITextView *)textView
{
    return textView.contentSize.height/textView.font.lineHeight;
}


-(void)addPullDownBarForText {
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
	pullBarIcon.frame = CGRectMake(iconXposition, self.pullBar.bounds.origin.y, iconSize, iconSize/2.f);
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
}

-(void) setTextFramesBottom {
	self.pullBar.frame = self.pullBarBottomFrame;
	self.textViewContainer.frame = self.textViewBottomFrame;
}

//makes text and blur view move up and down as pull bar is pulled up/down.
-(void)repositionTextView:(UIPanGestureRecognizer *)gesture {
	switch (gesture.state) {
		case UIGestureRecognizerStateBegan: {
			break;
		}
		case UIGestureRecognizerStateChanged: {
			[self changeFramesFromGesture:gesture];
			break;
		}
		case UIGestureRecognizerStateEnded: {
			[self changeFramesFromGesture:gesture];

			if(fabs(self.pullBar.frame.origin.y - self.pullBarBottomFrame.origin.y) <= TEXT_OVER_AVE_ANIMATION_THRESHOLD) {
				if(self.textViewContentSize > self.textViewBottomFrame.size.height) {
					[self.textViewContainer enableScrollingWithIndicator:YES];
				}
			} else {
				[self.textViewContainer disableScrolling];
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

		self.pullBar.frame = CGRectMake(self.pullBar.frame.origin.x, newYPos, self.pullBar.frame.size.width, self.pullBar.frame.size.height);
		self.textViewContainer.frame = CGRectMake(self.textViewContainer.frame.origin.x, self.textViewContainer.frame.origin.y,self.textViewContainer.frame.size.width, self.textViewContainer.frame.size.height + translation.y);
		[gesture setTranslation:CGPointZero inView:self.pullBar];
	}
}

-(void) setViewAsMainView: (UIView*) view{
	self.mainContentView = view;
	self.oldMainContentViewFrame = view.frame;
	self.oldMainContentViewSuperview = view.superview;

	[self.mainContentView removeFromSuperview];
	[self addSubview:self.mainContentView];

	[UIView animateWithDuration:AVE_VIEW_FILLS_SCREEN_DURATION animations:^{
		view.frame = self.bounds;
		[view layoutIfNeeded];
		if ([view isKindOfClass: [VerbatmImageScrollView class]]) {
			[(VerbatmImageScrollView*)view setImageHeights];
		}
	} completion:^(BOOL finished) {
	}];
}

-(void) removeMainView {
	if (self.mainContentView) {
		[UIView animateWithDuration:AVE_VIEW_FILLS_SCREEN_DURATION animations:^{
			self.mainContentView.frame = self.oldMainContentViewFrame;
			if ([self.mainContentView isKindOfClass: [VerbatmImageScrollView class]]) {
				[(VerbatmImageScrollView*)self.mainContentView setImageHeights];
			}
		}  completion:^(BOOL finished) {
			[self.mainContentView removeFromSuperview];
			[self.oldMainContentViewSuperview addSubview:self.mainContentView];
			self.mainContentView = nil;
		}];
	}
}

-(BOOL) mainViewIsFullScreen {
	return (BOOL) self.mainContentView;
}

-(void) showText:(BOOL)show {
	if(show) {
		[self showText];
	} else {
		[self hideText];
	}
}

-(void) hideText {
	if (self.textViewContainer) {
		[self.textViewContainer removeFromSuperview];
	}
	if (self.pullBar) {
		[self.pullBar removeFromSuperview];
	}
}

-(void) showText {
	if (self.textViewContainer) {
		[self addSubview:self.textViewContainer];
	}
	if (self.pullBar) {
		[self addSubview:self.pullBar];
	}
}

-(void) viewDidAppear {
	for (UIView* subview in self.subviews) {
		if([subview conformsToProtocol:@protocol(AVEDelegate)]) {
			[(UIView<AVEDelegate>*) subview viewDidAppear];
		}
	}
}

@end
