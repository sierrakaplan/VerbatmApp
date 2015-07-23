//
//  verbatmContentPageViewController.h
//  Verbatm
//
//  Created by Iain Usiri on 8/29/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VerbatmUITextView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PinchView.h"
#import "VerbatmImageView.h"
#import "VerbatmScrollView.h"
@interface ContentDevVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *articleTitleField;
@property (weak, nonatomic) IBOutlet UITextField *sandwichWhere;
@property (weak, nonatomic) IBOutlet UITextField *sandwichWhat;
@property (weak, nonatomic) IBOutlet UIImageView *dotsRight;
@property (weak, nonatomic) IBOutlet UIImageView *dotsLeft;

@property (strong, atomic) NSMutableArray * pageElements; //elements added to the scrollview- excludes uitextfields at the top of the screen
@property (nonatomic) CGRect containerViewFrame;
@property (strong, nonatomic) VerbatmUITextView * activeTextView; //view that is currently being filled in

-(PinchView *) newPinchObjectBelowView:(UIView *)upperView fromData: (id) data;
-(PinchView *) newPinchObjectBelowView:(UIView *)upperView fromView: (UIView *) view isTextView: (BOOL) isText;
-(void) createEditContentViewFromPinchView: (PinchView *) pinchView andVideo: (AVAsset*) videoAsset;
-(void) createEditContentViewFromPinchView: (PinchView *) pinchView andImageView: (NSData*)imageView;
-(void) createEditContentViewFromPinchView: (PinchView *) pinchView andTextView: (VerbatmUITextView *) textView;
-(void) removeEditContentView: (UITapGestureRecognizer *) sender;//allows you to remove the image scrollview
// either locks the scroll view or frees it
-(void)setMainScrollViewEnabled:(BOOL) enabled;
-(void) removeKeyboardFromScreen;
@property(nonatomic) NSInteger pullBarHeight;
@property (weak, nonatomic) IBOutlet VerbatmScrollView *mainScrollView;
@end


