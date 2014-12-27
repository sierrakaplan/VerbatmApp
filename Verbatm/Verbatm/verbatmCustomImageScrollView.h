//
//  verbatmCustomImageScrollView.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/20/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILTranslucentView.h"
#import "verbatmCustomImageView.h"
#import "verbatmCustomPinchView.h"
#import  "verbatmUITextView.h"
@interface verbatmCustomImageScrollView : UIScrollView
-(instancetype)initCustomViewWithFrame:(CGRect)frame;
-(void)addImage: (verbatmCustomImageView *) givenImageView withPinchObject: (verbatmCustomPinchView *) pinchObject;
-(void) createTextViewFromTextView: (UITextView *) textView;
-(void)adjustImageScrollViewContentSizing;
-(void)adjustFrameOfTextViewForGap:(NSInteger) gap;
@property (nonatomic, strong) verbatmUITextView * textView;
@property (nonatomic, strong) verbatmCustomImageView * openImage;
@end
