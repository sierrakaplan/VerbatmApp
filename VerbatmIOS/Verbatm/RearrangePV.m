//
//  RearrangePV.m
//  Verbatm
//
//  Created by Iain Usiri on 11/15/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "RearrangePV.h"
#import "ContentPageElementScrollView.h"
#import "CollectionPinchView.h"

#import "ImagePinchView.h"
#import "VideoPinchView.h"

#import "SizesAndPositions.h"
@interface RearrangePV ()
    @property (strong, nonatomic) ContentPageElementScrollView * scrollView;
@end

@implementation RearrangePV


-(instancetype) initWithFrame:(CGRect)frame andPinchViewArray:(NSMutableArray * ) pinchViewArray{
    self = [super initWithFrame:frame];
    if(self){
        [self setUpScrollViewWithPinchViews:pinchViewArray];
        [self addLongPressGesture];
        [self addTapGesture];
        [self formatBackground];
    }
    
    return self;
}


-(void) setUpScrollViewWithPinchViews:(NSMutableArray *) pvArray{
    
    if(pvArray.count) {
    
        PinchView * pv = pvArray[0];
        
        CGFloat svHeight = pv.frame.size.height + (ELEMENT_Y_OFFSET_DISTANCE*2);
        CGFloat svOriginY = self.center.y - svHeight/2.f;
        
        CGRect frame = CGRectMake(0, svOriginY, self.frame.size.width, svHeight);
        
        self.scrollView = [[ContentPageElementScrollView alloc] initWithFrame:frame andElement:nil];
        [self.scrollView openCollectionWithPinchViews:pvArray];
        [self addSubview:self.scrollView];
    }
}

-(void)addLongPressGesture {
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pinchObjectSelected:)];
    [self addGestureRecognizer:longPress];
}
-(void) addTapGesture{
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self addGestureRecognizer:tapGesture];
}

-(void)viewTapped:(UITapGestureRecognizer *) tapped{
    [self exitRearrangeView];
}

-(void)pinchObjectSelected:(UILongPressGestureRecognizer *) longPress{
    if([longPress numberOfTouches] == 1) {
        CGPoint touch = [longPress locationOfTouch:0 inView:self];
        if(longPress.state == UIGestureRecognizerStateBegan){
            [self.scrollView selectItemInOpenCollectionFromTouch:touch];
        }else if (longPress.state == UIGestureRecognizerStateChanged){
            //the scrollview manages the movement of the selected object
            PinchView * unPinched = [self.scrollView moveSelectedItemFromTouch:touch];
            
            //this only passes if the user moves the pinch object out of the bounds of the scrollview
            if (unPinched) {
                //object unpinched -- do something
            }
        }else if (longPress.state == UIGestureRecognizerStateEnded ||
                  longPress.state == UIGestureRecognizerStateCancelled){
            [self.scrollView finishMovingSelectedItem];
        }
    }
}


-(void) exitRearrangeView{
    NSMutableArray * finalArray = [self.scrollView closeCollection];
    [self.delegate exitPVWithFinalArray:finalArray];

}



-(void)formatBackground{
    //to make the view semi-transparent
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
