//
//  verbatmContentPageViewController.h
//  Verbatm
//
//  Created by Iain Usiri on 8/29/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationBar.h"
#import "VerbatmScrollView.h"

@class PinchView;
@class SingleMediaAndTextPinchView;
@import Photos;

// Delegate tells when pull bar should be shown, hidden,
//or when undo and preview are/n't possible
@protocol ContentDevVCDelegate <NSObject>

-(void) povPublishedWithUserName:(NSString*)userName andTitle:(NSString*)title andCoverPic:(UIImage*)coverPhoto andProgressObject:(NSProgress*)progress;

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
@property (strong, nonatomic) UITextField *titleField;
@property (strong, nonatomic) CustomNavigationBar* navBar;

//view that is currently being filled in
@property (weak, nonatomic) UITextView * activeTextView;
@property(nonatomic) NSInteger pullBarHeight;
// The pinch view that the user has opened and is currently editing
@property (nonatomic, strong) SingleMediaAndTextPinchView* editingPinchView;


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

@protocol ContentDevElementDelegate <NSObject>

-(void) markAsSelected: (BOOL) selected;
-(void) markAsDeleting: (BOOL) deleting;

@end