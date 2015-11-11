//
//  verbatmContentPageViewController.h
//  Verbatm
//
//  Created by Iain Usiri on 8/29/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;

#import "ContentDevNavBar.h"
#import "VerbatmScrollView.h"
#import "EditContentView.h"

@class PinchView;

@protocol ContentDevElementDelegate <NSObject>

-(void) markAsSelected: (BOOL) selected;
-(void) markAsDeleting: (BOOL) deleting;

@end

// Delegate tells when pull bar should be shown, hidden,
//or when undo and preview are/n't possible
@protocol ContentDevVCDelegate <NSObject>

-(void) backButtonPressed;
-(void) previewButtonPressed;
-(void) showPullBar: (BOOL) showPullBar withTransition: (BOOL) withTransition;

@end

@interface ContentDevVC : UIViewController

typedef NS_ENUM(NSInteger, PinchingMode) {
	PinchingModeNone,
	PinchingModeVertical,
    PinchingModeVertical_Undo,
	PinchingModeHorizontal
};

@property (weak, nonatomic) IBOutlet VerbatmScrollView *mainScrollView;

//Delegate in order to tell parent view controller when pull bar should be changed
@property (strong, nonatomic) id<ContentDevVCDelegate> delegate;

@property (strong, nonatomic) UITextField *titleField;

@property (strong, nonatomic) ContentDevNavBar* navBar;

//view that is currently being filled in
@property (weak, nonatomic) UITextView * activeTextView;
@property(nonatomic) NSInteger pullBarHeight;
@property (nonatomic, strong) EditContentView * openEditContentView;
@property (nonatomic, strong) PinchView * openPinchView;


-(void) addImageToStream: (UIImage*) image;
/*
 Given a PHAsset representing a video and we create a pinch view out of it
 */
-(void) addMediaAssetToStream:(PHAsset *) asset;


-(UIImage*) getCoverPicture;
-(NSArray*) getPinchViews;

//presents gallery so user can pick assets
-(void) presentEfficientGallery;
// Loads title, cover photo, and pinch views from user's saved settings
// (if they exist)
-(void) loadPOVFromUserDefaults;
- (void) newPinchView: (PinchView *) pinchView belowView:(UIView *)upperView;

// either locks the scroll view or frees it
-(void) removeKeyboardFromScreen;
// sets elements to nil to free memory
-(void)cleanUp;


@end