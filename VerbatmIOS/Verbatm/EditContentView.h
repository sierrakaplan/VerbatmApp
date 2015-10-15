//
//  verbatmCustomImageScrollView.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/20/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayerView.h"

@protocol EditContentViewDelegate <NSObject>

//Tells parent view controller that edit content view should exit
-(void) exitEditContentView;

@end

@interface EditContentView : UIView

@property (nonatomic, strong) VideoPlayerView * videoView;

-(void) displayVideo: (AVAsset*) videoAsset;

//passes it an array of UIImages to display
-(void)displayImages: (NSArray*) filteredImages atIndex:(NSInteger)index;

-(void)createTextCreationButton;

-(void) setText: (NSString*) text andTextViewYPosition: (CGFloat) yPosition;

-(NSString*) getText;

-(NSNumber*) getTextYPosition;

-(NSInteger) getFilteredImageIndex;

@property (nonatomic, strong) id<EditContentViewDelegate> delegate;

@end
