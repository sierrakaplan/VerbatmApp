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

@interface BaseArticleViewingExperience : UIView
-(instancetype)initWithFrame:(CGRect)frame andText:(NSString*)text andPhotos: (NSMutableArray *)photos andVideos: (NSMutableArray *)videos andAVEType:(AVEType)aveType;

-(int)numberOfLinesInTextView:(UITextView *)textView;
-(void) showText:(BOOL)show;

//set a view to animate to fill the screen
-(void) setViewAsMainView: (UIView*) view;
-(void) removeMainView;
-(BOOL) mainViewIsFullScreen;
@end
