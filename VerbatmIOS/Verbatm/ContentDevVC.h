//
//  verbatmContentPageViewController.h
//  Verbatm
//
//  Created by Iain Usiri on 8/29/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "VerbatmScrollView.h"
#import "EditContentView.h"

@class PinchView;

@protocol ContentDevElementDelegate <NSObject>

-(void) markAsSelected: (BOOL) selected;
-(void) markAsDeleting: (BOOL) deleting;

@end

// Delegate tells when pull bar should be shown, hidden,
//or when undo and preview are/n't possible
@protocol ChangePullBarDelegate <NSObject>

-(void) showPullBar: (BOOL) showPullBar withTransition: (BOOL) withTransition;
-(void) canPreview: (BOOL) canPreview;

@end

@interface ContentDevVC : UIViewController

typedef NS_ENUM(NSInteger, PinchingMode) {
	PinchingModeNone,
	PinchingModeVertical,
	PinchingModeHorizontal
};

@property (weak, nonatomic) IBOutlet VerbatmScrollView *mainScrollView;

@property (strong, nonatomic) UILabel *whatIsItLikeLabel;
@property (strong, nonatomic) UITextField *whatIsItLikeField;


//keeps track of ContentPageElementScrollViews
@property (strong, nonatomic, readonly) NSMutableArray * pageElementScrollViews;

//Delegate in order to tell parent view controller when pull bar should be changed
@property (strong, nonatomic) id<ChangePullBarDelegate> changePullBarDelegate;

//view that is currently being filled in
@property (weak, nonatomic) UITextView * activeTextView;
@property(nonatomic) NSInteger pullBarHeight;
@property (nonatomic, strong) EditContentView * openEditContentView;
@property (nonatomic, strong) PinchView * openPinchView;


-(UIImage*) getCoverPicture;

//presents gallery so user can pick assets
-(void) presentEfficientGallery;

// Loads pinch views from saved settings
-(void) loadPinchViews;

- (void) newPinchView: (PinchView *) pinchView belowView:(UIView *)upperView;

- (void) createEditContentViewFromPinchView: (PinchView *) pinchView;

// either locks the scroll view or frees it
-(void) setMainScrollViewEnabled:(BOOL) enabled;
-(void) removeKeyboardFromScreen;
-(void) closeAllOpenCollections;

-(void)cleanUp;

// Interacting with media dev vc
-(void)undoTileDeleteSwipe;

@end