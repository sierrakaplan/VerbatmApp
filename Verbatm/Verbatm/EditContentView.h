//
//  verbatmCustomImageScrollView.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/20/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VerbatmImageView.h"
#import "PinchView.h"
#import  "VerbatmUITextView.h"
@interface EditContentView : UIView
-(instancetype)initCustomViewWithFrame:(CGRect)frame;
-(void) addVideo: (AVAsset*) video;
-(void) addImage: (NSData*) image;
-(void) createTextViewFromTextView: (UITextView *) textView;
-(void)adjustContentSizing;
-(void)adjustFrameOfTextViewForGap:(NSInteger) gap;
@property (nonatomic, strong) VerbatmUITextView * textView;
@property (nonatomic, strong) VerbatmImageView * imageView;
@property (nonatomic, strong) VideoPlayerView * videoView;

@end
