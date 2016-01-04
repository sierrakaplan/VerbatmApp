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

-(void) povPublishedWithUserName:(NSString*)userName andTitle:(NSString*)title andProgressObject:(NSProgress*)progress;

@end

@interface ContentDevVC : UIViewController

typedef NS_ENUM(NSInteger, PinchingMode) {
	PinchingModeNone,
	PinchingModeVertical,
    PinchingModeVerticalUndo,
	PinchingModeHorizontal
};

@property (weak, nonatomic) IBOutlet VerbatmScrollView *mainScrollView;

@property (nonatomic) NSArray * userChannels;


//Delegate in order to tell parent view controller when pull bar should be changed
@property (strong, nonatomic) id<ContentDevVCDelegate> delegate;
@property (strong, nonatomic) UIPickerView *titleField;
@property (nonatomic) NSUInteger currentPresentedPickerRow;


@property (strong, nonatomic) CustomNavigationBar* navBar;

//view that is currently being filled in
@property (weak, nonatomic) UITextView * activeTextView;
@property(nonatomic) NSInteger pullBarHeight;
// The pinch view that the user has opened and is currently editing
@property (nonatomic, strong) SingleMediaAndTextPinchView* editingPinchView;

@end

@protocol ContentDevElementDelegate <NSObject>

-(void) markAsSelected: (BOOL) selected;
-(void) markAsDeleting: (BOOL) deleting;

@end