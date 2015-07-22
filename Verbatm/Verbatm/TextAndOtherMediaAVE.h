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

@interface TextAndOtherMediaAVE : UIView
-(instancetype)initWithFrame:(CGRect)frame andText:(NSString*)text andPhotos: (NSMutableArray *)photos andVideos: (NSMutableArray *)videos andAVEType:(AVEType)aveType;
-(void)addPullDownBarForText;
@end
