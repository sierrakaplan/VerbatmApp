//
//  verbatmContentPageViewController.h
//  Verbatm
//
//  Created by Iain Usiri on 8/29/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//
//	The content dev VC is in charge of almost all of the creation process -
// 	it handles displaying the channel the post will be published to, all of the pinch views
// 	in the post, and all of the logic for combining pinch views, pinching apart, and in
//	general adding media. It also is responsible for bringing up the Verbatm Camera View to capture media
//	and the Preview Mode where users can further edit their posts.

#import <UIKit/UIKit.h>
#import "CustomNavigationBar.h"
#import "VerbatmScrollView.h"

@class PinchView;
@class MediaSelectTile;
@class SingleMediaAndTextPinchView;
@import Photos;
@class Channel;

@interface ContentDevVC : UIViewController

typedef NS_ENUM(NSInteger, PinchingMode) {
	PinchingModeNone,
	PinchingModeVerticalTogether,
    PinchingModeVerticalApart,
	PinchingModeHorizontal
};

@property (nonatomic) VerbatmScrollView *mainScrollView;

@property (nonatomic) NSInteger startChannelIndex;
@property (nonatomic) NSUInteger currentPresentedPickerRow;

@property (strong, nonatomic) CustomNavigationBar* navBar;

@property (nonatomic) Channel *userChannel;

//view that is currently being filled in
@property (weak, nonatomic) UITextView * activeTextView;

@property(nonatomic) NSInteger pullBarHeight;

// The pinch view that the user has opened and is currently editing
@property (nonatomic, strong) SingleMediaAndTextPinchView* editingPinchView;

//keeps track of ContentPageElementScrollViews
@property (strong, nonatomic) NSMutableArray *pageElementScrollViews;

#pragma mark Pinch Views

@property (nonatomic) NSInteger numPinchViews;
@property (nonatomic) BOOL currentlyPresentingInstruction;
@property (nonatomic) NSMutableArray *pinchViewsToPublish;

-(void) initializeVariables;
-(void) setFrameMainScrollView;
-(void) setElementDefaultFrames;
-(void) addBackgroundImage;
-(void) adjustMainScrollViewContentSize;
-(void) placeNewMediaAtBottomOfDeck;

-(void) getImageFromAsset: (PHAsset *)asset;
-(void) getVideoFromAsset: (PHAsset *) asset;

-(void) removeExcessMediaTiles;
-(void) aboutToRemovePreview;

-(void) presentPinchInstruction;

-(void) publishOurStoryWithPinchViews:(NSMutableArray *)pinchViews;
-(void) continueToPublish;

-(void) textButtonPressedOnTile:(MediaSelectTile*) tile;
-(void) galleryButtonPressedOnTile: (MediaSelectTile *)tile;

@end

@protocol ContentDevElementDelegate <NSObject>

-(void) markAsSelected: (BOOL) selected;
-(void) markAsDeleting: (BOOL) deleting;

@end