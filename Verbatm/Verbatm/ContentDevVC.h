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
@property (weak, nonatomic) IBOutlet UITextField *sandwhichWhat;
@property (strong, atomic) NSMutableArray * pageElements; //elements added to the scrollview- excludes uitextfields at the top of the screen
@property (nonatomic) CGRect containerViewFrame;
@property (strong, nonatomic) VerbatmUITextView * activeTextView; //view that is currently being filled in

-(PinchView *) newPinchObjectBelowView:(UIView *)upperView fromData: (id) data;
-(PinchView *) newPinchObjectBelowView:(UIView *)upperView fromView: (UIView *) view isTextView: (BOOL) isText;
-(void) createVerbatmImageScrollViewFromPinchView: (PinchView *) pinchView andVideo: (AVAsset*) videoAsset;
-(void) createVerbatmImageScrollViewFromPinchView: (PinchView *) pinchView andImageView: (NSData*)imageView;
-(void) createVerbatmImageScrollViewFromPinchView: (PinchView *) pinchView andTextView: (VerbatmUITextView *) textView;
-(void) removeImageScrollview: (UITapGestureRecognizer *) sender;//allows you to remove the image scrollview
-(void)freeMainScrollView:(BOOL) isFree; // either locks the scroll view or frees it
-(void)alertGallery:(ALAsset*)asset;
-(void) removeKeyboardFromScreen;
@property(nonatomic) NSInteger pullBarHeight;
@property (weak, nonatomic) IBOutlet VerbatmScrollView *mainScrollView;
@end

