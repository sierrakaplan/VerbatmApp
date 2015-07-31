/*
//  ContentPageElementScrollView.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/27/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
// 

 */


#import "ContentPageElementScrollView.h"
#import "PinchView.h"
#import "CollectionPinchView.h"
#import "Durations.h"
#import "SizesAndPositions.h"
#import "UserPinchViews.h"

@interface ContentPageElementScrollView()

@property (nonatomic) CGPoint initialContentOffset;
@property (nonatomic) CGSize initialContentSize;
@property (strong, nonatomic, readwrite) UIView<ContentDevElementDelegate>* pageElement;

//if page element is a CollectionPinchView
@property (nonatomic, readwrite) BOOL isCollection;
@property (nonatomic, readwrite) BOOL collectionIsOpen;
@property (strong, nonatomic) NSMutableArray* collectionPinchViews;

//long press selecting item
@property (strong, nonatomic, readwrite) PinchView* selectedItem;
@property (nonatomic) CGPoint previousLocationOfTouchPoint_PAN;
@property (nonatomic) CGRect previousFrameInLongPress;
@property (nonatomic) CGRect potentialFrameAfterLongPress;

@end

@implementation ContentPageElementScrollView

-(id) initWithFrame:(CGRect)frame andElement:(UIView<ContentDevElementDelegate>*) element {
	self = [super initWithFrame:frame];
	if (self) {
		[self formatScrollView];
		[self changePageElement:element];
	}
	return self;
}

-(void) formatScrollView {
	float contentWidth = self.frame.size.width*3;
	self.initialContentSize = CGSizeMake(contentWidth, 0);
	self.contentSize = self.initialContentSize;
	self.initialContentOffset = CGPointMake(contentWidth/3.f, 0);
	self.contentOffset = self.initialContentOffset;
	self.pagingEnabled = NO;
	self.showsHorizontalScrollIndicator = NO;
	self.showsVerticalScrollIndicator = NO;
}

#pragma mark - Change Page Element -

//checks if the two scroll views can be pinched together
-(BOOL) okToPinchWith:(ContentPageElementScrollView*)otherScrollView {
	if([self.pageElement isKindOfClass:[PinchView class]] && [otherScrollView.pageElement isKindOfClass:[PinchView class]]
	   && !([self isCollection] && [otherScrollView isCollection])) {
		return YES;
	}
	return NO;
}

-(PinchView*) pinchWith:(ContentPageElementScrollView*)otherScrollView {
	PinchView* newPinchView;

	[[UserPinchViews sharedInstance] removePinchView:(PinchView*)otherScrollView.pageElement];
	[[UserPinchViews sharedInstance] removePinchView:(PinchView*)self.pageElement];

	if(self.isCollection) {
		newPinchView = [(CollectionPinchView*)self.pageElement pinchAndAdd:(PinchView*)otherScrollView.pageElement];
	} else if(otherScrollView.isCollection){
		newPinchView = [(CollectionPinchView*)otherScrollView.pageElement pinchAndAdd:(PinchView*)self.pageElement];
	} else {
		NSMutableArray* pinchViewArray = [[NSMutableArray alloc] initWithObjects:self.pageElement, otherScrollView.pageElement, nil];
		newPinchView = [PinchView pinchTogether:pinchViewArray];
		pinchViewArray = nil;
	}
	[[UserPinchViews sharedInstance] addPinchView:(PinchView*)newPinchView];
	[self changePageElement:newPinchView];
	[otherScrollView removeFromSuperview];
	return newPinchView;
}

-(void) changePageElement:(UIView<ContentDevElementDelegate>*) newPageElement {
	if(newPageElement == self.pageElement) {
		return;
	}
	if (self.pageElement) {
		[self.pageElement removeFromSuperview];
	}
	self.pageElement = newPageElement;
	if ([self.pageElement isKindOfClass:[CollectionPinchView class]]) {
		self.isCollection = YES;
	} else {
		self.isCollection = NO;
	}
	self.collectionIsOpen = NO;
	[self addSubview:self.pageElement];
}


#pragma mark - Deleting -

