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

@interface ContentPageElementScrollView()
@property (nonatomic, readwrite) BOOL collectionIsOpen;
@property (nonatomic, readwrite) BOOL isCollection;
@property (nonatomic) CGPoint initialContentOffset;
@property (nonatomic) CGSize initialContentSize;
@property (strong, nonatomic, readwrite) UIView<ContentDevElementDelegate>* pageElement;

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

	if(self.isCollection) {
		newPinchView = [(CollectionPinchView*)self.pageElement pinchAndAdd:(PinchView*)otherScrollView.pageElement];
	} else if(otherScrollView.isCollection){
		newPinchView = [(CollectionPinchView*)otherScrollView.pageElement pinchAndAdd:(PinchView*)self.pageElement];
	} else {
		NSMutableArray* pinchViewArray = [[NSMutableArray alloc] initWithObjects:self.pageElement, otherScrollView.pageElement, nil];
		newPinchView = [PinchView pinchTogether:pinchViewArray];
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

	[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
		int xPosition = ELEMENT_OFFSET_DISTANCE;

		for(PinchView* pinchView in pinchViews) {
			CGRect newFrame = CGRectMake(xPosition, ELEMENT_OFFSET_DISTANCE/2, pinchViewSize, pinchViewSize);
			[pinchView specifyFrame:newFrame];
			[self addSubview:pinchView];
			xPosition += pinchView.frame.size.width + ELEMENT_OFFSET_DISTANCE;
			[pinchView renderMedia];
		}
		self.contentSize = CGSizeMake(xPosition, self.contentSize.height);
	}];
}

-(BOOL) closeCollection {
	if (!self.isCollection
		|| !self.collectionIsOpen) {
		return NO;
	}

	for (PinchView* pinchView in self.subviews) {
		if ([pinchView isKindOfClass:[VideoPinchView class]]) {
			[[(VideoPinchView*)pinchView videoView] stopVideo];
		}
		[pinchView removeFromSuperview];
	}
	self.collectionIsOpen = NO;
	self.contentSize = self.initialContentSize;
	self.contentOffset = self.initialContentOffset;
	[self addSubview:self.pageElement];
	[(CollectionPinchView*)self.pageElement renderMedia];
	return YES;
}

//moves the views in the scrollview of the opened collection
-(void) moveViewsWithTotalDifference: (float)difference {
	if (!self.collectionIsOpen) {
		return;
	}

	float pinchViewSize = [(PinchView*)self.pageElement radius]*2;
	float scaleFactor = difference/HORIZONTAL_PINCH_THRESHOLD;
	NSArray * pinchViews = self.subviews;
	for(NSInteger i = 0; i < pinchViews.count; i++) {
		float originalXPosition = (ELEMENT_OFFSET_DISTANCE + pinchViewSize)*i;
		float originalDistanceFromMiddle = (self.contentSize.width/2.f - pinchViewSize/2.f) - originalXPosition;
		float xTranslation = scaleFactor*originalDistanceFromMiddle;
		CGRect oldFrame = ((PinchView *)pinchViews[i]).frame;
		CGRect newFrame = CGRectMake(originalXPosition + xTranslation, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
		((PinchView *)pinchViews[i]).frame = newFrame;
	}
}


-(void) moveOpenCollectionViewsBack {
	if(!self.collectionIsOpen) {
		return;
	}

	float pinchViewSize = [(PinchView*)self.pageElement radius]*2;

	[UIView animateWithDuration:PINCHVIEW_ANIMATION_DURATION animations:^{
		int xPosition = ELEMENT_OFFSET_DISTANCE;
		for(PinchView* pinchView in self.subviews) {
			CGRect newFrame = CGRectMake(xPosition, ELEMENT_OFFSET_DISTANCE/2, pinchViewSize, pinchViewSize);
			[pinchView specifyFrame:newFrame];
			xPosition += pinchView.frame.size.width + ELEMENT_OFFSET_DISTANCE;
		}
	} completion:^(BOOL finished) {
	}];
}

//-(void) selectItemInOpenCollectionFromTouch:(

@end
