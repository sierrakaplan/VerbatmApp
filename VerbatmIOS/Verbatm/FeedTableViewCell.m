//

//  verbatmArticle_TableViewCell.m

//  Verbatm

//

//  Created by Iain Usiri on 3/29/15.

//  Copyright (c) 2015 Verbatm. All rights reserved.

//

#import "FeedTableViewCell.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "Durations.h"


@interface FeedTableViewCell()

@property (strong, nonatomic) UILabel * povTitle;
@property (strong, nonatomic) UILabel * povCreatorUsername;
@property (strong, nonatomic) UIImageView * leftSemiCircle;
@property (strong, nonatomic) UIImageView * rightSemiCircle;

//point of the left finger in the pinch gesture
@property (nonatomic) CGPoint lastLeftestPoint;
//point of the right finger in the pinch gesture
@property (nonatomic) CGPoint lastRightestPoint;

#define SEMI_CIRCLE_DIAMETER 50
#define SEMI_CIRCLE_Y 5

@end



@implementation FeedTableViewCell
-(void)layoutSubviews{
    [self formatCell];
    [self setViewFrames];
    [self addPinchGestureToSelf];
}



-(void)setContentWithUsername:(NSString *) username andTitle: (NSString *) title {
    self.povTitle.text = title;
    self.povCreatorUsername.text = username;
    [self addSubview:self.povTitle];
    [self addSubview:self.povCreatorUsername];
}



-(void)setViewFrames{
    //set frames
    [self.povTitle setFrame:CGRectMake(FEED_TEXT_X_OFFSET, FEED_TEXT_GAP, self.frame.size.width, TITLE_LABLE_HEIGHT)];
    [self.povCreatorUsername setFrame:CGRectMake(FEED_TEXT_X_OFFSET, TITLE_LABLE_HEIGHT + 2*FEED_TEXT_GAP, self.frame.size.width, USERNAME_LABLE_HEIGHT)];
    
    //set text font formating
    [self.povTitle setFont:[UIFont fontWithName:TITLE_FONT size:TITLE_FONT_SIZE]];
    [self.povTitle setTextColor:[UIColor TITLE_TEXT_COLOR]];
    self.povTitle.backgroundColor = [UIColor clearColor];
    
    
    [self.povCreatorUsername setFont:[UIFont fontWithName:USERNAME_FONT size:USERNAME_FONT_SIZE]];
    [self.povCreatorUsername setTextColor:[UIColor USERNAME_TEXT_COLOR]];
    self.povCreatorUsername.backgroundColor = [UIColor clearColor];
    self.leftSemiCircle.backgroundColor = [UIColor clearColor];
    self.rightSemiCircle.backgroundColor = [UIColor clearColor];
}

#pragma mark - Gestures -
-(void)addPinchGestureToSelf{
    
    UIPinchGestureRecognizer * pinchG = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:
                                         @selector(pinchingSemiCirclesTogether:)];
    [self addGestureRecognizer:pinchG];
}

//moves the views frame to the provided offset
-(void)translateView:(UIView *) view withXOffset:(CGFloat) offset{
    view.frame = CGRectMake(view.frame.origin.x + offset, view.frame.origin.y, view.frame.size.width,
                            view.frame.size.height);
}

-(void)pinchingSemiCirclesTogether:(UIPinchGestureRecognizer *)sender{
    //make sure it's only two touches that are registered
    if(sender.numberOfTouches != 2) return;
    switch(sender.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint touch1 = [sender locationOfTouch:0 inView:self];
            CGPoint touch2 = [sender locationOfTouch:1 inView:self];
            if(touch1.x < touch2.x){
                self.lastLeftestPoint = touch1;
                self.lastRightestPoint = touch2;
            }else{
                self.lastLeftestPoint = touch2;
                self.lastRightestPoint = touch1;
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint touch1 = [sender locationOfTouch:0 inView:self];
            CGPoint touch2 = [sender locationOfTouch:1 inView:self];
            if(touch1.x < touch2.x){
                [self translateView:self.leftSemiCircle withXOffset:touch1.x - self.lastLeftestPoint.x];
                [self translateView:self.rightSemiCircle withXOffset:touch2.x - self.lastRightestPoint.x];
                self.lastLeftestPoint = touch1;
                self.lastRightestPoint = touch2;
            }else{
                [self translateView:self.leftSemiCircle withXOffset:touch2.x - self.lastLeftestPoint.x];
                [self translateView:self.rightSemiCircle withXOffset:touch1.x - self.lastRightestPoint.x];
                self.lastLeftestPoint = touch2;
                self.lastRightestPoint = touch1;
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


/*animates the semicircles either to the center or to their sides*/
-(void)positionSemiCirclesCenter:(BOOL)toCenter{
    
    if(toCenter){
        [UIView animateWithDuration:0.8 animations:^{
            CGPoint  myCenter = self.center;
            
            self.leftSemiCircle.frame = CGRectMake(myCenter.x - ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, SEMI_CIRCLE_Y, ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, self.frame.size.height - (2 * SEMI_CIRCLE_Y));
            self.rightSemiCircle.frame = CGRectMake(myCenter.x +((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, SEMI_CIRCLE_Y, ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, self.frame.size.height - (2 * SEMI_CIRCLE_Y));
        }];
        
    }else{
        [UIView animateWithDuration:0.8 animations:^{
            CGPoint  myCenter = self.center;
            
            self.leftSemiCircle.frame = CGRectMake(myCenter.x - ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, SEMI_CIRCLE_Y, ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, self.frame.size.height - (2 * SEMI_CIRCLE_Y));
            self.rightSemiCircle.frame = CGRectMake(myCenter.x +((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, SEMI_CIRCLE_Y, ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, self.frame.size.height - (2 * SEMI_CIRCLE_Y));
        }];
        
    }
    
}



#pragma mark -lazy instantiation -

-(UIImageView *)leftSemiCircle {
    if(!_leftSemiCircle) {
        _leftSemiCircle = [[UIImageView alloc] init];
        _leftSemiCircle.frame = CGRectMake(HOME_NAV_ICON_OFFSET, SEMI_CIRCLE_Y, ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, self.frame.size.height - (2 * SEMI_CIRCLE_Y));
        _leftSemiCircle.image = [UIImage imageNamed:@"half_photo_left"];
        [self addSubview:_leftSemiCircle];
        [self bringSubviewToFront:_leftSemiCircle];
    }
    
    return _leftSemiCircle;
    
}


-(UIImageView *) rightSemiCircle{
    
    if(!_rightSemiCircle){
        
        _rightSemiCircle = [[UIImageView alloc] init];
        
        _rightSemiCircle.frame = CGRectMake(self.frame.size.width - SEMI_CIRCLE_DIAMETER/2 - HOME_NAV_ICON_OFFSET , SEMI_CIRCLE_Y, ((self.frame.size.height - (2 * SEMI_CIRCLE_Y))/2)+20, self.frame.size.height - (2 * SEMI_CIRCLE_Y));
        _rightSemiCircle.image = [UIImage imageNamed:@"half_photo_right"];
        [self addSubview:_rightSemiCircle];
        [self addSubview:_rightSemiCircle];
    }
    return _rightSemiCircle;
}



-(UILabel *) povTitle {
    
    if(!_povTitle)_povTitle = [[UILabel alloc]init];
    
    return _povTitle;
    
}

-(UILabel *) povCreatorUsername{
    
    if(!_povCreatorUsername)_povCreatorUsername = [[UILabel alloc]init];
    
    return _povCreatorUsername;
    
}





-(void) formatCell {
    [self setBackgroundColor:[UIColor clearColor]];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
}





@end

