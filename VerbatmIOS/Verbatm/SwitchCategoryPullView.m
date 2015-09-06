//
//  userFeedCategorySwitch.m
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "Icons.h"
#import "Styles.h"
#import "SwitchCategoryPullView.h"
#import "Durations.h"

@interface SwitchCategoryPullView()

@property (strong, nonatomic) UIView * trendingLabelContainerView;
@property (strong, nonatomic) UIView * topicsLabelContainerView;
@property (strong, nonatomic) UILabel * trendingLabel;
@property (strong, nonatomic) UILabel * topicsLabel;

@property (nonatomic) CGRect topicsContainerInitialFrame;
//The circle icon that we move left/right to reveal the text
@property (strong, nonatomic) UIImageView * pullCircle;
@property (nonatomic) float pullCircleSize;
@property (nonatomic) BOOL isRight;
@property (nonatomic) CGPoint lastPoint;//keeps the last recorded point of a touch on the pull circle


#define TRENDING_LABEL_TEXT @"TRENDING"
#define TOPICS_LABEL_TEXT @"TOPICS"

@end

@implementation SwitchCategoryPullView

- (id)initWithFrame:(CGRect)frame andBackgroundColor:(UIColor*)backgroundColor {
    
   self =  [super initWithFrame:frame];
    if(self){
        self.isRight = YES;
		[self setBackgroundColor:backgroundColor];
        [self initializeSubviews];
    }
    return self;
}


// The trending label is on a container view by itself
// The topics label is on a container view with the pull circle in order to cover the trending view when pulled
-(void) initializeSubviews {
	self.pullCircleSize = self.frame.size.height;
	[self initLabelContainers];
	[self initPullCircle];
}

-(void) initLabelContainers {
	self.trendingLabelContainerView = [[UIView alloc] initWithFrame: self.bounds];
	self.topicsContainerInitialFrame = CGRectMake(self.frame.size.width - self.pullCircleSize,
												  0, self.frame.size.width, self.frame.size.height);

	self.topicsLabelContainerView = [[UIView alloc] initWithFrame: self.topicsContainerInitialFrame];
	[self.topicsLabelContainerView setBackgroundColor:self.backgroundColor];

	[self formatLabel: self.trendingLabel];
	[self formatLabel: self.topicsLabel];

	[self.trendingLabelContainerView addSubview:self.trendingLabel];
	[self.topicsLabelContainerView addSubview:self.topicsLabel];

	[self addSubview:self.trendingLabelContainerView];
	[self addSubview:self.topicsLabelContainerView];
	self.clipsToBounds = YES;
}

-(void) formatLabel: (UILabel*) label {
	label.font = [UIFont fontWithName:DEFAULT_FONT size:FEED_SLIDE_BAR_FONT_SIZE];
	label.textAlignment = NSTextAlignmentCenter;
	label.frame = self.bounds;
}

//tbd - set the image for the pull circle
-(void) initPullCircle {
    self.pullCircle.frame = CGRectMake(0, 0, self.pullCircleSize, self.pullCircleSize);
	self.pullCircle.image = [UIImage imageNamed: PULLCIRCLE_ICON];
	self.pullCircle.backgroundColor = [UIColor clearColor];
    [self addPanGestureToView:self.pullCircle];
    [self.topicsLabelContainerView addSubview: self.pullCircle];
}

-(void) addPanGestureToView: (UIView *) view {
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pullCirclePan:)];
    pan.maximumNumberOfTouches = 1; //make sure it's only one finger
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:pan];
}

//Deals with pan gesture on circle
-(void) pullCirclePan:(UITapGestureRecognizer *) sender {

	CGFloat leastX = 0;
	CGFloat maxX = self.topicsLabelContainerView.frame.size.width - self.pullCircleSize;

    switch(sender.state) {
        case UIGestureRecognizerStateBegan: {
            self.lastPoint = [sender locationOfTouch:0 inView:self];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint touch = [sender locationOfTouch:0 inView:self];
            CGFloat newXOffset = touch.x - self.lastPoint.x;
            CGFloat newX = self.topicsLabelContainerView.frame.origin.x + newXOffset;

            if (newX < leastX){
                newX = leastX;
            } else if (newX > maxX) {
                newX = maxX;
            }
            
            self.topicsLabelContainerView.frame = CGRectMake(newX,
															 self.topicsLabelContainerView.frame.origin.y,
															 self.topicsLabelContainerView.frame.size.width,
															 self.topicsLabelContainerView.frame.size.height);
            self.lastPoint = touch;
			// notify delegate that we have panned our pullCircle
            [self.categorySwitchDelegate pullCircleDidPan:(newX / (maxX - leastX))];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self snapToEdgeWithLeastX: leastX andMaxX: maxX];
            break;
        }
        default: {
            return;
        }
    }
}


//snaps the pull circle to an edge after a pan
-(void) snapToEdgeWithLeastX: (CGFloat) leastX andMaxX: (CGFloat) maxX {

	float midX = (maxX - leastX)/2.f;
	float newX;
	BOOL snapLeft;

	//snap left else right
	if (self.topicsLabelContainerView.frame.origin.x <= midX) {
		newX = leastX;
		snapLeft = YES;
	} else {
		newX = maxX;
		snapLeft = NO;
	}

	[self.categorySwitchDelegate snapped: snapLeft];
	[UIView animateWithDuration:SNAP_ANIMATION_DURATION animations: ^ {
		self.topicsLabelContainerView.frame = CGRectMake(newX,
														 self.topicsLabelContainerView.frame.origin.y,
														 self.topicsLabelContainerView.frame.size.width,
														 self.topicsLabelContainerView.frame.size.height);

	}];
}


#pragma mark - lazy instantiation -
-(UILabel *)trendingLabel {
    if(!_trendingLabel){
        _trendingLabel = [[UILabel alloc]init];
		_trendingLabel.text = TRENDING_LABEL_TEXT;
    }
    return _trendingLabel;
}

-(UILabel *)topicsLabel{
    if(!_topicsLabel){
        _topicsLabel = [[UILabel alloc] init];
		_topicsLabel.text = TOPICS_LABEL_TEXT;
    }
    return _topicsLabel;
}

-(UIImageView *)pullCircle{
    if(!_pullCircle){
        _pullCircle =[[UIImageView alloc] init];
    }
    return _pullCircle;
}

@end
