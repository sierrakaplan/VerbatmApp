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
#import "Icons.h"
#import "SizesAndPositions.h"
#import "PostInProgress.h"
#import "MediaSelectTile.h"

@interface ContentPageElementScrollView()

#pragma mark - Page element properties
@property (nonatomic) CGPoint initialContentOffset;
@property (nonatomic) CGSize initialContentSize;
@property (strong, nonatomic, readwrite) UIView<ContentDevElementDelegate>* pageElement;
@property (nonatomic) CGRect pageElementOriginalFrame;

#pragma mark - If page element is a CollectionPinchView
@property (nonatomic, readwrite) BOOL isCollection;
@property (nonatomic, readwrite) BOOL collectionIsOpen;
//reference to the array of pinch views also contained in the collection view
@property (strong, nonatomic) NSMutableArray* collectionPinchViews;

#pragma mark - Delete button
@property (strong, nonatomic) UIButton * deleteButton;
@property (nonatomic) CGRect deleteButtonFrame;

#pragma mark - Long press selecting item
@property (strong, nonatomic, readwrite) SingleMediaAndTextPinchView* selectedItem;
@property (nonatomic) float contentOffsetXBeforeLongPress;
@property (nonatomic) CGPoint previousLocationOfTouchPoint_PAN;
@property (nonatomic) CGRect previousFrameInLongPress;
@property (nonatomic) CGPoint panTouchLocation;
@property (nonatomic) CGFloat pinchViewStartSize;

#define MEDIA_SELECT_TILE_DELETE_BUTTON_OFFSET 7
#define ANIMATE_TO_DELETE_MODE_OR_BACK_DURATION 0.1f

@end

@implementation ContentPageElementScrollView

-(id) initWithFrame:(CGRect)frame andElement:(UIView<ContentDevElementDelegate>*) element {
	self = [super initWithFrame:frame];
	if (self) {
		[self formatScrollView];
		if(element)[self changePageElement:element];
        if([element isKindOfClass:[PinchView class]]){
            [self createDeleteButton];
        }
    }
    
	return self;
}

-(void) formatScrollView {
	self.pagingEnabled = NO;
	self.showsHorizontalScrollIndicator = NO;
	self.showsVerticalScrollIndicator = NO;
    self.bounces = NO;
}

-(void)createDeleteButton {
    self.deleteButtonFrame = CGRectMake(self.pageElement.frame.origin.x +
                                        self.pageElement.frame.size.width + DELETE_ICON_X_OFFSET,
                                        self.pageElement.center.y - (DELETE_ICON_HEIGHT/2.f),
                                        DELETE_ICON_WIDTH, DELETE_ICON_HEIGHT);
    self.deleteButton = [[UIButton alloc] initWithFrame:
                         self.deleteButtonFrame];
    
    [self.deleteButton setImage:[UIImage imageNamed:DELETE_PINCHVIEW_ICON] forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deleteButton];
}

-(void)deleteButtonPressed:(UIButton*) sender{
    [self.contentPageElementScrollViewDelegate deleteButtonPressedOnContentPageElementScrollView:self];
}

