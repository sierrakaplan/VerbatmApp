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



@interface FeedTableViewCell()

@property (strong, nonatomic) UILabel * articleTitle;
@property (strong, nonatomic) UILabel * artileAuthorUsername;
@property (strong, nonatomic) UIView * leftSemiCircle;
@property (strong, nonatomic) UIView * rightSemiCircle;

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
    self.articleTitle.text = title;
    self.artileAuthorUsername.text = username;
    [self addSubview:self.articleTitle];
    [self addSubview:self.artileAuthorUsername];
}



-(void)setViewFrames{
    //set frames
    [self.articleTitle setFrame:CGRectMake(FEED_TEXT_X_OFFSET, FEED_TEXT_GAP, self.frame.size.width, TITLE_LABLE_HEIGHT)];
    [self.artileAuthorUsername setFrame:CGRectMake(FEED_TEXT_X_OFFSET, TITLE_LABLE_HEIGHT + 2*FEED_TEXT_GAP, self.frame.size.width, USERNAME_LABLE_HEIGHT)];
    
    //set text font formating
    [self.articleTitle setFont:[UIFont fontWithName:USERNAME_FONT_TYPE size:TITLE_FONT_SIZE]];
    [self.articleTitle setTextColor:[UIColor USERNAME_TEXT_COLOR]];
    self.articleTitle.backgroundColor = [UIColor clearColor];
    
    
    [self.artileAuthorUsername setFont:[UIFont fontWithName:USERNAME_FONT_TYPE size:USERNAME_FONT_SIZE]];
    [self.artileAuthorUsername setTextColor:[UIColor TITLE_TEXT_COLOR]];
    self.artileAuthorUsername.backgroundColor = [UIColor clearColor];
    self.leftSemiCircle.backgroundColor = [UIColor blackColor];
    self.rightSemiCircle.backgroundColor = [UIColor blackColor];
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


#pragma mark -lazy instantiation -

-(UIView *)leftSemiCircle {
    
    if(!_leftSemiCircle) {
        _leftSemiCircle = [[UIView alloc] init];
        _leftSemiCircle.frame = CGRectMake(NAVICON_WALL_OFFSET, SEMI_CIRCLE_Y, SEMI_CIRCLE_DIAMETER/2, SEMI_CIRCLE_DIAMETER);
        [self addSubview:_leftSemiCircle];
        [self bringSubviewToFront:_leftSemiCircle];
    }
    
    return _leftSemiCircle;
    
}


-(UIView *) rightSemiCircle{
    
    if(!_rightSemiCircle){
        
        _rightSemiCircle = [[UIView alloc] init];
        
        _rightSemiCircle.frame = CGRectMake(self.frame.size.width - SEMI_CIRCLE_DIAMETER/2 - NAVICON_WALL_OFFSET , SEMI_CIRCLE_Y, SEMI_CIRCLE_DIAMETER/2, SEMI_CIRCLE_DIAMETER);
        
        [self addSubview:_rightSemiCircle];
        [self addSubview:_rightSemiCircle];
    }
    return _rightSemiCircle;
}



-(UILabel *) articleTitle {
    
    if(!_articleTitle)_articleTitle = [[UILabel alloc]init];
    
    return _articleTitle;
    
}

-(UILabel *) artileAuthorUsername{
    
    if(!_artileAuthorUsername)_artileAuthorUsername = [[UILabel alloc]init];
    
    return _artileAuthorUsername;
    
}





-(void) formatCell {
    [self setBackgroundColor:[UIColor clearColor]];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
}





@end

