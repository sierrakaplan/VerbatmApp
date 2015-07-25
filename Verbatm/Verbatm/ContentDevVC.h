//
//  verbatmContentPageViewController.h
//  Verbatm
//
//  Created by Iain Usiri on 8/29/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PinchView.h"
#import "VerbatmImageView.h"
#import "VerbatmScrollView.h"

@protocol ContentDevElementDelegate <NSObject>

-(void)markAsSelected: (BOOL) selected;
-(void)markAsDeleting: (BOOL) deleting;

@end

@interface ContentDevVC : UIViewController

@property (weak, nonatomic) IBOutlet VerbatmScrollView *mainScrollView;

@property (weak, nonatomic) IBOutlet UITextField *articleTitleField;
@property (weak, nonatomic) IBOutlet UITextField *sandwichWhere;
@property (weak, nonatomic) IBOutlet UITextField *sandwichWhat;
@property (weak, nonatomic) IBOutlet UILabel *sandwichAtLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dotsRight;
@property (weak, nonatomic) IBOutlet UIImageView *dotsLeft;

//elements added to the scrollview- excludes uitextfields at the top of the screen
@property (strong, atomic) NSMutableArray * pageElements;
//keeps track of horizontal scroll views containing pinch views added to screen
@property (strong, atomic) NSMutableArray * pinchViewScrollViews;
@property (nonatomic) CGRect containerViewFrame;
//view that is currently being filled in
@property (strong, nonatomic) UITextView * activeTextView;
@property(nonatomic) NSInteger pullBarHeight;

-(PinchView *) newPinchObjectBelowView:(UIView *)upperView fromData: (id) data;
-(PinchView *) newPinchObjectBelowView:(UIView *)upperView fromView: (UIView *) view isTextView: (BOOL) isText;
-(void) createEditContentViewFromPinchView: (PinchView *) pinchView andVideo: (AVAsset*) videoAsset;
-(void) createEditContentViewFromPinchView: (PinchView *) pinchView andImageView: (NSData*)imageView;
-(void) createEditContentViewFromPinchView: (PinchView *) pinchView andTextView: (UITextView *) textView;
-(void) removeEditContentView;//allows you to remove the image scrollview
// either locks the scroll view or frees it
-(void)setMainScrollViewEnabled:(BOOL) enabled;
-(void) removeKeyboardFromScreen;
-(void) closeAllOpenCollections;


typedef NS_ENUM(NSInteger, PinchingMode) {
	PinchingModeNone,
	PinchingModeVertical,
	PinchingModeHorizontal
};

@end