//puts the pinch view right in the middle
-(void)centerView{
    self.contentOffset = self.initialContentOffset;
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

-(PinchView*) pinchWith:(ContentPageElementScrollView*)otherScrollView currentIndex:(NSInteger)currentIndex otherIndex:(NSInteger)otherIndex {

	// remove index twice because other pinch view will have replaced it at its index
	NSInteger index = currentIndex < otherIndex ? currentIndex : otherIndex;
    PinchView* newPinchView;
	if(self.isCollection) {
		newPinchView = [(CollectionPinchView*)self.pageElement pinchAndAdd:(SingleMediaAndTextPinchView*)otherScrollView.pageElement];
        [[PostInProgress sharedInstance] removePinchViewAtIndex:index];
        [[PostInProgress sharedInstance] removePinchViewAtIndex:index andReplaceWithPinchView:newPinchView];
        
	} else if(otherScrollView.isCollection){
		newPinchView = [(CollectionPinchView*)otherScrollView.pageElement pinchAndAdd:(SingleMediaAndTextPinchView*)self.pageElement];
		[[PostInProgress sharedInstance] removePinchViewAtIndex:index];
		[[PostInProgress sharedInstance] removePinchViewAtIndex:index andReplaceWithPinchView:newPinchView];

	} else {
		NSMutableArray* pinchViewArray = [[NSMutableArray alloc] initWithObjects:self.pageElement, otherScrollView.pageElement, nil];
		newPinchView = [[CollectionPinchView alloc] initWithRadius: [(PinchView*)self.pageElement radius]
														withCenter: [(PinchView*)self.pageElement center]
													 andPinchViews: pinchViewArray];

		[[PostInProgress sharedInstance] removePinchViewAtIndex:index];
		[[PostInProgress sharedInstance] removePinchViewAtIndex:index];
		[[PostInProgress sharedInstance] addPinchView:newPinchView atIndex:currentIndex];
		pinchViewArray = nil;
	}
	
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
    self.pageElementOriginalFrame = self.pageElement.frame;
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
	if(self.contentOffset.x == self.initialContentOffset.x) {
		return NO;
	}
	return YES;
}

-(void) animateBackToInitialPosition {
	[UIView animateWithDuration:ANIMATE_TO_DELETE_MODE_OR_BACK_DURATION animations:^{
		[self setContentOffset:self.initialContentOffset animated:NO];
	} completion:^(BOOL finished) {
	}];
}

-(void) animateToDeleting {
	[UIView animateWithDuration:ANIMATE_TO_DELETE_MODE_OR_BACK_DURATION animations:^{
		[self setContentOffset:CGPointMake(self.contentSize.width - self.frame.size.width, self.initialContentOffset.y) animated:NO];
	} completion:^(BOOL finished) {
	}];
}

#pragma mark - Open and close collection -

//remove collection view from scrollview and add all its children instead
-(void) openCollectionWithPinchViews:(NSMutableArray *) pinchViews {
	self.collectionIsOpen = YES;
	if(self.pageElement) [self.pageElement removeFromSuperview];
    [self.deleteButton removeFromSuperview];
	[self displayCollectionPinchViews:pinchViews];
}


-(void) addTapGestureToPinchView:(UIView *) pinchView{
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pinchviewTapped:)];
    [pinchView addGestureRecognizer:tapGesture];
}

-(void)pinchviewTapped:(UITapGestureRecognizer *) tapped{
    PinchView * pv = (PinchView *)tapped.view;
    [self.contentPageElementScrollViewDelegate pinchviewSelected:pv];
}

//array of PinchViews
-(void) displayCollectionPinchViews:(NSMutableArray *) pinchViews {
    if(pinchViews.count){
        self.pinchViewStartSize = [(PinchView*)pinchViews[0] radius]*2.f;
        CGFloat pinchViewSize = self.frame.size.height - 5.f;
        CGFloat yPosition = (self.frame.size.height/2.f) - (pinchViewSize/2.f);
        CGFloat xPosition = ELEMENT_Y_OFFSET_DISTANCE;
        for(PinchView* pinchView in pinchViews) {
            CGRect newFrame = CGRectMake(xPosition, yPosition, pinchViewSize, pinchViewSize);
            [pinchView specifyFrame:newFrame];
            [self addTapGestureToPinchView:pinchView];
            [self addSubview:pinchView];
            xPosition += pinchView.frame.size.width + ELEMENT_Y_OFFSET_DISTANCE;
            [pinchView renderMedia];
        }
        self.collectionPinchViews = pinchViews;
        [self adjustScrollViewContentSize];
    }
}

- (NSMutableArray *) closeCollection {

    for(PinchView * pinchView in self.collectionPinchViews){
        [pinchView changeWidthTo:self.pinchViewStartSize];
        [pinchView renderMedia];
    }
    
    
    return self.collectionPinchViews;
}

//moves the views in the scrollview of the opened collection
-(void) moveViewsWithTotalDifference: (float)difference {
	if (!self.collectionIsOpen) {
		return;
	}

	float pinchViewSize = [(PinchView*)self.pageElement radius]*2;
	float scaleFactor = difference/HORIZONTAL_PINCH_THRESHOLD;
	for(NSInteger i = 0; i < self.collectionPinchViews.count; i++) {
		float originalXPosition = (ELEMENT_Y_OFFSET_DISTANCE + pinchViewSize)*i;
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
		int xPosition = ELEMENT_Y_OFFSET_DISTANCE;
		for(PinchView* pinchView in self.collectionPinchViews) {
			CGRect newFrame = CGRectMake(xPosition, ELEMENT_Y_OFFSET_DISTANCE/2, pinchViewSize, pinchViewSize);
			[pinchView specifyFrame:newFrame];
			xPosition += pinchView.frame.size.width + ELEMENT_Y_OFFSET_DISTANCE;
		}
	} completion:^(BOOL finished) {
	}];
}