//Returns if delete swipe is far enough
-(BOOL) isDeleting {
	if (self.collectionIsOpen) {
		return NO;
	}

	float deleteThreshold = self.frame.size.width/2.f;
	if(fabs(self.contentOffset.x - self.initialContentOffset.x) < deleteThreshold) {
		return NO;
	}
	return YES;
}

-(void) animateBackToInitialPosition {
	[self setContentOffset:self.initialContentOffset animated:YES];
}

-(void) animateOffScreen {
	CGPoint newContentOffset = CGPointMake(0, self.initialContentOffset.y);
	if (self.contentOffset.x > self.initialContentOffset.x) {
		newContentOffset.x = self.initialContentSize.width;
	}
	[self setContentOffset:newContentOffset animated:YES];
}

#pragma mark - Open and close collection -

//remove collection view from scrollview and add all its children instead
-(BOOL) openCollection {
	if (!self.isCollection
		|| self.collectionIsOpen) {
		return NO;
	}
	self.collectionIsOpen = YES;
	if ([(CollectionPinchView*)self.pageElement containsVideo]) {
		[[(CollectionPinchView*)self.pageElement videoView] stopVideo];
	}
	[self.pageElement removeFromSuperview];
	[self displayCollectionPinchViews:[(CollectionPinchView*)self.pageElement pinchedObjects]];
	return YES;
}

//array of PinchViews
-(void) displayCollectionPinchViews:(NSMutableArray *) pinchViews {

	float pinchViewSize = [(PinchView*)self.pageElement radius]*2;
	self.contentSize = CGSizeMake((ELEMENT_OFFSET_DISTANCE + pinchViewSize)*[pinchViews count],
								  self.contentSize.height);

	[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
		int xPosition = ELEMENT_OFFSET_DISTANCE;

		for(PinchView* pinchView in pinchViews) {
			CGRect newFrame = CGRectMake(xPosition, ELEMENT_OFFSET_DISTANCE/2, pinchViewSize, pinchViewSize);
			[pinchView specifyFrame:newFrame];
			[self addSubview:pinchView];
			xPosition += pinchView.frame.size.width + ELEMENT_OFFSET_DISTANCE;
			[pinchView renderMedia];
		}

	}];
	self.collectionPinchViews = pinchViews;
}

-(BOOL) closeCollection {
	if (!self.isCollection
		|| !self.collectionIsOpen) {
		return NO;
	}

	for (PinchView* pinchView in self.collectionPinchViews) {
		if ([pinchView isKindOfClass:[VideoPinchView class]]) {
			[[(VideoPinchView*)pinchView videoView] stopVideo];
		}
		[pinchView removeFromSuperview];
	}
	self.collectionIsOpen = NO;
	self.contentSize = self.initialContentSize;
	self.contentOffset = self.initialContentOffset;
	[self addSubview:self.pageElement];
	[(CollectionPinchView*)self.pageElement updateMedia];
	[(CollectionPinchView*)self.pageElement renderMedia];
	self.collectionPinchViews = Nil;
	return YES;
}

//moves the views in the scrollview of the opened collection
-(void) moveViewsWithTotalDifference: (float)difference {
	if (!self.collectionIsOpen) {
		return;
	}

	float pinchViewSize = [(PinchView*)self.pageElement radius]*2;
	float scaleFactor = difference/HORIZONTAL_PINCH_THRESHOLD;
	for(NSInteger i = 0; i < self.collectionPinchViews.count; i++) {
		float originalXPosition = (ELEMENT_OFFSET_DISTANCE + pinchViewSize)*i;
		float originalDistanceFromMiddle = (self.contentSize.width/2.f - pinchViewSize/2.f) - originalXPosition;
		float xTranslation = scaleFactor*originalDistanceFromMiddle;
		CGRect oldFrame = ((PinchView *)self.collectionPinchViews[i]).frame;
		CGRect newFrame = CGRectMake(originalXPosition + xTranslation, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
		((PinchView *)self.collectionPinchViews[i]).frame = newFrame;
	}
}


-(void) moveOpenCollectionViewsBack {
	if(!self.collectionIsOpen) {
		return;
	}

	float pinchViewSize = [(PinchView*)self.pageElement radius]*2;

	[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
		int xPosition = ELEMENT_OFFSET_DISTANCE;
		for(PinchView* pinchView in self.collectionPinchViews) {
			CGRect newFrame = CGRectMake(xPosition, ELEMENT_OFFSET_DISTANCE/2, pinchViewSize, pinchViewSize);
			[pinchView specifyFrame:newFrame];
			xPosition += pinchView.frame.size.width + ELEMENT_OFFSET_DISTANCE;
		}
	} completion:^(BOOL finished) {
	}];
}

