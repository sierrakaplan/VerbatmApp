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

#define pullCircleWidth 100
#define SNAP_ANIMATION_DURATION 0.3
@end

@implementation userFeedCategorySwitch

- (id)initWithCoder:(NSCoder *)decoder{
    
   self =  [super initWithCoder:decoder];
    if(self){
        self.isRight = YES;
        [self initializeSubviews];
        [self initPullCircle];
        //temp
        self.pullCircle.backgroundColor = [UIColor blueColor];
        self.backgroundColor = [UIColor greenColor];
    }
    return self;
}


//we start with the trending label showing and the topics label not visible
-(void) initializeSubviews {
    self.trendingLabel.text = @"Trending";
    self.topicsLabel.text = @"Topics";
    self.trendingLabel.frame = self.bounds;
    self.topicsLabel.frame = CGRectMake(self.frame.size.width, 0, 0, self.frame.size.height);
    [self addSubview:self.trendingLabel];
    [self addSubview:self.topicsLabel];
    self.clipsToBounds = YES;
}

//tbd - set the image for the pull circle
-(void) initPullCircle {
    self.pullCircle.frame = CGRectMake(self.frame.size.width - pullCircleWidth, 0, pullCircleWidth, pullCircleWidth);
    [self addPanGestureToView:self.pullCircle];
    [self addSubview:self.pullCircle];
}

-(void) addPanGestureToView: (UIView *) view {
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pullCirclePan:)];
    pan.maximumNumberOfTouches = 1;//make sure it's only one finger
    self.pullCircle.userInteractionEnabled = YES;
    [self.pullCircle addGestureRecognizer:pan];
}

//tbd
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
            self.topicsLabel.frame = CGRectMake(self.pullCircle.frame.origin.x + self.pullCircle.frame.size.width, 0,self.frame.size.width - touch.x , self.topicsLabel.frame.size.height);
            self.trendingLabel.frame = CGRectMake(0, 0,self.pullCircle.frame.origin.x, self.trendingLabel.frame.size.height);
            self.lastPoint = touch;
            //noitify delegat that we have panned our pullCircle
        
            CGFloat centerX=  self.pullCircle.frame.origin.x;
            [self.categorySwitchDelegate pullCircleDidPan:(centerX / (self.frame.size.width - self.pullCircle.frame.size.width) )];
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
        _trendingLabel.backgroundColor = [UIColor greenColor];
    }
    return _trendingLabel;
}

-(UILabel *)topicsLabel{
    if(!_topicsLabel){
        _topicsLabel = [[UILabel alloc] init];
        _topicsLabel.backgroundColor = [UIColor yellowColor];
    }
    return _topicsLabel;
}

-(UIImageView *)pullCircle{
    if(!_pullCircle)_pullCircle =[[UIImageView alloc] init];
    return _pullCircle;
}

@end
