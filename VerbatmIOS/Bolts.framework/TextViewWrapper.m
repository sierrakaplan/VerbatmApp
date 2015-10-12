//
//  photoVideoWrapperViewForText.m
//  Verbatm
//
//  Created by Iain Usiri on 10/7/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "TextViewWrapper.h"

@interface TextViewWrapper ()

@property (nonatomic, readwrite) BOOL textShowing;

@end

@implementation TextViewWrapper

-(void)showText{
    if(self.textView && !self.textShowing){
        [self addSubview:self.textView];
        [self bringSubviewToFront:self.textView];
        self.textShowing = !self.textShowing;
    }
    
}
-(void)hideText{
    if(self.textView && self.textShowing){
        [self.textView removeFromSuperview];
        self.textShowing = !self.textShowing;
    }
    
}

@end
