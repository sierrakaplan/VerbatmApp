//
//  verbatmCustomImageScrollView.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/20/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import  "VerbatmUITextView.h"
#import "VideoPlayerView.h"

@protocol EditContentViewDelegate <NSObject>

//Tells parent view controller that edit content view should exit
-(void) exitEditContentView;

@end

@interface EditContentView : UIView

-(instancetype)initCustomViewWithFrame:(CGRect)frame;
-(void) displayVideo: (AVAsset*) videoAsset;
//passes it an array of UIImages to display
-(void)displayImages: (NSArray*) filteredImages atIndex:(NSInteger)index;
-(void) editText: (NSString *) text;
-(NSString*) getText;
-(void)adjustContentSizing;
-(void)adjustFrameOfTextViewForGap:(NSInteger) gap;
-(NSInteger) getFilteredImageIndex;

@property (nonatomic, strong) VerbatmUITextView * textView;
@property (nonatomic, strong) VideoPlayerView * videoView;
@property (nonatomic, strong) id<EditContentViewDelegate> delegate;

@end