-(void) selectItemInOpenCollectionFromTouch:(CGPoint) touch {
	if (!self.collectionIsOpen) {
		return;
	}

	if(touch.x < ((PinchView*)self.collectionPinchViews[0]).frame.origin.x) {
		return;
	}

	for (PinchView* pinchView in self.collectionPinchViews) {

		//we stop when we find the first one
		if((pinchView.frame.origin.x + pinchView.frame.size.width) > touch.x) {
			self.selectedItem = pinchView;
			//add it to its parent's scroll view so that it can be moved outside
			//the bounds of the scroll view to be unpinched
			[self.selectedItem removeFromSuperview];
			self.selectedItem.frame = CGRectMake(self.selectedItem.frame.origin.x + self.frame.origin.x,
												 self.selectedItem.frame.origin.y + self.frame.origin.y,
												 self.selectedItem.frame.size.width, self.selectedItem.frame.size.height);
			[self.superview addSubview:self.selectedItem];
			[self.selectedItem markAsSelected:YES];
			self.previousLocationOfTouchPoint_PAN = touch;
			self.previousFrameInLongPress = self.selectedItem.frame;
			return;
		}
	}
}

-(PinchView*) moveSelectedItemFromTouch:(CGPoint) touch {
	if (!self.collectionIsOpen || !self.selectedItem) {
		return Nil;
	}

	float xDifference  = touch.x - self.previousLocationOfTouchPoint_PAN.x;
	float yDifference  = touch.y - self.previousLocationOfTouchPoint_PAN.y;
	CGRect newFrame = [self newTranslationFrameForView:self.selectedItem andXDifference:xDifference andYDifference:yDifference];

	//check if new location is out of the bounds of the collection view, and if so unpinch
	//the selected view and return it so it can be re placed
	if (newFrame.origin.y > (self.frame.origin.y + self.frame.size.height)
		|| (newFrame.origin.y + newFrame.size.height) < self.frame.origin.y) {
		PinchView* unPinched = self.selectedItem;
		self.selectedItem = Nil;
		[self.collectionPinchViews removeObject:unPinched];
		[[UserPinchViews sharedInstance] removePinchView:(CollectionPinchView*)self.pageElement];
		[(CollectionPinchView*)self.pageElement unPinchAndRemove:unPinched];
		[[UserPinchViews sharedInstance] addPinchView:(CollectionPinchView*)self.pageElement];
		return unPinched;
	}

	//move item
	[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION/2.f animations:^{
		self.selectedItem.frame = newFrame;
	}];

	//swap item if necessary
	NSInteger viewIndex = [self.collectionPinchViews indexOfObject:self.selectedItem];
	PinchView* leftView = Nil;
	PinchView* rightView = Nil;

	if(viewIndex !=0) {
		leftView = self.collectionPinchViews[viewIndex-1];
	}
	if (viewIndex+1 < [self.collectionPinchViews count]) {
		rightView = self.collectionPinchViews[viewIndex+1];
	}
	//check if object has moved to the halfway mark of the view next to it, if so swap them
	if(leftView && (newFrame.origin.x - self.frame.origin.x + newFrame.size.width/2.f)
	   < (leftView.frame.origin.x + leftView.frame.size.width)) {
		[self swapWithLeftView: leftView];
	}
	//check if object has moved down the halfway mark of the view below it, if so swap them
	else if(rightView && (newFrame.origin.x - self.frame.origin.x + newFrame.size.width/2.f)
			> rightView.frame.origin.x) {
		[self swapWithRightView: rightView];
	}

	//move the offest of the main scroll view
//	[self moveOffsetBasedOnSelectedItem];
	self.previousLocationOfTouchPoint_PAN = touch;

	return Nil;
}

