//
//  userFeedCategorySwitch.m
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "userFeedCategorySwitch.h"

@interface userFeedCategorySwitch()
@property (strong, nonatomic) UILabel * trendingLabel;
@property (strong, nonatomic) UILabel * topicsLabel;
@property (strong, nonatomic) UIImageView * pullCircle;//The circle icon that we move left/right to reveal the text
@property (nonatomic) BOOL isRight;
@property (nonatomic) CGPoint lastPoint;//keeps the last recorded point of a touch on the pull cirlce

#define pullCircleWidth 30
@end

@implementation userFeedCategorySwitch


-(instancetype) initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    if(self){
        self.isRight = YES;
        [self initPullCircle];
        [self initializeSubviews];
    }
    return self;
}

//we start with the trending label showing and the topics label not visible
//tbd - set the text formatting for the
-(void)initializeSubviews{
    self.trendingLabel.text = @"Trending";
    self.topicsLabel.text = @"Topics";
    self.trendingLabel.frame = self.bounds;
    self.topicsLabel.frame = CGRectMake(self.frame.size.width, 0, 0, self.frame.size.height);
    [self addSubview:self.trendingLabel];
    [self addSubview:self.topicsLabel];
}
//tbd - set the image for the pull circle
-(void)initPullCircle {
    self.pullCircle.frame = CGRectMake(self.frame.size.width - pullCircleWidth, 0, pullCircleWidth, pullCircleWidth);
    [self addPanGestureToView:self.pullCircle];
    [self addSubview:self.pullCircle];
}

-(void)addPanGestureToView: (UIView *) view {
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pullCirclePan:)];
    pan.maximumNumberOfTouches = 1;//make sure it's only one finger
    [view addGestureRecognizer:pan];
}

//tbd
-(void) pullCirclePan:(UITapGestureRecognizer *) sender {
    switch(sender.state) {
        case UIGestureRecognizerStateBegan: {
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint touch = [sender locationOfTouch:0 inView:self];
            if(!(touch.x <= 0) && !(touch.x >= self.frame.size.width -
                                    self.pullCircle.frame.size.width)){
                self.pullCircle.frame = CGRectMake(touch.x, 0, self.pullCircle.frame.size.width,
                                                   self.pullCircle.frame.size.height);
                
                self.topicsLabel.frame = CGRectMake(touch.x, 0,self.frame.size.width - touch.x , self.topicsLabel.frame.size.height);
                self.trendingLabel.frame = CGRectMake(0, 0,touch.x, self.trendingLabel.frame.size.height);
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            break;
        }
        default: {
            return;
        }
    }
}

@end
