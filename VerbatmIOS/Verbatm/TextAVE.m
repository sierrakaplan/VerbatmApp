//
//  v_textview.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "TextAVE.h"
#import "Styles.h"
#import "TextOverAveView.h"
#import "SizesAndPositions.h"
#import "Icons.h"

@interface TextAVE()

@property (strong, nonatomic) TextOverAVEView* textViewContainer;
@property (nonatomic) float textViewContentSize;
@property (strong, nonatomic) UIView* blurView;
@property (strong, nonatomic) UIView* pullBar;
@property (nonatomic) CGRect pullBarStartFrame;
@property (nonatomic) CGRect pullBarBottomFrame;

@end
@implementation TextAVE

//provide for a little bit of spacing on top and belows
/*
 *This function initializes the text view to the frame issue
 */
-(id)initWithFrame:(CGRect)frame andText:(NSString*) text{
    if((self = [super initWithFrame:frame])) {
		[self setBackgroundColor:[UIColor blackColor]];
		self.textViewContainer = [[TextOverAVEView alloc] initWithFrame:self.bounds];
		[self.textViewContainer setText:text];

		self.textViewContentSize = [self.textViewContainer getHeightOfText];
		if (self.textViewContentSize < self.bounds.size.height) {
			float textViewYPos = (self.bounds.size.height - self.textViewContentSize)/2.f;
			CGRect newTextContainerFrame = CGRectMake(self.bounds.origin.x, textViewYPos, self.bounds.size.width, self.textViewContentSize);
			self.textViewContainer.frame = newTextContainerFrame;
		}
        
		[self addSubview:self.textViewContainer];

		if (self.textViewContentSize > (TEXT_OVER_AVE_STARTING_HEIGHT+ TEXT_OVER_AVE_BORDER)) {
			float blurViewYPos = TEXT_OVER_AVE_STARTING_HEIGHT + self.textViewContainer.frame.origin.y;
			CGRect blurViewFrame = CGRectMake(self.bounds.origin.x, blurViewYPos, self.bounds.size.width, self.bounds.size.height - blurViewYPos);
			self.blurView = [[UIView alloc] initWithFrame:blurViewFrame];
			[self.blurView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.9]];
			[self addSubview:self.blurView];

			[self addPullDownBarForText];
		}

    }
    return self;
}

-(void)addPullDownBarForText {
	self.pullBarStartFrame = CGRectMake(0,self.blurView.frame.origin.y,
										self.frame.size.width, TEXT_OVER_AVE_PULLBAR_HEIGHT);
	float pullBarBottomFrameYPos = self.frame.size.height - TEXT_OVER_AVE_PULLBAR_HEIGHT;
	if (pullBarBottomFrameYPos > (self.textViewContentSize + self.textViewContainer.frame.origin.y)) {
		pullBarBottomFrameYPos = self.textViewContentSize + self.textViewContainer.frame.origin.y;
	}
	self.pullBarBottomFrame = CGRectMake(0, pullBarBottomFrameYPos,
										 self.frame.size.width, TEXT_OVER_AVE_PULLBAR_HEIGHT);

	self.pullBar = [[UIView alloc] initWithFrame:self.pullBarStartFrame];
	self.pullBar.backgroundColor = [UIColor clearColor];

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

-(void)addSwipeGestureToView:(UIView *) view {
	UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc]initWithTarget: self action:@selector(repositionBlurView:)];
	[view addGestureRecognizer:panGesture];
}


//makes blur view move down with pull bar as pull bar is dragged
-(void)repositionBlurView:(UIPanGestureRecognizer *)gesture {
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
				if(self.textViewContentSize > (self.frame.size.height - TEXT_OVER_AVE_PULLBAR_HEIGHT)) {
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
		self.blurView.frame = CGRectMake(self.blurView.frame.origin.x, self.blurView.frame.origin.y + translation.y,self.blurView.frame.size.width, self.blurView.frame.size.height - translation.y);
		[gesture setTranslation:CGPointZero inView:self.pullBar];
	}
}

@end