//Takes a change in horizontal position and constructs the frame for the views new position
-(CGRect) newTranslationFrameForView: (UIView*)view andXDifference: (float) xDifference andYDifference: (float) yDifference {
	CGRect frame= CGRectMake(view.frame.origin.x+xDifference, view.frame.origin.y + yDifference,
							 view.frame.size.width, view.frame.size.height);
	return frame;
}

//swap currently selected item's frame with view to the left of it
-(void) swapWithLeftView: (PinchView*) leftView {
	[self swapPinchView:self.selectedItem andPinchView:leftView];

	[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION/2 animations:^{

		self.previousFrameInLongPress = CGRectMake(leftView.frame.origin.x + self.frame.origin.x,
													   leftView.frame.origin.y + self.frame.origin.y,
													   self.previousFrameInLongPress.size.width,
													   self.previousFrameInLongPress.size.height);

		leftView.frame = CGRectMake(self.previousFrameInLongPress.origin.x - self.frame.origin.x,
								   self.previousFrameInLongPress.origin.y - self.frame.origin.y,
								   leftView.frame.size.width, leftView.frame.size.height);
	}];
}

//swap currently selected item's frame with view to the right of it
-(void) swapWithRightView: (PinchView*) rightView {
	[self swapPinchView:self.selectedItem andPinchView:rightView];

	[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION/2 animations:^{

		self.previousFrameInLongPress = CGRectMake(rightView.frame.origin.x + self.frame.origin.x,
													   rightView.frame.origin.y + self.frame.origin.y,
													   self.previousFrameInLongPress.size.width,
													   self.previousFrameInLongPress.size.height);

		rightView.frame = CGRectMake(self.previousFrameInLongPress.origin.x - self.frame.origin.x,
									  self.previousFrameInLongPress.origin.y - self.frame.origin.y,
									  rightView.frame.size.width, rightView.frame.size.height);
	}];
}

//swaps scroll views int he pageElementScrollView array
-(void) swapPinchView: (PinchView *) pinchView1 andPinchView: (PinchView *) pinchView2 {
	NSInteger index1 = [self.collectionPinchViews indexOfObject: pinchView1];
	NSInteger index2 = [self.collectionPinchViews indexOfObject: pinchView2];
	[self.collectionPinchViews replaceObjectAtIndex: index1 withObject: pinchView2];
	[self.collectionPinchViews replaceObjectAtIndex: index2 withObject: pinchView1];
}

//adjusts offset of main scroll view so selected item is in focus
-(void) moveOffsetBasedOnSelectedItem {
	float newXOffset = 0;
	if (self.contentOffset.x > self.selectedItem.frame.origin.x - (self.selectedItem.frame.size.width/2.f) && (self.contentOffset.x - AUTO_SCROLL_OFFSET >= 0)) {

		newXOffset = -AUTO_SCROLL_OFFSET;
	} else if (self.contentOffset.x + self.frame.size.width < (self.selectedItem.frame.origin.x + self.selectedItem.frame.size.width) && self.contentOffset.x + AUTO_SCROLL_OFFSET < self.contentSize.width) {

		newXOffset = AUTO_SCROLL_OFFSET;
	}

	if (newXOffset != 0) {
		CGPoint newOffset = CGPointMake(self.contentOffset.x + newXOffset, self.contentOffset.y);
		[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
			self.contentOffset = newOffset;
		}];
	}
}

-(void) finishMovingSelectedItem {

	[self.selectedItem removeFromSuperview];
	self.selectedItem.frame = CGRectMake(self.previousFrameInLongPress.origin.x - self.frame.origin.x,
										 self.previousFrameInLongPress.origin.y - self.frame.origin.y,
										 self.previousFrameInLongPress.size.width,
										 self.previousFrameInLongPress.size.height);

	[self addSubview:self.selectedItem];

	[self.selectedItem markAsSelected:NO];

	//sanitize for next run
	self.selectedItem = Nil;
}

@end
