//
//  TextAndOtherAves.h
//  Verbatm
//
//  Created by Iain Usiri on 7/18/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVETypeAnalyzer.h"

@interface TextAndOtherAves : UIView
-(instancetype)initWithFrame:(CGRect) frame text:(NSString*)text aveType:(AVEType)aveType aveMedia: (NSArray *)media;
-(void)addGestureToView;
@end
