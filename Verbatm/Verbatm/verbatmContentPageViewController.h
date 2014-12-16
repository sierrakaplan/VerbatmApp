//
//  verbatmContentPageViewController.h
//  Verbatm
//
//  Created by Iain Usiri on 8/29/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "verbatmUITextView.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface verbatmContentPageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *articleTitleField;
@property (weak, nonatomic) IBOutlet UITextField *sandwichWhere;
@property (weak, nonatomic) IBOutlet UITextField *sandwhichWhat;
@property (strong, nonatomic) NSMutableArray * pageElements; //elements added to the scrollview- excludes uitextfields
@property (nonatomic) CGRect containerViewFrame;
@property (nonatomic) BOOL containerAtHalfScreen;// tells the contentpage if it's in half view
@property (strong, nonatomic) verbatmUITextView * activeTextView; //view that is currently being filled in


-(void)createNewTextViewBelowView: (UIView *) topView;
-(void)freeMainScrollView:(BOOL) isFree; // either locks the scroll view or frees it
-(void)alertGallery:(ALAsset*)asset;
@property(nonatomic) NSInteger pullBarHeight;

@end


