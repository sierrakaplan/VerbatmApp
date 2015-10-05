//
//  verbatmContentPageViewController.h
//  Verbatm
//
//  Created by Iain Usiri on 8/29/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

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
	PinchingModeHorizontal
};

@property (weak, nonatomic) IBOutlet VerbatmScrollView *mainScrollView;

//Delegate in order to tell parent view controller when pull bar should be changed
@property (strong, nonatomic) id<ContentDevVCDelegate> delegate;

@property (strong, nonatomic) UILabel *whatIsItLikeLabel;
@property (strong, nonatomic) UITextField *whatIsItLikeField;

@property (strong, nonatomic) ContentDevNavBar* navBar;

//view that is currently being filled in
@property (weak, nonatomic) UITextView * activeTextView;
@property(nonatomic) NSInteger pullBarHeight;
@property (nonatomic, strong) EditContentView * openEditContentView;
@property (nonatomic, strong) PinchView * openPinchView;

-(void)addMediaAssetToStream:(ALAsset *) asset;


-(UIImage*) getCoverPicture;
-(NSArray*) getPinchViews;

//presents gallery so user can pick assets
-(void) presentEfficientGallery;
// Loads pinch views from saved settings
-(void) loadPinchViews;
- (void) newPinchView: (PinchView *) pinchView belowView:(UIView *)upperView;

// either locks the scroll view or frees it
-(void) removeKeyboardFromScreen;
-(void)cleanUp;


@end