//
//  TextAndOtherAves.h
//  Verbatm
//
//  Created by Iain Usiri on 7/18/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVETypeAnalyzer.h"
#import "TextOverAVEView.h"

@protocol AVEDelegate <NSObject>

-(void)viewDidAppear;

@end

@interface BaseArticleViewingExperience : UIView

typedef NS_ENUM(NSInteger, AVEType) {
	AVETypeVideo,
	AVETypePhoto,
	AVETypePhotoVideo
};

-(instancetype)initWithFrame:(CGRect)frame andText:(NSString*)text andPhotos: (NSArray *)photos andVideos: (NSArray *)videos andAVEType:(AVEType)aveType;

-(int)numberOfLinesInTextView:(UITextView *)textView;
-(void) showText:(BOOL)show;

//set a view to animate to fill the screen
-(void) setViewAsMainView: (UIView*) view;
-(void) removeMainView;
-(BOOL) mainViewIsFullScreen;
-(void) viewDidAppear;
@end