-(void) selectItemInOpenCollectionFromTouch:(CGPoint) touch {
	if (!self.collectionIsOpen) {
		return;
	}

	if(touch.x < ((PinchView*)self.collectionPinchViews[0]).frame.origin.x - self.contentOffset.x ) {
		return;
	}

	for (SingleMediaAndTextPinchView* pinchView in self.collectionPinchViews) {
		//we stop when we find the first one
		if((pinchView.frame.origin.x + pinchView.frame.size.width) > (touch.x + self.contentOffset.x)) {
			self.selectedItem = pinchView;
			//add it to its parent's scroll view so that it can be moved outside
			//the bounds of the scroll view to be unpinched
			[self.selectedItem removeFromSuperview];
			self.contentOffsetXBeforeLongPress = self.contentOffset.x;
			self.selectedItem.frame = CGRectMake(self.selectedItem.frame.origin.x + self.frame.origin.x - self.contentOffsetXBeforeLongPress,
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
		return nil;
	}

	float xDifference  = touch.x - self.previousLocationOfTouchPoint_PAN.x;
    float yDifference  = touch.y - self.previousLocationOfTouchPoint_PAN.y;
	CGRect newFrame = [self newTranslationFrameForView:self.selectedItem andXDifference:xDifference andYDifference:yDifference];

	//move item
	[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION/2.f animations:^{
		self.selectedItem.frame = newFrame;
	}];

	//swap item if necessary
	NSInteger viewIndex = [self.collectionPinchViews indexOfObject:self.selectedItem];
	PinchView* leftView = nil;
	PinchView* rightView = nil;

	if(viewIndex !=0) {
		leftView = self.collectionPinchViews[viewIndex-1];
	}
	if (viewIndex+1 < [self.collectionPinchViews count]) {
		rightView = self.collectionPinchViews[viewIndex+1];
	}
	//check if object has moved to the 1/2 mark of the view next to it, if so swap them
	if(leftView && (newFrame.origin.x - self.frame.origin.x + newFrame.size.width/2.f)
	   < (leftView.frame.origin.x + leftView.frame.size.width)) {
		[self swapWithLeftView: leftView];
	}
	//check if object has moved down the 1/2 mark of the view below it, if so swap them
	else if(rightView && (newFrame.origin.x - self.frame.origin.x + newFrame.size.width/2.f)
			> rightView.frame.origin.x) {
		[self swapWithRightView: rightView];
	}

	//move the offest of the main scroll view
	[self moveOffsetBasedOnSelectedItem];
	self.previousLocationOfTouchPoint_PAN = touch;

	return nil;
}

-(void) shiftPinchViewsAfterIndex:(NSInteger) index {

    if(self.subviews.count){
        float firstXCoordinate = ELEMENT_Y_OFFSET_DISTANCE;
        

        for(NSInteger i = index; i < [self.collectionPinchViews count]; i++) {
            PinchView* pinchView = self.collectionPinchViews[i];
            float yPosition = (self.frame.size.height/2.f) - (pinchView.frame.size.height/2.f);
            
            CGRect frame = CGRectMake(firstXCoordinate, yPosition,
                                      pinchView.frame.size.width, pinchView.frame.size.height);

            [UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION/2 animations:^{
                [pinchView specifyFrame:frame];
            }];
            firstXCoordinate+= frame.size.width + ELEMENT_Y_OFFSET_DISTANCE;
        }
    }
    [self adjustScrollViewContentSize];
	
}

-(void)adjustScrollViewContentSize{
    CGFloat width = ((PinchView *)[self.collectionPinchViews lastObject]).frame.origin.x + [self.subviews lastObject].frame.size.width + ELEMENT_Y_OFFSET_DISTANCE;
    CGFloat height = 0;
    
    //make sure the main scroll view can show everything
    self.contentSize = CGSizeMake(width,height);
}

//Takes a change in horizontal position and constructs the frame for the views new position
//Takes a change in horizontal position and constructs the frame for the views new position
-(CGRect) newTranslationFrameForView: (UIView*)view andXDifference: (float) xDifference andYDifference: (float) yDifference {
    CGRect frame= CGRectMake(view.frame.origin.x+xDifference, view.frame.origin.y + yDifference,
                             view.frame.size.width, view.frame.size.height);
    return frame;
}


//swap currently selected item's frame with view to the left of it
-(void) swapWithLeftView: (PinchView*) leftView {

	[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION/2 animations:^{

		CGRect potentialFrame = CGRectMake(leftView.frame.origin.x + self.frame.origin.x - self.contentOffsetXBeforeLongPress,
													   leftView.frame.origin.y + self.frame.origin.y,
													   self.previousFrameInLongPress.size.width,
													   self.previousFrameInLongPress.size.height);

		leftView.frame = CGRectMake(self.previousFrameInLongPress.origin.x - self.frame.origin.x  + self.contentOffsetXBeforeLongPress,
								   self.previousFrameInLongPress.origin.y - self.frame.origin.y,
								   leftView.frame.size.width, leftView.frame.size.height);
		self.previousFrameInLongPress = potentialFrame;
        
        
        [self swap:self.selectedItem with:leftView inArray:self.collectionPinchViews];
        
	}];
}


-(void)swap:(id) object1 with:(id) object2 inArray:(NSMutableArray *) array{
    
    CGFloat indexOfObject1 = [array indexOfObject:object1];
    CGFloat indexOfObject2 = [array indexOfObject:object2];
    
    [array replaceObjectAtIndex:indexOfObject1 withObject:object2];
    [array replaceObjectAtIndex:indexOfObject2 withObject:object1];
}


//swap currently selected item's frame with view to the right of it
-(void) swapWithRightView: (PinchView*) rightView {

	[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION/2 animations:^{

		CGRect potentialFrame = CGRectMake(rightView.frame.origin.x + self.frame.origin.x - self.contentOffsetXBeforeLongPress,
													   rightView.frame.origin.y + self.frame.origin.y,
													   self.previousFrameInLongPress.size.width,
													   self.previousFrameInLongPress.size.height);

		rightView.frame = CGRectMake(self.previousFrameInLongPress.origin.x - self.frame.origin.x + self.contentOffsetXBeforeLongPress,
									  self.previousFrameInLongPress.origin.y - self.frame.origin.y,
									  rightView.frame.size.width, rightView.frame.size.height);
		self.previousFrameInLongPress = potentialFrame;
        
        [self swap:self.selectedItem with:rightView inArray:self.collectionPinchViews];

	}];
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
	self.selectedItem.frame = CGRectMake(self.previousFrameInLongPress.origin.x - self.frame.origin.x + self.contentOffsetXBeforeLongPress,
										 self.previousFrameInLongPress.origin.y - self.frame.origin.y,
										 self.previousFrameInLongPress.size.width,
										 self.previousFrameInLongPress.size.height);

	[self addSubview:self.selectedItem];
	[self.selectedItem markAsSelected:NO];
    [self shiftPinchViewsAfterIndex:0];
    [self.contentPageElementScrollViewDelegate pinchviewSelected:self.selectedItem];
    
	//sanitize for next run
	self.selectedItem = nil;
}

//todo:delete
////returns the unpinched PinchView
//-(PinchView*) unPinchObjectAtCurrentIndex: (NSInteger) currentIndex {
//	CollectionPinchView* currentPinchView = (CollectionPinchView*)self.pageElement;
//	SingleMediaAndTextPinchView* unPinched = self.selectedItem;
//	self.selectedItem = nil;
//	NSInteger index = [self.collectionPinchViews indexOfObject:unPinched]-1;
//	if (index < 0) index = 0;
//	
//    [currentPinchView unPinchAndRemove:unPinched];
//
//	//check if there is now only one element in the collection - if so
//	//this should not be collection anymore
//	if ([currentPinchView getNumPinchViews] < 2) {
//		if (currentPinchView.imagePinchViews.count) self.pageElement = currentPinchView.imagePinchViews[0];
//		else self.pageElement = currentPinchView.videoPinchViews[0];
//
//		[(PinchView*)self.pageElement revertToInitialFrame];
//		self.isCollection = NO;
//		self.collectionIsOpen = NO;
//		self.contentSize = self.initialContentSize;
//		self.contentOffset = self.initialContentOffset;
//		[self addSubview:self.deleteButton];
//		self.collectionPinchViews = nil;
//	} else {
//		[self shiftPinchViewsAfterIndex:index];
//	}
//
//	self.selectedItem = nil;
//	[[PostInProgress sharedInstance] removePinchViewAtIndex:currentIndex andReplaceWithPinchView:(PinchView *)self.pageElement];
//	return unPinched;
//}


-(void)markAsSelected:(BOOL) selected{
    if (selected) {
        self.deleteButton.frame = CGRectMake(self.deleteButton.frame.origin.x, self.deleteButton.frame.origin.y,
                                             self.deleteButton.frame.size.width + 10, self.deleteButton.frame.size.height + 10);
        self.deleteButton.layer.shadowOffset = CGSizeMake(5, 0);
        self.deleteButton.layer.shadowRadius = 5;
        self.deleteButton.layer.shadowOpacity = 0.8;
        self.deleteButton.layer.shadowColor = [UIColor blackColor].CGColor;
    } else {
        self.deleteButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.deleteButton.frame = self.deleteButtonFrame;
        self.deleteButton.layer.shadowOpacity = 0;
    }
}



#pragma mark - Clean up when deleted to free memory -

-(void) cleanUp {
	self.pageElement = nil;
	self.collectionPinchViews = nil;
	self.deleteButton = nil;
	self.selectedItem = nil;
}

@end
