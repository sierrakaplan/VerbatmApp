/*
 //  ContentPageElementScrollView.m
 //  Verbatm
 //
 //  Created by Sierra Kaplan-Nelson on 7/27/15.
 //  Copyright (c) 2015 Verbatm. All rights reserved.
 //
	Is a horizontal scroll view containing a page element 
 
 */

#import <UIKit/UIKit.h>
#import "ContentDevVC.h"

@class CollectionPinchView;

@interface ContentPageElementScrollView : UIScrollView

@property (strong, nonatomic, readonly) UIView<ContentDevElementDelegate>* pageElement;

-(id) initWithFrame:(CGRect)frame andElement:(UIView<ContentDevElementDelegate>*) element;

#pragma mark Deleting

//checks if scroll view is close enough to edge to be deleted
-(BOOL) isDeleting;

-(void) animateBackToInitialPosition;

-(void) animateOffScreen;

#pragma mark Changing page element

//checks that both contain pinch views and both are not collections
-(BOOL) okToPinchWith:(ContentPageElementScrollView*)otherScrollView;

//up to the caller to check that the two are ok to pinch first
//removes the other scroll view from its superview
//Returns the pinched pinch view
-(PinchView*) pinchWith:(ContentPageElementScrollView*)otherScrollView;

//changes the page element and updates the scroll view
-(void) changePageElement:(UIView<ContentDevElementDelegate>*) newPageElement;

#pragma mark Collection opening and closing

@property (nonatomic, readonly) BOOL isCollection;
// if the page element is a collectionPinchView, this can be YES
// otherwise will always be NO
@property (nonatomic, readonly) BOOL collectionIsOpen;

// If can open the collection, will open and return YES
// otherwise will return NO
-(BOOL) openCollection;

// If can open the collection, will open and return YES
// otherwise will return NO
-(BOOL) closeCollection;

//animates the open collection pinch views closer together (all will move towards the middle of the collection)
-(void) moveViewsWithTotalDifference: (float)difference;

//moves pinch views in open collection back to their starting locations
-(void) moveOpenCollectionViewsBack;

@end

