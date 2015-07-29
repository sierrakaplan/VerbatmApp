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

-(void)markAsSelected: (BOOL) selected;
-(void)markAsDeleting: (BOOL) deleting;

@end

@interface ContentDevVC : UIViewController

typedef NS_ENUM(NSInteger, PinchingMode) {
	PinchingModeNone,
	PinchingModeVertical,
	PinchingModeHorizontal
};

@property (weak, nonatomic) IBOutlet VerbatmScrollView *mainScrollView;

@property (weak, nonatomic) IBOutlet UITextField *articleTitleField;
@property (weak, nonatomic) IBOutlet UITextField *sandwichWhere;
@property (weak, nonatomic) IBOutlet UITextField *sandwichWhat;
@property (weak, nonatomic) IBOutlet UILabel *sandwichAtLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dotsRight;
@property (weak, nonatomic) IBOutlet UIImageView *dotsLeft;

//keeps track of ContentPageElementScrollViews
@property (strong, nonatomic, readonly) NSMutableArray * pageElementScrollViews;

@property (nonatomic) CGRect containerViewFrame;
//view that is currently being filled in
@property (weak, nonatomic) UITextView * activeTextView;
@property(nonatomic) NSInteger pullBarHeight;
@property (nonatomic, strong) EditContentView * openEditContentView;
@property (nonatomic, strong) PinchView * openPinchView;

- (void) newPinchView: (PinchView *) pinchView belowView:(UIView *)upperView;

-(void) createEditContentViewFromPinchView: (PinchView *) pinchView;
-(void) removeEditContentView;

// either locks the scroll view or frees it
-(void) setMainScrollViewEnabled:(BOOL) enabled;
-(void) removeKeyboardFromScreen;
-(void) closeAllOpenCollections;

@end