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

@interface SwitchCategoryPullView()
@property (strong, nonatomic) UIView * trendingLabelContainerView;
@property (strong, nonatomic) UIView * topicsLabelContainerView;
@property (strong, nonatomic) UILabel * trendingLabel;
@property (strong, nonatomic) UILabel * topicsLabel;
//The circle icon that we move left/right to reveal the text
@property (strong, nonatomic) UIImageView * pullCircle;
@property (nonatomic) float pullCircleSize;
@property (nonatomic) BOOL isRight;
@property (nonatomic) CGPoint lastPoint;//keeps the last recorded point of a touch on the pull cirlce

#define SNAP_ANIMATION_DURATION 0.3
@end

@implementation SwitchCategoryPullView

- (id)initWithFrame:(CGRect)frame {
    
   self =  [super initWithFrame:frame];
    if(self){
        self.isRight = YES;
        [self initializeSubviews];
        [self initPullCircle];
    }
    return self;
}


//we start with the trending label showing and the topics label not visible
-(void) initializeSubviews {

	self.pullCircleSize = self.frame.size.height;

	self.trendingLabelContainerView = [[UIView alloc] initWithFrame:self.frame];
	self.topicsLabelContainerView = [[UIView alloc] initWithFrame:self.frame];

    self.trendingLabel.text = @"TRENDING";
	self.trendingLabel.font = [UIFont fontWithName:DEFAULT_FONT size:FEED_SLIDE_BAR_FONT_SIZE];
    self.topicsLabel.text = @"TOPICS";
	self.topicsLabel.font = [UIFont fontWithName:DEFAULT_FONT size:FEED_SLIDE_BAR_FONT_SIZE];

	// Labels must be centered taking into account circle size on either side
	CGRect labelFrame = CGRectMake(self.pullCircleSize,
								   0, self.frame.size.width - self.pullCircleSize*2, self.frame.size.height);
    self.trendingLabel.frame = labelFrame;
    self.topicsLabel.frame = labelFrame;

	[self.trendingLabelContainerView addSubview:self.trendingLabel];
	[self.topicsLabelContainerView addSubview:self.topicsLabel];

    [self addSubview:self.trendingLabelContainerView];
    [self addSubview:self.topicsLabelContainerView];
    self.clipsToBounds = YES;
}

//tbd - set the image for the pull circle
-(void) initPullCircle {

    self.pullCircle.frame = CGRectMake(self.frame.size.width - self.pullCircleSize,
									   self.frame.origin.y,
									   self.pullCircleSize, self.pullCircleSize);
	self.pullCircle.image = [UIImage imageNamed:PULLCIRCLE_ICON];
	self.pullCircle.backgroundColor = [UIColor clearColor];
    [self addPanGestureToView:self.pullCircle];
    [self.topicsLabelContainerView addSubview:self.pullCircle];
}

-(void) addPanGestureToView: (UIView *) view {
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pullCirclePan:)];
    pan.maximumNumberOfTouches = 1;//make sure it's only one finger
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:pan];
}

//Deals with pan gesture on circle
-(void) pullCirclePan:(UITapGestureRecognizer *) sender {
    switch(sender.state) {
        case UIGestureRecognizerStateBegan: {
            self.lastPoint = [sender locationOfTouch:0 inView:self];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint touch = [sender locationOfTouch:0 inView:self];
            CGFloat newXOffset = touch.x - self.lastPoint.x;
            CGFloat newX = self.pullCircle.frame.origin.x + newXOffset;
            if ((self.pullCircle.frame.origin.x + newXOffset) <= 0){
                newX = 0;
            }else if ((self.pullCircle.frame.origin.x + newXOffset) >=
                      self.frame.size.width - (self.pullCircle.frame.size.width)){
                
                newX =  self.frame.size.width - (self.pullCircle.frame.size.width);
            }
            
            self.pullCircle.frame = CGRectMake(newX, 0, self.pullCircle.frame.size.width,
                                               self.pullCircle.frame.size.height);
            self.topicsLabel.frame = CGRectMake(self.pullCircle.frame.origin.x + self.pullCircle.frame.size.width,
												0, self.frame.size.width - touch.x , self.topicsLabel.frame.size.height);
            self.trendingLabel.frame = CGRectMake(0, 0, self.pullCircle.frame.origin.x, self.trendingLabel.frame.size.height);
            self.lastPoint = touch;
            CGFloat centerX=  self.pullCircle.frame.origin.x;

			//noitify delegate that we have panned our pullCircle
            [self.categorySwitchDelegate pullCircleDidPan:(centerX / (self.frame.size.width - self.pullCircle.frame.size.width))];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self snapToEdge];
            break;
        }
        default: {
            return;
        }
    }
}


//snaps the pull circle to an edge after a pan
-(void)snapToEdge{
        [UIView animateWithDuration:SNAP_ANIMATION_DURATION animations: ^ {
            //snap left
            if(self.pullCircle.frame.origin.x <= (self.frame.size.width/2)){
               
                self.pullCircle.frame = CGRectMake(0, 0, self.pullCircle.frame.size.width,
                                                   self.pullCircle.frame.size.height);
                self.topicsLabel.frame = CGRectMake(self.pullCircle.frame.origin.x + self.pullCircle.frame.size.width, 0,self.frame.size.width - self.pullCircle.frame.size.width, self.topicsLabel.frame.size.height);
                //tbd
                self.trendingLabel.frame = CGRectMake(0,0,0, self.topicsLabel.frame.size.height);
                //inform the delegate that we have completed a switch to topics
                [self.categorySwitchDelegate switchedToTopics];
            //snap right
            }else{
                self.pullCircle.frame = CGRectMake(self.frame.size.width - (self.pullCircle.frame.size.width),
                                                   0, self.pullCircle.frame.size.width,
                                                   self.pullCircle.frame.size.height);
                
                self.topicsLabel.frame = CGRectMake(self.pullCircle.frame.origin.x + self.pullCircle.frame.size.width, 0,self.frame.size.width - self.pullCircle.frame.size.width, self.topicsLabel.frame.size.height);
                self.trendingLabel.frame = CGRectMake(0, 0,self.pullCircle.frame.origin.x, self.trendingLabel.frame.size.height);
                //inform the delegate that we have completed a switch to topics
                [self.categorySwitchDelegate switchedToTrending];
            }
        }];
}


#pragma mark - lazy instantiation -
-(UILabel *)trendingLabel {
    if(!_trendingLabel){
        _trendingLabel = [[UILabel alloc]init];
    }
    return _trendingLabel;
}

-(UILabel *)topicsLabel{
    if(!_topicsLabel){
        _topicsLabel = [[UILabel alloc] init];
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
