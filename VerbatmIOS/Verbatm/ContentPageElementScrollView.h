/*
 //  ContentPageElementScrollView.m
 //  Verbatm
 //
 //  Created by Sierra Kaplan-Nelson on 7/27/15.
 //  Copyright (c) 2015 Verbatm. All rights reserved.
 //
	Is a horizontal scroll view containing a pinch object 
 
 */

#import <UIKit/UIKit.h>
#import "ContentDevVC.h"

@class CollectionPinchView;
@class ContentPageElementScrollView;

@protocol ContentPageElementScrollViewDelegate <NSObject>

-(void) deleteButtonPressedOnContentPageElementScrollView:(ContentPageElementScrollView*)scrollView;
-(void) pinchviewSelected:(PinchView *) pinchView;
@end

@interface ContentPageElementScrollView : UIScrollView

@property (nonatomic, strong) id<ContentPageElementScrollViewDelegate> contentPageElementScrollViewDelegate;

@property (strong, nonatomic, readonly) UIView<ContentDevElementDelegate>* pageElement;

@property (strong, nonatomic, readonly) SingleMediaAndTextPinchView* selectedItem;

-(id) initWithFrame:(CGRect)frame andElement:(UIView<ContentDevElementDelegate>*) element;

//puts the pinch view in the middle of the screen
-(void)centerView;


#pragma mark Deleting

//checks if scroll view is close enough to edge to be deleted
-(BOOL) isDeleting;

-(void) animateBackToInitialPosition;

-(void) animateToDeleting;

#pragma mark Changing page element

//checks that both contain pinch views and both are not collections
-(BOOL) okToPinchWith:(ContentPageElementScrollView*)otherScrollView;

//up to the caller to check that the two are ok to pinch first
//removes the other scroll view from its superview
//Returns the pinched pinch view
-(PinchView*) pinchWith:(ContentPageElementScrollView*)otherScrollView currentIndex:(NSInteger)currentIndex otherIndex:(NSInteger)otherIndex;

//changes the page element and updates the scroll view
-(void) changePageElement:(UIView<ContentDevElementDelegate>*) newPageElement;

#pragma mark Collection opening and closing

@property (nonatomic, readonly) BOOL isCollection;
// if the page element is a collectionPinchView, this can be YES
// otherwise will always be NO
@property (nonatomic, readonly) BOOL collectionIsOpen;

//will present the pinchviews sent in on the scrollview
-(void) openCollectionWithPinchViews:(NSMutableArray *) pinchViews;

// will close the open collection and return a list of all the pinchviews 
- (NSMutableArray *) closeCollection;


//animates the open collection pinch views closer together (all will move towards the middle of the collection)
-(void) moveViewsWithTotalDifference: (float)difference;

//moves pinch views in open collection back to their starting locations
-(void) moveOpenCollectionViewsBack;

//marks the pinch view being touched as selected (if there is any)
-(void) selectItemInOpenCollectionFromTouch:(CGPoint) touch;

//moves the selected pinch view to new location horizontally in collection
//if it was moved vertically far enough from collection it is unpinched
//from collection and returned
-(PinchView*) moveSelectedItemFromTouch:(CGPoint) touch;

-(void) finishMovingSelectedItem;

-(void) cleanUp;

-(void)markAsSelected:(BOOL) selected;

@end

