//
//  TextAndOtherAves.h
//  Verbatm
//
//  Created by Iain Usiri on 7/18/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextAndOtherAves : UIView
-(instancetype)initWithFrame:(CGRect) frame text:(NSString*)text aveType:(NSString*)AVE aveMedia: (NSArray *)media;
-(void)addGestureToView;
@end
