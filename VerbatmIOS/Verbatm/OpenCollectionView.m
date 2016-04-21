//
//  RearrangePV.m
//  Verbatm
//
//  Created by Iain Usiri on 11/15/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "OpenCollectionView.h"
#import "ContentPageElementScrollView.h"
#import "CollectionPinchView.h"

#import "ImagePinchView.h"
#import "VideoPinchView.h"

#import "SizesAndPositions.h"


@interface OpenCollectionView ()<ContentPageElementScrollViewDelegate>

@property (strong, nonatomic) ContentPageElementScrollView * scrollView;

@end


@implementation OpenCollectionView

-(instancetype) initWithFrame:(CGRect)frame andPinchViewArray:(NSMutableArray *) pinchViewArray{
	self = [super initWithFrame:frame];
	if(self) {
		[self formatBackground];
		[self setUpScrollViewWithPinchViews:pinchViewArray];
		[self addLongPressGesture];
	}
	return self;
}

-(void)formatBackground{
	//to make the view semi-transparent
    self.backgroundColor = [UIColor clearColor];
}

-(void) setUpScrollViewWithPinchViews:(NSMutableArray *) pinchViews{
	if(pinchViews.count) {
		self.scrollView = [[ContentPageElementScrollView alloc] initWithFrame:self.bounds andElement:nil];
		[self.scrollView openCollectionWithPinchViews: pinchViews];
		[self addSubview:self.scrollView];
        self.scrollView.contentPageElementScrollViewDelegate = self;
	}
}

-(void)addLongPressGesture {
	UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pinchObjectSelected:)];
	longPress.minimumPressDuration = 0.1f;
	[self addGestureRecognizer:longPress];
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
				//TODO: object unpinched
			}
		}else if (longPress.state == UIGestureRecognizerStateEnded ||
				  longPress.state == UIGestureRecognizerStateCancelled){
			[self.scrollView finishMovingSelectedItem];
		}
	}
}

//Custom scrollview delegate
-(void) pinchviewSelected:(PinchView *) pinchView{
    [self.delegate pinchViewSelected:pinchView];
}
-(void) deleteButtonPressedOnContentPageElementScrollView:(ContentPageElementScrollView*)scrollView{
    
}

-(void) exitView {
	NSMutableArray * finalArray = [self.scrollView closeCollection];
	[self.delegate collectionClosedWithFinalArray:finalArray];
}

@end
